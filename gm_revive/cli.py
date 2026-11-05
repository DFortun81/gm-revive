"""Command line interface:  python -m gm_revive {convert,report} ..."""
import argparse
import os
import sys

from . import __version__


def cmd_convert(a):
    from .build import convert
    from .gmk import UnsupportedFormat
    extra = a.files
    if extra is None and not a.no_files:
        extra = os.path.dirname(os.path.abspath(a.project))   # games load extra files from their own folder
    try:
        conv = convert(a.project, a.out, extra_dir=extra, soundfont=a.soundfont)
    except UnsupportedFormat as e:
        print(f'error: {e}', file=sys.stderr)
        return 2
    print(f'Wrote {a.out}{os.sep}index.html')
    if conv.errors:
        print(f'{len(conv.errors)} piece(s) of code could not be translated:')
        for e in conv.errors:
            print('  ', e)
    if conv.dnd_actions:
        print('Drag & drop actions not converted yet: ' +
              ', '.join(f'{k} x{v}' for k, v in sorted(conv.dnd_actions.items())))
    from .report import implemented_builtins
    missing = sorted(conv.ctx.used_builtins - implemented_builtins())
    if missing:
        print('Built-in functions the runtime does not implement yet: ' + ', '.join(missing))
    from .report import implemented_extensions
    exts = [e for e in conv.g['extensions'] if e not in implemented_extensions()]
    if exts:
        print('Uses extension packages with no JS replacement yet: ' + ', '.join(exts))
    return 1 if conv.errors else 0


def cmd_report(a):
    from .report import build_report
    text, results = build_report(a.folder)
    if a.output:
        with open(a.output, 'w', encoding='utf-8') as fh:
            fh.write(text)
        print(f'Wrote {a.output} ({len(results)} projects)')
    else:
        print(text)
    return 0


def main(argv=None):
    p = argparse.ArgumentParser(prog='gm-revive', description='Convert old GameMaker projects to HTML5.')
    p.add_argument('--version', action='version', version=f'gm-revive {__version__}')
    sub = p.add_subparsers(dest='cmd', required=True)

    c = sub.add_parser('convert', help='convert one project into an HTML5 folder')
    c.add_argument('project', help='path to a GameMaker 7 or 8.0 .gmk file')
    c.add_argument('out', help='output folder (created if needed)')
    c.add_argument('--files', help='folder with extra files the game loads at runtime '
                                   '(default: the folder the project is in)')
    c.add_argument('--no-files', action='store_true', help="don't copy any extra files")
    c.add_argument('--soundfont', help='General MIDI .sf2 soundfont used to render MIDI music')
    c.set_defaults(func=cmd_convert)

    r = sub.add_parser('report', help='scan a folder of projects and report what is not supported yet')
    r.add_argument('folder')
    r.add_argument('-o', '--output', help='write the Markdown report to this file')
    r.set_defaults(func=cmd_report)

    a = p.parse_args(argv)
    return a.func(a)
