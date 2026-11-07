"""Tests for the GML -> JavaScript translator.

Semantic tests run the translated code in Node.js together with the real runtime (skipped if
`node` isn't installed).  Run with:  python -m unittest discover tests
"""
import json
import os
import re
import shutil
import subprocess
import tempfile
import unittest

from gm_revive.gml2js import Context, translate, ParseError

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RUNTIME = os.path.join(ROOT, 'gm_revive', 'runtime', 'runtime.js')
NODE = shutil.which('node')


def tr(code, is_script=True, scripts=(), resources=None, constants=()):
    ctx = Context(resources or {}, scripts, constants)
    body, max_arg, _ = translate(ctx, code, is_script, 1)
    return body, max_arg


def run_script(code, args=()):
    """Translate a GML script, run it in node with the runtime, return its result."""
    body, max_arg = tr(code)
    params = ', '.join(f'argument{i} = 0' for i in range(max(max_arg + 1, len(args))))
    js = (open(RUNTIME, encoding='utf-8').read() +
          '\nconst OBJECTS = [], K = {}, S = {};\n'
          f'function __f(self, other{", " if params else ""}{params}) {{\n{body}    return 0;\n}}\n'
          'const __self = Object.create(B._DUMMY);\n'
          f'console.log(JSON.stringify(__f(__self, __self, ...{json.dumps(list(args))})));\n')
    with tempfile.NamedTemporaryFile('w', suffix='.js', delete=False, encoding='utf-8') as fh:
        fh.write(js)
    try:
        out = subprocess.run([NODE, fh.name], capture_output=True, text=True, timeout=30)
    finally:
        os.unlink(fh.name)
    if out.returncode:
        raise AssertionError(out.stderr)
    return json.loads(out.stdout.strip().splitlines()[-1])


class SyntaxTests(unittest.TestCase):
    def test_begin_end_and_single_equals_comparison(self):
        js, _ = tr('if a = 1 then begin b := 2 end else b = 3')
        self.assertIn('if ((self.a == 1))', js)
        self.assertIn('self.b = 2', js)
        self.assertIn('self.b = 3', js)

    def test_var_is_hoisted_to_function_top(self):
        js, _ = tr('x = 1; var i; i = 2;')
        self.assertTrue(js.lstrip().startswith('let i = 0;'))
        self.assertIn('i = 2;', js)
        self.assertNotIn('self.i', js)

    def test_trailing_semicolon_in_for_header(self):
        js, _ = tr('var j; for(j = 0; j < 3; j += 1;) { x += j }')
        self.assertIn('for (j = 0; (j < 3); j += 1)', js)

    def test_word_operators(self):
        js, _ = tr('return a div 2 + b mod 3 and not c or d xor e;')
        self.assertIn('Math.trunc', js)
        self.assertIn('%', js)
        self.assertIn('!==', js)

    def test_names_are_resolved_by_kind(self):
        js, _ = tr('my_script(obj_player, c_red, CONST, global.score, other.x, room_width)',
                   scripts=['my_script'], resources={'obj_player': 3}, constants=['CONST'])
        self.assertIn('S.my_script(self, other, obj_player, B.c_red, K.CONST, G.score, other.x, B.room_width)', js)

    def test_field_assignment_on_other_instance(self):
        js, _ = tr('target.hp -= 5;')
        self.assertIn('B.setField(self.target, "hp", I(self.target).hp - 5)', js)

    def test_with_rebinds_self_and_other(self):
        js, _ = tr('with (obj_enemy) { hp = other.dmg; }', resources={'obj_enemy': 1})
        self.assertIn('for (const [self, other] of', js)
        self.assertIn('self.hp = other.dmg', js)

    def test_builtin_arrays_without_index_mean_element_zero(self):
        js, _ = tr('view_object = obj; a = view_xview + view_yview[1];', resources={'obj': 2})
        self.assertIn('B.view_object[0] = obj', js)
        self.assertIn('B.view_xview[0] + B.aget(B.view_yview, 1)', js)

    def test_js_reserved_words_are_renamed(self):
        js, _ = tr('var new, class; new = 1; class = new;')
        self.assertIn('l_new', js)
        self.assertIn('l_class = l_new', js)

    def test_parse_error_reported(self):
        with self.assertRaises(ParseError):
            tr('if (a == ) { }')


@unittest.skipUnless(NODE, 'node is not installed')
class SemanticTests(unittest.TestCase):
    def test_arithmetic(self):
        self.assertEqual(run_script('return 7 div 2 + 7 mod 3 + $10;'), 3 + 1 + 16)

    def test_gm_truthiness(self):
        # GameMaker treats values <= 0.5 as false, so negative ids (noone = -4) are false.
        self.assertEqual(run_script('if (-4) return 1; return 0;'), 0)
        self.assertEqual(run_script('if (0.4) return 1; else return 2;'), 2)
        self.assertEqual(run_script('if (0.6) return 1; return 0;'), 1)

    def test_uninitialised_variables_read_as_zero(self):
        self.assertEqual(run_script('return never_set + 1;'), 1)

    def test_repeat_and_do_until(self):
        self.assertEqual(run_script('var n; n = 0; repeat (5) n += 2; do { n += 1 } until (n >= 13); return n;'), 13)

    def test_switch_and_arguments(self):
        code = 'switch (argument0) { case 1: return "one"; case 2: return "two"; default: return "many"; }'
        self.assertEqual(run_script(code, [2]), 'two')
        self.assertEqual(run_script(code, [9]), 'many')

    def test_string_formatting_matches_gm8(self):
        self.assertEqual(run_script('return string(2.8) + "|" + string(3) + "|" + string(true);'), '2.80|3|1')

    def test_mp_grid_path_goes_around_walls(self):
        code = ('var g, p; g = mp_grid_create(0, 0, 5, 5, 32, 32); mp_grid_add_rectangle(g, 64, 0, 95, 127);'
                'p = path_add(); if (!mp_grid_path(g, p, 16, 16, 144, 16, 0)) return -1;'
                'return string(path_get_number(p)) + "," + string(round(path_get_length(p)));')
        self.assertEqual(run_script(code), '13,384')   # 13 cell centres, 12 orthogonal steps of 32px

    def test_mp_grid_path_blocked(self):
        code = ('var g, p; g = mp_grid_create(0, 0, 5, 5, 32, 32); mp_grid_add_rectangle(g, 64, 0, 95, 159);'
                'p = path_add(); return mp_grid_path(g, p, 16, 16, 144, 16, 1);')
        self.assertEqual(run_script(code), False)

    def test_ds_grid_and_map(self):
        code = ('var g, m; g = ds_grid_create(3, 3); ds_grid_set_region(g, 0, 0, 1, 1, 2); ds_grid_add(g, 2, 2, 5);'
                'm = ds_map_create(); ds_map_add(m, "a", 1); ds_map_add(m, "a", 9); ds_map_replace(m, "a", 4);'
                'return ds_grid_get_sum(g, 0, 0, 2, 2) + ds_map_find_value(m, "a");')
        self.assertEqual(run_script(code), 8 + 5 + 4)

    def test_arrays(self):
        self.assertEqual(run_script('a[2] = 5; b[1, 3] = 4; return a[2] + b[1, 3] + a[7];'), 9)


class ExampleBuildTest(unittest.TestCase):
    """Convert the bundled example and check the output is valid and fully covered by the runtime."""

    GMK = os.path.join(ROOT, 'examples', 'battlefield', 'battlefield_3_2_0_2.gmk')

    @unittest.skipUnless(os.path.exists(GMK), 'example project not present')
    def test_battlefield_converts_cleanly(self):
        from gm_revive.build import convert
        from gm_revive.report import implemented_builtins
        with tempfile.TemporaryDirectory() as out:
            conv = convert(self.GMK, out, extra_dir=os.path.dirname(self.GMK), soundfont=False, log=lambda *_: None)
            self.assertEqual(conv.errors, [])
            self.assertEqual(sorted(conv.ctx.used_builtins - implemented_builtins()), [])
            game_js = open(os.path.join(out, 'game.js'), encoding='utf-8').read()
            used = set(re.findall(r'\bB\.(\w+)', game_js))
            self.assertEqual(sorted(used - implemented_builtins() - {'T', 'sw', 'aget', 'setField', 'with',
                                                                     'event_inherited', 'script_execute'}), [])
            if NODE:
                for f in ('game.js', 'runtime.js', 'images.js'):
                    r = subprocess.run([NODE, '--check', os.path.join(out, f)], capture_output=True, text=True)
                    self.assertEqual(r.returncode, 0, r.stderr)


if __name__ == '__main__':
    unittest.main()


def test_variable_local_functions_get_self():
    js, _ = tr('a = variable_local_get("hp"); variable_local_set("hp", 3); b = variable_local_exists("hp");')
    assert 'B.variable_local_get(self, "hp")' in js
    assert 'B.variable_local_set(self, "hp", 3)' in js
    assert 'B.variable_local_exists(self, "hp")' in js


def test_ini_files_round_trip():
    if not NODE:
        return
    # values written before ini_close are there after reopening; missing keys give the default
    assert run_script('''
        ini_open("save.ini"); ini_write_real("stats", "wins", 3); ini_write_string("stats", "name", "Zio"); ini_close();
        ini_open("save.ini");
        r = string(ini_read_real("stats", "wins", 0)) + ini_read_string("stats", "name", "") + string(ini_read_real("stats", "losses", 7));
        r += string(ini_key_exists("stats", "wins")) + string(ini_section_exists("nope"));
        ini_close();
        return r;''') == '3Zio710'


def test_comments_kept_for_eject():
    ctx = Context([], ['foo'], [])
    src = ('// head\n/* two\n   lines */\nvar a; // trailing\na = 1;\n'
           'if(a) {\n    // inside\n    foo();\n}\nswitch(a) {\n    // before case\n    case 1: a = 2; break;\n}\n// end\n')
    js, _, _ = translate(ctx, src, True, 1, keep_comments=True)
    lines = [l.strip() for l in js.splitlines()]
    # the leading comment block goes above the local declarations
    assert lines[:4] == ['// head', '// two', '// lines', 'let a = 0;']
    for c in ('// trailing', '// inside', '// before case', '// end'):
        assert c in lines
    assert lines.index('// inside') < lines.index('S.foo(self, other);')
    # without keep_comments nothing changes
    plain, _, _ = translate(ctx, src, True, 1)
    assert '//' not in plain
