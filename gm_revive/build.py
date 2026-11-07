"""Convert a GameMaker 7 or 8.0 project into a self-contained HTML5 build directory."""
import base64
import json
import os
import shutil
import struct
import subprocess
import tempfile
import zlib

from .gmk import load, RESOURCE_KINDS
from .gml2js import Context, translate, translate_expr, prescan_globalvars, ParseError
from .rtf2html import rtf_to_html

HERE = os.path.dirname(os.path.abspath(__file__))
RUNTIME_DIR = os.path.join(HERE, 'runtime')

EVENT_NAMES = {0: 'create', 1: 'destroy', 2: 'alarm', 3: 'step', 4: 'collision', 5: 'keyboard',
               6: 'mouse', 7: 'other', 8: 'draw', 9: 'keypress', 10: 'keyrelease', 11: 'trigger'}
# Files a game may load from its working directory at runtime (sprite_replace, sound_replace, ...)
EXTRA_FILE_TYPES = ('.png', '.jpg', '.jpeg', '.gif', '.bmp', '.mp3', '.wav', '.ogg', '.txt', '.ini')
SOUNDFONT_CANDIDATES = [
    '/usr/share/sounds/sf2/FluidR3_GM.sf2',
    '/usr/share/soundfonts/FluidR3_GM.sf2',
    '/usr/share/soundfonts/default.sf2',
    '/opt/homebrew/share/soundfonts/default.sf2',
    os.path.expanduser('~/soundfonts/FluidR3_GM.sf2'),
    r'C:\soundfonts\FluidR3_GM.sf2',
]


def png_from_bgra(w, h, raw):
    """Encode GameMaker's raw BGRA pixel data as a PNG (no third-party libraries needed)."""
    rows = []
    for y in range(h):
        row = bytearray(raw[y * w * 4:(y + 1) * w * 4])
        row[0::4], row[2::4] = row[2::4], row[0::4]
        rows.append(b'\x00' + bytes(row))

    def chunk(t, d):
        c = struct.pack('>I', len(d)) + t + d
        return c + struct.pack('>I', zlib.crc32(t + d) & 0xffffffff)

    return (b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', struct.pack('>IIBBBBB', w, h, 8, 6, 0, 0, 0))
            + chunk(b'IDAT', zlib.compress(b''.join(rows), 9)) + chunk(b'IEND', b''))


def find_soundfont(explicit=None):
    if explicit is False:          # MIDI rendering explicitly disabled
        return None
    for cand in [explicit, os.environ.get('GM_REVIVE_SOUNDFONT')] + SOUNDFONT_CANDIDATES:
        if cand and os.path.isfile(cand):
            return cand
    return None


def midi_to_mp3(path, soundfont, log):
    """Browsers can't play MIDI, so render it to MP3 with FluidSynth + ffmpeg. Returns mp3 path or None."""
    mp3 = os.path.splitext(path)[0] + '.mp3'
    if os.path.exists(mp3):
        return mp3
    if not soundfont or not shutil.which('fluidsynth') or not shutil.which('ffmpeg'):
        return None
    with tempfile.TemporaryDirectory() as td:
        wav = os.path.join(td, 'render.wav')
        r = subprocess.run(['fluidsynth', '-ni', '-g', '0.8', '-r', '44100', '-F', wav, soundfont, path],
                           capture_output=True)
        if r.returncode or not os.path.exists(wav):
            log(f'  warning: fluidsynth failed on {os.path.basename(path)}')
            return None
        # trim the trailing silence fluidsynth leaves after the last note
        subprocess.run(['ffmpeg', '-y', '-loglevel', 'error', '-i', wav,
                        '-af', 'areverse,silenceremove=start_periods=1:start_threshold=-60dB,areverse',
                        '-codec:a', 'libmp3lame', '-b:a', '128k', mp3], check=True)
    return mp3


def event_label(et, en):
    """A readable name for an event (eject comments): 'end step', 'alarm 3', 'key release M', ..."""
    if et == 3: return {0: 'begin step', 1: 'step', 2: 'end step'}.get(en, f'step {en}')
    if et == 2: return f'alarm {en}'
    if et == 8: return 'draw' if en == 0 else f'draw {en}'
    if et in (5, 9, 10):
        what = {5: 'key held', 9: 'key press', 10: 'key release'}[et]
        keys = {32: 'space', 13: 'enter', 27: 'escape', 37: 'left', 38: 'up', 39: 'right', 40: 'down', 0: 'no key', 1: 'any key'}
        k = keys.get(en) or (chr(en) if 48 <= en <= 90 else (f'F{en - 111}' if 112 <= en <= 123 else str(en)))
        return f'{what} {k}'
    if et == 6:
        mouse = {0: 'left button', 1: 'right button', 2: 'middle button', 3: 'no button', 4: 'left pressed', 5: 'right pressed',
                 6: 'middle pressed', 7: 'left released', 8: 'right released', 9: 'middle released', 10: 'mouse enter',
                 11: 'mouse leave', 50: 'global left button', 51: 'global right button', 52: 'global middle button',
                 53: 'global left pressed', 54: 'global right pressed', 55: 'global middle pressed', 56: 'global left released',
                 57: 'global right released', 58: 'global middle released', 60: 'wheel up', 61: 'wheel down'}
        return 'mouse: ' + mouse.get(en, str(en))
    if et == 7:
        other = {0: 'outside room', 1: 'intersect boundary', 2: 'game start', 3: 'game end', 4: 'room start', 5: 'room end',
                 6: 'no more lives', 7: 'animation end', 8: 'end of path', 9: 'no more health'}
        return other.get(en, f'user event {en - 10}' if 10 <= en < 26 else f'other {en}')
    return {0: 'create', 1: 'destroy'}.get(et, f'{EVENT_NAMES.get(et, et)} {en}')


FILE_MARK = '\x00file:'   # in Conversion.js: the following lines belong to this source file (eject)


def _js_bool(v):
    return 'true' if v else 'false'


class Conversion:
    """Holds the results of translating one project (used by both convert() and the report)."""

    def __init__(self, g, source_name, keep_comments=False):
        self.g = g
        self.keep_comments = keep_comments   # eject: carry GML comments over, and mark file boundaries
        self.errors = []
        self.dnd_actions = {}          # function name / id -> count
        resources = {r['name']: r['index'] for kind in RESOURCE_KINDS for r in g[kind] if r}
        self.ctx = Context(resources, [s['name'] for s in g['scripts'] if s], g['constants'].keys())
        sources = [s['code'] for s in g['scripts'] if s]
        for o in g['objects']:
            if o:
                for _, _, acts in o['events']:
                    sources += [a['args'][0] for a in acts if a['kind'] == 7 and a['args']]
        prescan_globalvars(self.ctx, sources)
        self.js = self._generate(source_name)

    def _tr(self, code, is_script, ind, where):
        try:
            return translate(self.ctx, code, is_script, ind, self.keep_comments)
        except ParseError as e:
            self.errors.append(f'{where}: {e}')
            msg = json.dumps(f'{where} failed to translate: {e}')
            return '    ' * ind + f'throw new Error({msg});\n', -1, False

    # ---- drag & drop actions -------------------------------------------------------------------
    # Action argument kinds: 0 expression, 1 string, 2 string or expression, 3 boolean, 4 menu,
    # 5 sprite, 6 sound, 7 background, 8 path, 9 script, 10 object, 11 room, 12 font, 13 colour,
    # 14 timeline, 15 font string
    def _arg(self, kind, val, where):
        if kind == 0 or (kind == 2 and val.strip()[:1] in ('"', "'")):
            try:
                return translate_expr(self.ctx, val if val.strip() else '0')
            except ParseError as e:
                self.errors.append(f'{where}: action argument {val!r}: {e}')
                return '0'
        if kind in (1, 2, 15):
            return json.dumps(val)
        try:
            return str(int(float(val or 0)))
        except ValueError:
            return json.dumps(val)

    def _call(self, a, where):
        n = a['argc']
        args = [self._arg(k, v, where) for k, v in zip(a['argkinds'][:n], a['args'][:n])]
        args = ['self'] + args + (['true' if a['relative'] else 'false'] if a['relative_allowed'] else [])
        self.ctx.used_builtins.add(a['func'])
        return f'B.{a["func"]}({", ".join(args)})'

    def _wrap_applies(self, a, js, pad):
        """Run js for the action's 'applies to' target (self, other or every instance of an object)."""
        if a['applies'] == -1:
            return js
        target = 'other.id' if a['applies'] == -2 else str(a['applies'])
        inner = ''.join('    ' + line + '\n' for line in js.rstrip('\n').split('\n'))
        return (f'{pad}{{ const __a = B.with({target}, self, other);\n{pad}for (const [self, other] of __a) {{\n'
                + inner + f'{pad}}} }}\n')

    def _action_block(self, acts, i, where, ind):
        """Translate the action at acts[i] (plus any block/else that belongs to it). Returns (js, next_i)."""
        pad = '    ' * ind
        a = acts[i]
        k = a['kind']
        if k == 7:                                   # code
            body, _, _ = self._tr(a['args'][0] if a['args'] else '', False, ind + 1, where)
            js = f'{pad}(function () {{\n{body}{pad}}})();\n'
            return self._wrap_applies(a, js, pad), i + 1
        if k == 1:                                   # start of block
            out, i = [], i + 1
            while i < len(acts) and acts[i]['kind'] != 2:
                js, i = self._action_block(acts, i, where, ind + 1)
                out.append(js)
            return f'{pad}{{\n' + ''.join(out) + f'{pad}}}\n', i + 1
        if k in (2, 8, 9, 10):                       # stray end of block, placeholder, separator, label
            return '', i + 1
        if k == 3:                                   # else without an if: ignore
            return '', i + 1
        if k == 4:                                   # exit event
            return f'{pad}return;\n', i + 1
        if k == 5:                                   # repeat next action/block
            n = self._arg(0, a['args'][0] if a['args'] else '1', where)
            body, j = self._action_block(acts, i + 1, where, ind + 1) if i + 1 < len(acts) else ('', i + 1)
            t = f'__r{i}'
            return f'{pad}for (let {t} = Math.round({n}); {t} > 0; {t}--) {{\n{body}{pad}}}\n', j
        if k == 6:                                   # set variable
            name, val = (a['args'] + ['', ''])[:2]
            code = f'{name} {"+=" if a["relative"] else "="} {val or 0}'
            body, _, _ = self._tr(code, False, ind, where)
            return self._wrap_applies(a, body, pad), i + 1
        if k == 0 and a['exec'] == 1 and a['func']:  # library function
            call = self._call(a, where)
            if not a['question']:
                return self._wrap_applies(a, f'{pad}{call};\n', pad), i + 1
            if a['applies'] != -1:
                target = 'other.id' if a['applies'] == -2 else str(a['applies'])
                call = f'B.withAll({target}, self, other, (self, other) => {call})'
            cond = f'!B.T({call})' if a['not'] else f'B.T({call})'
            then, j = self._action_block(acts, i + 1, where, ind + 1) if i + 1 < len(acts) else ('', i + 1)
            js = f'{pad}if ({cond}) {{\n{then}{pad}}}'
            if j < len(acts) and acts[j]['kind'] == 3:
                els, j = self._action_block(acts, j + 1, where, ind + 1) if j + 1 < len(acts) else ('', j + 1)
                js += f' else {{\n{els}{pad}}}'
            return js + '\n', j
        name = a['func'] or f'action {a["lib"]}/{a["id"]}'
        self.dnd_actions[name] = self.dnd_actions.get(name, 0) + 1
        return f'{pad}// TODO: drag & drop action not converted: {name}\n', i + 1

    def _actions(self, acts, where):
        if len(acts) == 1 and acts[0]['kind'] == 7 and acts[0]['applies'] == -1:
            body, _, _ = self._tr(acts[0]['args'][0], False, 3, where)   # the common case: one code action
            return body
        out, i = [], 0
        while i < len(acts):
            js, i = self._action_block(acts, i, where, 3)
            out.append(js)
        return ''.join(out)

    def _generate(self, source_name):
        g = self.g
        js = [f'// Generated by gm-revive from {source_name}.',
              '// GML translated to JavaScript; the GameMaker API itself lives in runtime.js.',
              '"use strict";', '', '// ---- Resource indices']
        for kind in RESOURCE_KINDS:
            items = [r for r in g[kind] if r]
            if items:
                js.append(f'// {kind}')
                if self.keep_comments:   # eject: one per line, so adding a resource is a one-line change
                    js.append('const ' + ',\n    '.join(f'{r["name"]} = {r["index"]}' for r in items) + ';')
                else:
                    js.append('const ' + ', '.join(f'{r["name"]} = {r["index"]}' for r in items) + ';')

        js += ['', '// ---- User-defined constants', 'const K = {};', 'function __init_constants(self, other) {']
        for k, v in g['constants'].items():
            try:
                body, _, _ = translate(self.ctx, f'__c = {v};', True, 1)
                js.append(f'    K.{k} = {body.strip().split("=", 1)[1].strip().rstrip(";")};')
            except ParseError as e:
                self.errors.append(f'constant {k}: {e}')
                js.append(f'    K.{k} = 0; // could not translate: {v}')
        js += ['}', '', '// ---- Scripts', 'const S = {};']

        for s in g['scripts']:
            if not s:
                continue
            js.append(FILE_MARK + f'scripts/{s["name"]}.js')
            body, max_arg, uses_arr = self._tr(s['code'], True, 1, f'script {s["name"]}')
            nargs = max(max_arg + 1, 16 if uses_arr else 0)
            params = ['self', 'other'] + [f'argument{i} = 0' for i in range(nargs)]
            pre = ''
            if uses_arr:
                pre = ('    const argument = [' + ', '.join(f'argument{i}' for i in range(16)) + '];\n'
                       '    const argument_count = arguments.length - 2;\n')
            js.append(f'S.{s["name"]} = function {s["name"]}({", ".join(params)}) {{')
            js.append(pre + body + '    return 0;')
            js.append('};')
        js.append(FILE_MARK + 'world.js')
        js.append('const SCRIPT_LIST = [' + ', '.join(f'S.{x["name"]}' if x else 'null' for x in g['scripts']) + '];')

        def rname(kind, idx):
            # eject writes resources by name (spr_x, obj_y) so the source reads well; convert keeps numbers
            if self.keep_comments and isinstance(idx, int) and 0 <= idx < len(g[kind]) and g[kind][idx]:
                return g[kind][idx]['name']
            return idx
        js += ['', '// ---- Objects', f'const OBJECTS = new Array({len(g["objects"])}).fill(null);']
        for o in g['objects']:
            if not o:
                continue
            js.append(FILE_MARK + f'objects/{o["name"]}.js')
            js.append(f'OBJECTS[{rname("objects", o["index"])}] = {{')
            js.append(f'    name: "{o["name"]}", sprite: {rname("sprites", o["sprite"])}, visible: {_js_bool(o["visible"])}, '
                      f'solid: {_js_bool(o["solid"])}, depth: {o["depth"]}, persistent: {_js_bool(o["persistent"])}, '
                      f'parent: {rname("objects", o["parent"])}, mask: {rname("sprites", o["mask"])},')
            js.append('    events: {')
            for et, en, acts in o['events']:
                key = f'{EVENT_NAMES[et]}_{en}'
                label = key
                if et == 4 and 0 <= en < len(g['objects']) and g['objects'][en]:
                    label = f'collision with {g["objects"][en]["name"]}'
                elif self.keep_comments:
                    label = event_label(et, en)
                js.append(f'        // {label}')
                js.append(f'        "{key}": function (self, other) {{\n'
                          + self._actions(acts, f'{o["name"]} {key}') + '        },')
            js.append('    },')
            js.append('};')

        js.append(FILE_MARK + 'world.js')
        js += ['', '// ---- Timelines', 'const TIMELINES = [];']
        for t in g['timelines']:
            if not t:
                js.append('TIMELINES.push(null);')
                continue
            js.append(f'TIMELINES[{t["index"]}] = {{ name: "{t["name"]}", moments: {{')
            for step, acts in t['moments']:
                js.append(f'    {step}: function (self, other) {{\n'
                          + self._actions(acts, f'timeline {t["name"]} step {step}') + '    },')
            js.append('}};')

        js += ['', '// ---- Paths', 'const PATHS = ' + json.dumps(
            [p and {'name': p['name'], 'closed': p['closed'], 'smooth': p['smooth'],
                    'points': [{'x': x, 'y': y, 'sp': sp} for x, y, sp in p['points']]} for p in g['paths']]) + ';']

        js += ['', '// ---- Rooms']
        rooms = []
        for rm in g['rooms']:
            if not rm:
                rooms.append('null')
                continue
            inst = []
            for i in rm['instances']:
                code = 'null'
                if i['code'].strip():
                    body, _, _ = self._tr(i['code'], False, 2, f'{rm["name"]} instance {i["id"]} creation code')
                    code = 'function (self, other) {\n' + body + '    }'
                inst.append(f'{{ x: {i["x"]}, y: {i["y"]}, object: {i["object"]}, id: {i["id"]}, code: {code} }}')
            rcode = 'null'
            if rm['code'].strip():
                body, _, _ = self._tr(rm['code'], False, 2, f'{rm["name"]} creation code')
                rcode = 'function (self, other) {\n' + body + '    }'
            rooms.append(
                f'{{ name: "{rm["name"]}", caption: {json.dumps(rm["caption"])}, width: {rm["width"]}, '
                f'height: {rm["height"]}, speed: {rm["speed"]}, persistent: {_js_bool(rm["persistent"])}, '
                f'color: {rm["color"]}, draw_color: {_js_bool(rm["draw_color"])}, '
                f'views_enabled: {_js_bool(rm["views_enabled"])},\n  views: {json.dumps(rm["views"])},\n'
                f'  backgrounds: {json.dumps(rm["backgrounds"])},\n  tiles: {json.dumps(rm["tiles"])},\n'
                f'  code: {rcode},\n  instances: [\n    ' + ',\n    '.join(inst) + ']}')
        js.append('const ROOMS = [\n' + ',\n'.join(rooms) + '];')
        js.append('const ROOM_ORDER = ' + json.dumps(g.get('room_order') or [r['index'] for r in g['rooms'] if r]) + ';')
        return js


def convert(gmk_path, out_dir, extra_dir=None, soundfont=None, log=print, overrides=None, keep_comments=False):
    """Convert gmk_path into an HTML5 build in out_dir. Returns the Conversion."""
    g = load(gmk_path)
    from . import overrides as ov
    folder = overrides if overrides is not None else ov.default_dir(gmk_path)
    g['overrides_applied'] = ov.apply(g, folder) if folder else []   # folder=False disables overrides
    for c in g['overrides_applied']:
        log(f'  override: {c}')
    conv = Conversion(g, os.path.basename(gmk_path), keep_comments=keep_comments)
    js = [l for l in conv.js if not l.startswith(FILE_MARK)]
    for sub in ('sprites', 'backgrounds', 'sounds'):
        os.makedirs(os.path.join(out_dir, 'assets', sub), exist_ok=True)

    meta = {'sprites': [], 'backgrounds': [], 'sounds': [], 'fonts': []}
    for sp in g['sprites']:
        if not sp:
            meta['sprites'].append(None)
            continue
        frames = []
        for fi, (w, h, raw) in enumerate(sp['frames']):
            fn = f'assets/sprites/{sp["name"]}_{fi}.png'
            if w:
                with open(os.path.join(out_dir, fn), 'wb') as fh:
                    fh.write(png_from_bgra(w, h, raw))
            frames.append(fn if w else None)
        w, h = (sp['frames'][0][0], sp['frames'][0][1]) if sp['frames'] else (0, 0)
        left, right, bottom, top = sp['bbox']
        meta['sprites'].append({'name': sp['name'], 'frames': frames, 'width': w, 'height': h,
                                'xoffset': sp['ox'], 'yoffset': sp['oy'], 'shape': sp['shape'],
                                'bbox': {'left': left, 'right': right, 'top': top, 'bottom': bottom}})
    for bg in g['backgrounds']:
        if not bg:
            meta['backgrounds'].append(None)
            continue
        w, h, raw = bg['image']
        fn = f'assets/backgrounds/{bg["name"]}.png'
        if w:
            with open(os.path.join(out_dir, fn), 'wb') as fh:
                fh.write(png_from_bgra(w, h, raw))
        meta['backgrounds'].append({'name': bg['name'], 'file': fn if w else None, 'width': w, 'height': h})

    sf = find_soundfont(soundfont)
    midi_warned = False
    for sn in g['sounds']:
        if not sn:
            meta['sounds'].append(None)
            continue
        fn = play = None
        if sn['data']:
            fn = f'assets/sounds/{sn["name"]}{sn["ext"]}'
            with open(os.path.join(out_dir, fn), 'wb') as fh:
                fh.write(sn['data'])
            play = fn
            if sn['ext'].lower() in ('.mid', '.midi'):
                mp3 = midi_to_mp3(os.path.join(out_dir, fn), sf, log)
                play = os.path.relpath(mp3, out_dir).replace(os.sep, '/') if mp3 else None
                if not mp3 and not midi_warned:
                    log('  warning: MIDI music needs fluidsynth, ffmpeg and a General MIDI soundfont '
                        '(--soundfont or GM_REVIVE_SOUNDFONT); MIDI tracks will be silent')
                    midi_warned = True
        meta['sounds'].append({'name': sn['name'], 'file': fn, 'play_file': play, 'kind': sn['kind'],
                               'ext': sn['ext'], 'volume': sn['volume'], 'pan': sn['pan']})
    for fo in g['fonts']:
        meta['fonts'].append(fo and {k: fo[k] for k in ('name', 'font', 'size', 'bold', 'italic')})
    js.append('const ASSETS = ' + json.dumps(meta, indent=1) + ';')
    conv.meta = meta

    extra = []
    if extra_dir:
        os.makedirs(os.path.join(out_dir, 'files'), exist_ok=True)
        for f in sorted(os.listdir(extra_dir)):
            if f.lower().endswith(EXTRA_FILE_TYPES) and os.path.isfile(os.path.join(extra_dir, f)):
                shutil.copy(os.path.join(extra_dir, f), os.path.join(out_dir, 'files', f))
                extra.append(f)
    js.append('const EXTRA_FILES = ' + json.dumps(extra) + ';')
    conv.extra = extra
    with open(os.path.join(out_dir, 'game.js'), 'w', encoding='utf-8') as fh:
        fh.write('\n'.join(js) + '\n')

    # Images are also embedded as data: URIs so index.html works straight from disk (file:// images
    # would taint the canvas and break the pixel-reading functions such as sprite_set_alpha_from_sprite).
    imgs = {}
    for root in ('assets/sprites', 'assets/backgrounds', 'files'):
        d = os.path.join(out_dir, root)
        if os.path.isdir(d):
            for f in sorted(os.listdir(d)):
                if f.lower().endswith('.png'):
                    with open(os.path.join(d, f), 'rb') as fh:
                        imgs[f'{root}/{f}'] = 'data:image/png;base64,' + base64.b64encode(fh.read()).decode()
    with open(os.path.join(out_dir, 'images.js'), 'w', encoding='utf-8') as fh:
        fh.write('// Embedded image data (generated by gm-revive)\nconst IMAGE_DATA = ' + json.dumps(imgs) + ';\n')

    title = os.path.splitext(os.path.basename(gmk_path))[0]
    with open(os.path.join(RUNTIME_DIR, 'index_template.html'), encoding='utf-8') as fh:
        tpl = fh.read()
    tpl = tpl.replace('{{TITLE}}', title).replace('{{INFO}}', rtf_to_html(g['game_info_rtf']))
    with open(os.path.join(out_dir, 'index.html'), 'w', encoding='utf-8') as fh:
        fh.write(tpl)
    shutil.copy(os.path.join(RUNTIME_DIR, 'runtime.js'), os.path.join(out_dir, 'runtime.js'))
    return conv
