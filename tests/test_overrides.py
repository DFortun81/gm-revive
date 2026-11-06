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
