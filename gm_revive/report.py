"""Compatibility report: scan a folder of GameMaker projects and list what gm-revive can't handle yet."""
import os
import re
from collections import Counter

from .gmk import detect, load, UnsupportedFormat
from .build import Conversion, RUNTIME_DIR

PROJECT_EXTS = ('.gmk', '.gm81', '.gm6', '.gmd', '.yyp', '.project.gmx')


def implemented_builtins():
    """Names the JS runtime provides on its B object (functions, variables and constants)."""
    with open(os.path.join(RUNTIME_DIR, 'runtime.js'), encoding='utf-8') as fh:
        src = fh.read()
    names = set(re.findall(r'\bB\.(\w+)\s*=', src))
    names |= set(re.findall(r"defineProperty\(B,\s*'(\w+)'", src))
    m = re.search(r'const C = \{(.*?)\n    \};', src, re.S)           # the constants table (c_red, vk_left, ...)
    if m:
        names |= set(re.findall(r'(\w+):', m.group(1)))
    return names


def implemented_extensions():
    with open(os.path.join(RUNTIME_DIR, 'runtime.js'), encoding='utf-8') as fh:
        m = re.search(r"B\._extensions = \[(.*?)\]", fh.read())
    return set(re.findall(r"'([^']+)'", m.group(1))) if m else set()


def find_projects(root):
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = [d for d in dirnames if not d.startswith('.')]
        for f in sorted(filenames):
            if f.lower().endswith(PROJECT_EXTS):
                yield os.path.join(dirpath, f)


def analyse(path, have):
    """Returns a dict describing one project's compatibility."""
    fmt, ver = detect(path)
    info = {'path': path, 'format': fmt or 'not a GameMaker project', 'status': 'unsupported',
            'missing': Counter(), 'dnd': {}, 'errors': [], 'extensions': [], 'stats': ''}
    try:
        g = load(path)
    except UnsupportedFormat as e:
        info['note'] = str(e).split(': ', 1)[-1]
        return info
    except Exception as e:  # corrupt or unexpected data
        info['status'] = 'failed'
        info['note'] = f'could not be read: {e}'
        return info
    conv = Conversion(g, os.path.basename(path))
    info['extensions'] = [e for e in g['extensions'] if e not in implemented_extensions()]
    info['errors'] = conv.errors
    info['dnd'] = conv.dnd_actions
    for name in conv.ctx.used_builtins:
        if name not in have:
            info['missing'][name] += 1
    n = lambda k: len([x for x in g[k] if x])
    info['stats'] = (f'{n("objects")} objects, {n("scripts")} scripts, {n("rooms")} rooms, '
                     f'{n("sprites")} sprites, {n("sounds")} sounds')
    blocked = info['errors'] or info['missing'] or info['dnd'] or info['extensions']
    info['status'] = 'needs work' if blocked else 'ready'
    return info


def build_report(root):
    have = implemented_builtins()
    results = [analyse(p, have) for p in find_projects(root)]
    lines = ['# gm-revive compatibility report', '', f'Scanned `{root}` — {len(results)} project file(s).', '']
    by_status = Counter(r['status'] for r in results)
    lines.append('| Status | Count |')
    lines.append('|---|---|')
    for st in ('ready', 'needs work', 'unsupported', 'failed'):
        if by_status[st]:
            lines.append(f'| {st} | {by_status[st]} |')
    lines.append('')

    formats = Counter(r['format'] for r in results)
    lines += ['## Formats found', '']
    for fmt, c in formats.most_common():
        lines.append(f'- {fmt}: {c}')
    lines.append('')

    # What to build next, ranked by how many projects need it
    need_fn, need_dnd, need_ext = Counter(), Counter(), Counter()
    for r in results:
        for k in r['missing']:
            need_fn[k] += 1
        for k in r['dnd']:
            need_dnd[k] += 1
        for k in r['extensions']:
            need_ext[k] += 1
    if need_fn or need_dnd or need_ext:
        lines += ['## What to implement next', '', 'Ranked by how many of the readable projects need it.', '']
        if need_fn:
            lines += ['### Built-in functions missing from the runtime', '']
            lines += [f'- `{k}` — {c} project(s)' for k, c in need_fn.most_common()]
            lines.append('')
        if need_dnd:
            lines += ['### Drag & drop actions (not translated yet)', '']
            lines += [f'- `{k}` — {c} project(s)' for k, c in need_dnd.most_common()]
            lines.append('')
        if need_ext:
            lines += ['### Extension packages (code is not stored in the project; needs a JS replacement)', '']
            lines += [f'- {k} — {c} project(s)' for k, c in need_ext.most_common()]
            lines.append('')

    lines += ['## Per project', '']
    for r in results:
        rel = os.path.relpath(r['path'], root)
        lines.append(f'### {rel}')
        lines.append(f'- Format: {r["format"]} — **{r["status"]}**')
        if r.get('note'):
            lines.append(f'- {r["note"]}')
        if r['stats']:
            lines.append(f'- {r["stats"]}')
        if r['missing']:
            lines.append('- Missing functions: ' + ', '.join(f'`{k}`' for k in sorted(r['missing'])))
        if r['dnd']:
            lines.append('- Drag & drop actions: ' + ', '.join(f'`{k}` ×{c}' for k, c in sorted(r['dnd'].items())))
        if r['extensions']:
            lines.append('- Extensions: ' + ', '.join(r['extensions']))
        for e in r['errors'][:10]:
            lines.append(f'- Translation error: {e}')
        if len(r['errors']) > 10:
            lines.append(f'- …and {len(r["errors"]) - 10} more translation errors')
        lines.append('')
    return '\n'.join(lines), results
