"""Tests for GML overrides."""
import os
import tempfile
import unittest

from gm_revive import overrides as ov


def project():
    obj = {'name': 'obj_hero', 'index': 0, 'sprite': -1, 'visible': True, 'solid': False, 'depth': 0,
           'persistent': False, 'parent': -1, 'mask': -1, 'events': [(0, 0, [ov.code_action('hp = 1;')])]}
    return {'objects': [obj], 'scripts': [{'name': 'scr_old', 'index': 0, 'code': 'return 1;'}]}


class OverrideTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        d = self.tmp.name
        os.makedirs(os.path.join(d, 'objects', 'obj_hero'))
        os.makedirs(os.path.join(d, 'scripts'))
        for path, code in [('objects/obj_hero/create.gml', 'hp = 99;'), ('objects/obj_hero/step_end.gml', 'x += 1;'),
                           ('objects/obj_hero/user3.gml', 'y = 2;'), ('objects/obj_hero/alarm0.gml', 'z = 3;'),
                           ('scripts/scr_old.gml', 'return 2;'), ('scripts/scr_new.gml', 'return 3;')]:
            with open(os.path.join(d, path), 'w') as fh:
                fh.write(code)

    def tearDown(self):
        self.tmp.cleanup()

    def test_events_and_scripts_are_replaced_and_added(self):
        g = project()
        changes = ov.apply(g, self.tmp.name)
        events = {(t, n): acts[0]['args'][0] for t, n, acts in g['objects'][0]['events']}
        self.assertEqual(events[(0, 0)], 'hp = 99;')
        self.assertEqual(events[(3, 2)], 'x += 1;')
        self.assertEqual(events[(7, 13)], 'y = 2;')
        self.assertEqual(events[(2, 0)], 'z = 3;')
        scripts = {s['name']: s for s in g['scripts']}
        self.assertEqual(scripts['scr_old']['code'], 'return 2;')
        self.assertEqual(scripts['scr_new']['index'], 1)
        self.assertIn('obj_hero create (replaced)', changes)
        self.assertIn('script scr_new (added)', changes)

    def test_unknown_object_is_an_error(self):
        os.makedirs(os.path.join(self.tmp.name, 'objects', 'obj_missing'))
        with self.assertRaises(ov.OverrideError):
            ov.apply(project(), self.tmp.name)

    def test_event_names(self):
        self.assertEqual(ov.parse_event_name('step_begin'), (3, 1))
        self.assertEqual(ov.parse_event_name('keypress_32'), (9, 32))
        self.assertEqual(ov.parse_event_name('alarm_11'), (2, 11))
        with self.assertRaises(ov.OverrideError):
            ov.parse_event_name('jump')


if __name__ == '__main__':
    unittest.main()


class NewObjectTests(unittest.TestCase):
    def make(self, files):
        self.tmp = tempfile.TemporaryDirectory()
        for path, text in files.items():
            full = os.path.join(self.tmp.name, path)
            os.makedirs(os.path.dirname(full), exist_ok=True)
            with open(full, 'w') as fh:
                fh.write(text)
        return self.tmp.name

    def tearDown(self):
        if hasattr(self, 'tmp'):
            self.tmp.cleanup()

    def proj(self):
        g = project()
        g['sprites'] = [{'name': 'spr_boss', 'index': 0}]
        return g

    def test_new_object_with_parent_sprite_and_events(self):
        d = self.make({'objects/obj_boss_new/object.json': '{"sprite": "spr_boss", "parent": "obj_hero", "depth": -5}',
                       'objects/obj_boss_new/create.gml': 'event_inherited(); hp = 5000;',
                       'objects/obj_minion/object.json': '{"parent": "obj_boss_new", "visible": false}'})
        g = self.proj()
        changes = ov.apply(g, d)
        new = {o['name']: o for o in g['objects']}
        boss, minion = new['obj_boss_new'], new['obj_minion']
        self.assertEqual((boss['index'], boss['sprite'], boss['parent'], boss['depth']), (1, 0, 0, -5))
        self.assertEqual(boss['events'][0][:2], (0, 0))
        self.assertEqual((minion['parent'], minion['visible'], minion['sprite']), (boss['index'], False, -1))
        self.assertIn('obj_boss_new (new object)', changes)

    def test_object_json_changes_an_existing_object(self):
        d = self.make({'objects/obj_hero/object.json': '{"sprite": "spr_boss", "solid": true}'})
        g = self.proj()
        ov.apply(g, d)
        self.assertEqual((g['objects'][0]['sprite'], g['objects'][0]['solid']), (0, True))

    def test_new_object_errors(self):
        for files, msg in [({'objects/obj_x/create.gml': 'a = 1;'}, 'object.json'),
                           ({'objects/obj_x/object.json': '{"sprit": "spr_boss"}'}, 'unknown keys'),
                           ({'objects/obj_x/object.json': '{"sprite": "spr_nope"}'}, "no sprite called 'spr_nope'"),
                           ({'objects/obj_x/object.json': '{"parent": "obj_y"}', 'objects/obj_y/object.json': '{"parent": "obj_x"}'}, 'loop'),
                           ({'objects/obj_x/object.json': '[1]'}, 'JSON object')]:
            d = self.make(files)
            with self.assertRaises(ov.OverrideError) as cm:
                ov.apply(self.proj(), d)
            self.assertIn(msg, str(cm.exception))
            self.tmp.cleanup(); del self.tmp
