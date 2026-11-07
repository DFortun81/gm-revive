"""GML overrides: replace or add object events and scripts at build time without touching the project file.

Layout (default folder: <project name>.overrides next to the project file):

    scripts/<script_name>.gml               replaces that script, or adds a new one
    objects/<object_name>/<event>.gml       replaces that event's actions with this code, or adds the event
    objects/<object_name>/object.json       creates the object if the project doesn't have it (required then),
                                            or changes an existing object's properties
    sprites/<sprite_name>.png               replaces that sprite's images, or adds a new sprite
    sprites/<sprite_name>.json              (optional) how to cut the PNG into frames, see below
    sounds/<sound_name>.wav|.mp3|.ogg|.mid  replaces that sound, or adds a new one
    sounds/<sound_name>.json                (optional) {"kind": 0 sound effect / 1 music, "volume": 0-1}

object.json keys (all optional; names refer to resources in the project or to other new objects):
    {"sprite": "spr_name", "parent": "obj_name", "mask": "spr_name", "depth": 0,
     "visible": true, "solid": false, "persistent": false}
A new object without "sprite" has none; "parent" and "mask" can be null.

Sprite .json keys (all optional):
    {"columns": 4, "rows": 4,            the PNG is a sheet of columns x rows frames, read row by row
     "frames": 16,                       how many of those cells to use (default: all)
     "origin": [20, 52],                 [x, y], or "top-left" (default), "center", "bottom-center"
     "transparent": "#ff00ff"}           a colour to make see-through, or "top-left" (that pixel's colour)
An RPG Maker character sheet (4 x 4, rows facing down, left, right, up) gives a GameMaker sprite with
the same 16 frames in the same order. The bounding box is worked out from the visible pixels.

Event file names: create, destroy, step, step_begin, step_end, draw, alarm0..alarm11, user0..user15,
room_start, room_end, game_start, game_end, animation_end, end_of_path, outside, boundary,
or the raw form <type>_<number> used in game.js (e.g. keypress_32, mouse_53, collision_4).
Lines starting with // in an override are kept as comments; nothing else is special.
"""
import json
import os
import re

from . import png

EVENT_TYPES = {'create': 0, 'destroy': 1, 'alarm': 2, 'step': 3, 'collision': 4, 'keyboard': 5, 'mouse': 6,
               'other': 7, 'draw': 8, 'keypress': 9, 'keyrelease': 10, 'trigger': 11}
ALIASES = {'create': (0, 0), 'destroy': (1, 0), 'step': (3, 0), 'step_begin': (3, 1), 'step_end': (3, 2),
           'draw': (8, 0), 'outside': (7, 0), 'boundary': (7, 1), 'game_start': (7, 2), 'game_end': (7, 3),
           'room_start': (7, 4), 'room_end': (7, 5), 'animation_end': (7, 7), 'end_of_path': (7, 8)}


class OverrideError(Exception):
    pass


def default_dir(project_path):
    d = os.path.splitext(os.path.abspath(project_path))[0] + '.overrides'
    return d if os.path.isdir(d) else None


def parse_event_name(name):
    name = name.lower()
    if name in ALIASES:
        return ALIASES[name]
    m = re.fullmatch(r'alarm_?(\d+)', name)
    if m and name != 'alarm':
        return 2, int(m.group(1))
    m = re.fullmatch(r'user_?(\d+)', name)
    if m:
        return 7, 10 + int(m.group(1))
    m = re.fullmatch(r'([a-z]+)_(\d+)', name)
    if m and m.group(1) in EVENT_TYPES:
        return EVENT_TYPES[m.group(1)], int(m.group(2))
    raise OverrideError(f'unknown event name {name!r}')


def code_action(code):
    return {'lib': 1, 'id': 603, 'kind': 7, 'relative_allowed': False, 'question': False, 'applies_allowed': True,
            'exec': 2, 'func': '', 'code': '', 'argc': 1, 'argkinds': [1], 'applies': -1, 'relative': False,
            'args': [code], 'not': False}


def apply(g, folder):
    """Apply the overrides in folder to the loaded project g. Returns a list of human-readable changes."""
    changes = []
    sdir = os.path.join(folder, 'scripts')
    if os.path.isdir(sdir):
        by_name = {s['name']: s for s in g['scripts'] if s}
        for f in sorted(os.listdir(sdir)):
            if not f.lower().endswith('.gml'):
                continue
            name = f[:-4]
            with open(os.path.join(sdir, f), encoding='utf-8') as fh:
                code = fh.read()
            if name in by_name:
                by_name[name]['code'] = code
                changes.append(f'script {name} (replaced)')
            else:
                g['scripts'].append({'name': name, 'index': len(g['scripts']), 'code': code})
                changes.append(f'script {name} (added)')
    spdir = os.path.join(folder, 'sprites')
    if os.path.isdir(spdir):
        changes += _apply_sprites(g, spdir)
    sndir = os.path.join(folder, 'sounds')
    if os.path.isdir(sndir):
        changes += _apply_sounds(g, sndir)
    odir = os.path.join(folder, 'objects')
    if os.path.isdir(odir):
        objects = {o['name']: o for o in g['objects'] if o}
        changes += _apply_object_files(g, odir, objects)
        for oname in sorted(os.listdir(odir)):
            path = os.path.join(odir, oname)
            if not os.path.isdir(path):
                continue
            obj = objects[oname]
            for f in sorted(os.listdir(path)):
                if not f.lower().endswith('.gml'):
                    continue
                et, en = parse_event_name(f[:-4])
                with open(os.path.join(path, f), encoding='utf-8') as fh:
                    code = fh.read()
                for k, (t, n, _) in enumerate(obj['events']):
                    if (t, n) == (et, en):
                        obj['events'][k] = (et, en, [code_action(code)])
                        changes.append(f'{oname} {f[:-4]} (replaced)')
                        break
                else:
                    obj['events'].append((et, en, [code_action(code)]))
                    changes.append(f'{oname} {f[:-4]} (added)')
    return changes


OBJECT_KEYS = {'sprite', 'parent', 'mask', 'depth', 'visible', 'solid', 'persistent'}


def _apply_object_files(g, odir, objects):
    """Create new objects and apply object.json properties. New objects are all created before any
    properties are resolved, so a new object can be the parent of another new one."""
    changes = []
    folders = [f for f in sorted(os.listdir(odir)) if os.path.isdir(os.path.join(odir, f))]
    props = {}
    for oname in folders:
        jpath = os.path.join(odir, oname, 'object.json')
        if os.path.isfile(jpath):
            try:
                with open(jpath, encoding='utf-8') as fh:
                    props[oname] = json.load(fh)
            except ValueError as e:
                raise OverrideError(f'overrides: {oname}/object.json is not valid JSON: {e}')
            if not isinstance(props[oname], dict):
                raise OverrideError(f'overrides: {oname}/object.json must be a JSON object')
            bad = set(props[oname]) - OBJECT_KEYS
            if bad:
                raise OverrideError(f'overrides: {oname}/object.json: unknown keys {sorted(bad)} (allowed: {sorted(OBJECT_KEYS)})')
        if oname not in objects:
            if oname not in props:
                raise OverrideError(f'overrides: there is no object called {oname!r} in the project '
                                    f'(add {oname}/object.json to create it)')
            if not re.fullmatch(r'[A-Za-z_][A-Za-z0-9_]*', oname):
                raise OverrideError(f'overrides: {oname!r} is not a valid object name')
            obj = {'name': oname, 'index': len(g['objects']), 'sprite': -1, 'solid': False, 'visible': True,
                   'depth': 0, 'persistent': False, 'parent': -1, 'mask': -1, 'events': []}
            g['objects'].append(obj)
            objects[oname] = obj
            changes.append(f'{oname} (new object)')

    sprites = {s['name']: s['index'] for s in g.get('sprites', []) if s}

    def resource(oname, key, value, table, kind):
        if value is None:
            return -1
        if value not in table:
            raise OverrideError(f'overrides: {oname}/object.json: no {kind} called {value!r}')
        return table[value]

    for oname, p in props.items():
        obj = objects[oname]
        if 'sprite' in p:
            obj['sprite'] = resource(oname, 'sprite', p['sprite'], sprites, 'sprite')
        if 'mask' in p:
            obj['mask'] = resource(oname, 'mask', p['mask'], sprites, 'sprite')
        if 'parent' in p:
            obj['parent'] = resource(oname, 'parent', p['parent'], {k: v['index'] for k, v in objects.items()}, 'object')
            # refuse inheritance loops
            seen, cur = {obj['index']}, obj['parent']
            while cur >= 0:
                if cur in seen:
                    raise OverrideError(f'overrides: {oname}/object.json: parent {p["parent"]!r} makes an inheritance loop')
                seen.add(cur)
                cur = g['objects'][cur]['parent']
        for key in ('depth',):
            if key in p:
                obj[key] = int(p[key])
        for key in ('visible', 'solid', 'persistent'):
            if key in p:
                obj[key] = bool(p[key])
        if f'{oname} (new object)' not in changes:
            changes.append(f'{oname} properties (object.json)')
    return changes


SPRITE_KEYS = {'columns', 'rows', 'frames', 'origin', 'transparent'}


def _apply_sprites(g, spdir):
    changes = []
    g.setdefault('sprites', [])
    by_name = {sp['name']: sp for sp in g['sprites'] if sp}
    for f in sorted(os.listdir(spdir)):
        if not f.lower().endswith('.png'):
            continue
        name = f[:-4]
        if not re.fullmatch(r'[A-Za-z_][A-Za-z0-9_]*', name):
            raise OverrideError(f'overrides: {f!r}: sprite names must be valid identifiers')
        opts = {}
        jpath = os.path.join(spdir, name + '.json')
        if os.path.isfile(jpath):
            try:
                with open(jpath, encoding='utf-8') as fh:
                    opts = json.load(fh)
            except ValueError as e:
                raise OverrideError(f'overrides: sprites/{name}.json is not valid JSON: {e}')
            bad = set(opts) - SPRITE_KEYS
            if bad:
                raise OverrideError(f'overrides: sprites/{name}.json: unknown keys {sorted(bad)} (allowed: {sorted(SPRITE_KEYS)})')
        try:
            w, h, rgba = png.read(os.path.join(spdir, f))
        except (png.PNGError, zlib_error()) as e:
            raise OverrideError(f'overrides: sprites/{f}: {e}')
        cols, rows = int(opts.get('columns', 1)), int(opts.get('rows', 1))
        if cols < 1 or rows < 1 or w % cols or h % rows:
            raise OverrideError(f'overrides: sprites/{f} is {w}x{h}, which does not divide into {cols} x {rows} frames')
        fw, fh = w // cols, h // rows
        count = int(opts.get('frames', cols * rows))
        key = opts.get('transparent')
        if key == 'top-left':
            key = rgba[:3]
        elif isinstance(key, str):
            m = re.fullmatch(r'#?([0-9a-fA-F]{6})', key)
            if not m:
                raise OverrideError(f'overrides: sprites/{name}.json: "transparent" must be "#rrggbb" or "top-left"')
            key = bytes.fromhex(m.group(1))
        elif key is not None:
            raise OverrideError(f'overrides: sprites/{name}.json: "transparent" must be "#rrggbb" or "top-left"')
        frames = []
        left, top, right, bottom = fw, fh, -1, -1
        for k in range(count):
            cx, cy = (k % cols) * fw, (k // cols) * fh
            out = bytearray(fw * fh * 4)
            for y in range(fh):
                for x in range(fw):
                    i = ((cy + y) * w + cx + x) * 4
                    r, gg, b, a = rgba[i:i + 4]
                    if key is not None and bytes((r, gg, b)) == key:
                        a = 0
                    o = (y * fw + x) * 4
                    out[o:o + 4] = bytes((b, gg, r, a))           # GameMaker keeps BGRA
                    if a:
                        left, right, top, bottom = min(left, x), max(right, x), min(top, y), max(bottom, y)
            frames.append((fw, fh, bytes(out)))
        if right < 0:
            left = top = right = bottom = 0
        origin = opts.get('origin', 'top-left')
        if origin == 'top-left':
            ox, oy = 0, 0
        elif origin == 'center':
            ox, oy = fw // 2, fh // 2
        elif origin == 'bottom-center':
            ox, oy = fw // 2, fh - 1
        elif isinstance(origin, list) and len(origin) == 2:
            ox, oy = int(origin[0]), int(origin[1])
        else:
            raise OverrideError(f'overrides: sprites/{name}.json: "origin" must be [x, y], "top-left", "center" or "bottom-center"')
        if name in by_name:
            sp = by_name[name]
            sp.update({'frames': frames, 'ox': ox, 'oy': oy, 'bbox': [left, right, bottom, top]})
            changes.append(f'sprite {name} (replaced, {count} frames of {fw}x{fh})')
        else:
            sp = {'name': name, 'index': len(g['sprites']), 'ox': ox, 'oy': oy, 'frames': frames, 'shape': 1,
                  'tol': 0, 'sepmask': False, 'bboxmode': 0, 'bbox': [left, right, bottom, top]}
            g['sprites'].append(sp)
            by_name[name] = sp
            changes.append(f'sprite {name} (added, {count} frames of {fw}x{fh})')
    return changes


SOUND_TYPES = ('.wav', '.mp3', '.ogg', '.mid', '.midi')
SOUND_KEYS = {'kind', 'volume'}


def _apply_sounds(g, sndir):
    """sounds/<name>.<ext> replaces a sound's data or adds a new sound (a new one is a sound effect unless
    its .json says "kind": 1, background music). MIDI is rendered to MP3 by the build like the game's own."""
    changes = []
    g.setdefault('sounds', [])
    by_name = {s['name']: s for s in g['sounds'] if s}
    for f in sorted(os.listdir(sndir)):
        name, ext = os.path.splitext(f)
        if ext.lower() not in SOUND_TYPES:
            continue
        opts = {}
        jp = os.path.join(sndir, name + '.json')
        if os.path.exists(jp):
            try:
                with open(jp, encoding='utf-8') as fh:
                    opts = json.load(fh)
            except ValueError as e:
                raise OverrideError(f'overrides: sounds/{name}.json is not valid JSON: {e}')
            bad = set(opts) - SOUND_KEYS
            if bad:
                raise OverrideError(f'overrides: sounds/{name}.json: unknown keys {sorted(bad)} (allowed: {sorted(SOUND_KEYS)})')
        with open(os.path.join(sndir, f), 'rb') as fh:
            data = fh.read()
        if name in by_name:
            sn = by_name[name]
            sn.update({'ext': ext.lower(), 'file': f, 'data': data})
            for k in opts:
                sn[k] = opts[k]
            changes.append(f'sound {name} (replaced)')
        else:
            sn = {'name': name, 'index': len(g['sounds']), 'kind': int(opts.get('kind', 0)), 'ext': ext.lower(),
                  'file': f, 'data': data, 'effects': 0, 'volume': float(opts.get('volume', 1)), 'pan': 0.0,
                  'preload': True}
            g['sounds'].append(sn)
            by_name[name] = sn
            changes.append(f'sound {name} (added)')
    return changes


def zlib_error():
    import zlib
    return zlib.error
