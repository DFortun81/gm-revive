"""GML overrides: replace or add object events and scripts at build time without touching the project file.

Layout (default folder: <project name>.overrides next to the project file):

    scripts/<script_name>.gml               replaces that script, or adds a new one
    objects/<object_name>/<event>.gml       replaces that event's actions with this code, or adds the event
    objects/<object_name>/object.json       creates the object if the project doesn't have it (required then),
                                            or changes an existing object's properties

object.json keys (all optional; names refer to resources in the project or to other new objects):
    {"sprite": "spr_name", "parent": "obj_name", "mask": "spr_name", "depth": 0,
     "visible": true, "solid": false, "persistent": false}
A new object without "sprite" has none; "parent" and "mask" can be null.

Event file names: create, destroy, step, step_begin, step_end, draw, alarm0..alarm11, user0..user15,
room_start, room_end, game_start, game_end, animation_end, end_of_path, outside, boundary,
or the raw form <type>_<number> used in game.js (e.g. keypress_32, mouse_53, collision_4).
Lines starting with // in an override are kept as comments; nothing else is special.
"""
import json
import os
import re

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
