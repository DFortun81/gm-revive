"""Tests for drag & drop action translation."""
import unittest

from gm_revive.build import Conversion


def action(kind=0, func='', args=(), argkinds=(), question=False, negate=False, relative=False,
           relative_allowed=False, applies=-1, exec_=1):
    return {'lib': 1, 'id': 0, 'kind': kind, 'relative_allowed': relative_allowed, 'question': question,
            'applies_allowed': True, 'exec': exec_, 'func': func, 'code': '', 'argc': len(args),
            'argkinds': list(argkinds), 'applies': applies, 'relative': relative, 'args': list(args), 'not': negate}


def project(actions):
    empty = {k: [] for k in ('sounds', 'sprites', 'backgrounds', 'paths', 'scripts', 'fonts', 'timelines', 'rooms')}
    obj = {'name': 'obj_test', 'index': 0, 'sprite': -1, 'visible': True, 'solid': False, 'depth': 0,
           'persistent': False, 'parent': -1, 'mask': -1, 'events': [(3, 0, actions)]}
    return dict(empty, objects=[obj], constants={}, extensions=[], game_info_rtf='', room_order=[])


def translate_event(actions):
    conv = Conversion(project(actions), 'test')
    js = '\n'.join(conv.js)
    return js[js.index('"step_0"'):], conv


class ActionTests(unittest.TestCase):
    def test_question_with_block_and_else(self):
        acts = [
            action(func='action_if_dice', args=['3'], argkinds=[0], question=True),
            action(kind=1),
            action(func='action_sound', args=['2', '0'], argkinds=[6, 3]),
            action(kind=6, args=['hits', '1'], relative=True),
            action(kind=2),
            action(kind=3),
            action(func='action_kill_object'),
        ]
        js, conv = translate_event(acts)
        self.assertIn('if (B.T(B.action_if_dice(self, 3)))', js)
        self.assertIn('B.action_sound(self, 2, 0);', js)
        self.assertIn('self.hits += 1;', js)
        self.assertIn('} else {', js)
        self.assertIn('B.action_kill_object(self);', js)
        self.assertEqual(conv.dnd_actions, {})

    def test_not_relative_and_applies_to(self):
        acts = [
            action(func='action_if_number', args=['0', '2', '0'], argkinds=[10, 0, 4], question=True, negate=True),
            action(func='action_move_to', args=['x + 4', '0'], argkinds=[0, 0], relative=True, relative_allowed=True,
                   applies=-2),
        ]
        js, _ = translate_event(acts)
        self.assertIn('if (!B.T(B.action_if_number(self, 0, 2, 0)))', js)
        self.assertIn('B.with(other.id, self, other)', js)
        self.assertIn('B.action_move_to(self, (self.x + 4), 0, true);', js)

    def test_repeat_and_exit(self):
        acts = [action(kind=5, args=['3']), action(func='action_set_score', args=['1'], argkinds=[0],
                                                     relative=True, relative_allowed=True), action(kind=4)]
        js, _ = translate_event(acts)
        self.assertIn('Math.round(3); __r0 > 0; __r0--', js)
        self.assertIn('B.action_set_score(self, 1, true);', js)
        self.assertIn('return;', js)


if __name__ == '__main__':
    unittest.main()
