"""GML (GameMaker 8) -> JavaScript translator.

Output conventions (see runtime.js):
  self, other   - the current instance objects (JS objects)
  G             - global.* variables
  K             - user-defined constants
  S             - user scripts:  S.name(self, other, arg0, arg1, ...)
  B             - built-in GameMaker functions / variables
  I(id)         - resolve an instance id / object index to an instance object
  resource names (obj_*, spr_*, snd_* ...) are plain global JS constants
"""
import re, json

KEYWORDS = {'if','then','else','while','do','until','for','repeat','with','switch','case',
            'default','break','continue','exit','return','var','globalvar','begin','end',
            'and','or','not','xor','div','mod'}

JS_RESERVED = {'class','new','function','this','let','in','of','delete','typeof','void','yield',
               'static','enum','export','import','super','null','undefined','NaN','Infinity',
               'arguments','eval','const','instanceof','try','catch','finally','throw','debugger',
               'extends','implements','interface','package','private','protected','public',
               'await','async','with','self','other','G','K','S','B','I'}

# GameMaker built-in global variables / constants (accessed as B.name)
GLOBAL_BUILTINS = set('''
room room_width room_height room_speed room_caption room_persistent room_first room_last
fps current_time current_year current_month current_day current_weekday current_hour current_minute current_second
mouse_x mouse_y mouse_button mouse_lastbutton keyboard_key keyboard_lastkey keyboard_lastchar keyboard_string
working_directory program_directory temp_directory instance_count instance_id
view_enabled view_current view_visible view_xview view_yview view_wview view_hview view_xport view_yport
view_wport view_hport view_angle view_hborder view_vborder view_hspeed view_vspeed view_object
background_color background_showcolor background_visible background_index background_x background_y
score lives health show_score show_lives show_health caption_score caption_lives caption_health
transition_kind transition_steps error_occurred error_last debug_mode game_id secure_mode
event_type event_number event_object event_action
pi true false noone all
'''.split())
BUILTIN_PREFIXES = ('c_', 'bm_', 'fa_', 'vk_', 'pr_', 'ev_', 'mb_', 'ty_', 'se_', 'cr_', 'ef_', 'ps_', 'dll_')

# Built-ins that act on the calling instance: emitted as B.fn(self, ...)
SELF_FUNCS = set('''
instance_destroy instance_change instance_copy place_free place_empty place_meeting position_meeting
instance_place move_towards_point move_snap move_wrap move_random motion_set motion_add
distance_to_object distance_to_point draw_self draw_sprite draw_sprite_ext
action_kill_object sprite_collision_mask path_start path_end timeline_set
mp_linear_step mp_potential_step instance_nearest_self
'''.split())


class Tok:
    __slots__ = ('t', 'v', 'line')
    def __init__(s, t, v, line): s.t = t; s.v = v; s.line = line
    def __repr__(s): return f'{s.t}:{s.v}'


OPS = [':=', '+=', '-=', '*=', '/=', '|=', '&=', '^=', '==', '!=', '<>', '<=', '>=', '<<', '>>',
       '&&', '||', '^^', '++', '--', '+', '-', '*', '/', '%', '!', '~', '&', '|', '^', '<', '>',
       '=', '.', ',', ';', '(', ')', '[', ']', '{', '}', ':', '?']


def lex(src):
    toks = []; i = 0; n = len(src); line = 1
    while i < n:
        c = src[i]
        if c == '\n': line += 1; i += 1; continue
        if c in ' \t\r\f\v': i += 1; continue
        if src.startswith('//', i):
            j = src.find('\n', i); i = n if j < 0 else j; continue
        if src.startswith('/*', i):
            j = src.find('*/', i + 2); j = n if j < 0 else j + 2
            line += src.count('\n', i, j); i = j; continue
        if c.isdigit() or (c == '.' and i + 1 < n and src[i + 1].isdigit()):
            m = re.match(r'\d*\.?\d*', src[i:]); v = m.group(0)
            if v.endswith('.') and len(v) > 1: v = v[:-1]
            toks.append(Tok('num', v, line)); i += len(v); continue
        if c == '$':
            m = re.match(r'\$[0-9A-Fa-f]+', src[i:])
            if m:
                toks.append(Tok('num', '0x' + m.group(0)[1:], line)); i += len(m.group(0)); continue
        if c in '"\'':
            j = src.find(c, i + 1); j = n if j < 0 else j
            s = src[i + 1:j]; line += s.count('\n')
            toks.append(Tok('str', s, line)); i = j + 1; continue
        if c.isalpha() or c == '_':
            m = re.match(r'[A-Za-z_]\w*', src[i:]); v = m.group(0)
            toks.append(Tok('kw' if v in KEYWORDS else 'id', v, line)); i += len(v); continue
        for op in OPS:
            if src.startswith(op, i):
                toks.append(Tok('op', op, line)); i += len(op); break
        else:
            i += 1  # ignore stray char
    toks.append(Tok('eof', None, line))
    return toks


class ParseError(Exception):
    pass


class Parser:
    def __init__(s, src):
        s.toks = lex(src); s.p = 0
        s.locals = []; s.globalvars = set()

    def peek(s, k=0): return s.toks[s.p + k]
    def nxt(s): t = s.toks[s.p]; s.p += 1; return t
    def at(s, *vals):
        t = s.toks[s.p]; return t.t in ('op', 'kw') and t.v in vals
    def accept(s, *vals):
        if s.at(*vals): return s.nxt()
        return None
    def expect(s, *vals):
        t = s.nxt()
        if t.t in ('op', 'kw') and t.v in vals: return t
        raise ParseError(f'line {t.line}: expected {vals}, got {t.v!r}')

    # ---------- statements
    def program(s):
        out = []
        while s.peek().t != 'eof':
            out.append(s.statement())
        return ('block', out)

    def block_until(s, *ends):
        out = []
        while not s.at(*ends):
            if s.peek().t == 'eof': raise ParseError('unexpected end of code')
            out.append(s.statement())
        s.nxt()
        return ('block', out)

    def statement(s):
        t = s.peek()
        if s.accept('{'): st = s.block_until('}')
        elif s.accept('begin'): st = s.block_until('end')
        elif s.accept(';'): return ('empty',)
        elif s.accept('var'): st = s.vardecl(s.locals)
        elif s.accept('globalvar'):
            names = []; st = s.vardecl(names); s.globalvars.update(names)
        elif s.accept('if'):
            c = s.expr(); s.accept('then'); a = s.statement(); b = None
            if s.accept('else'): b = s.statement()
            st = ('if', c, a, b)
        elif s.accept('while'):
            c = s.expr(); s.accept('do'); st = ('while', c, s.statement())
        elif s.accept('do'):
            b = s.statement(); s.expect('until'); st = ('dountil', b, s.expr())
        elif s.accept('for'):
            s.expect('(')
            init = s.statement() if not s.at(';') else ('empty',)
            s.accept(';')
            cond = s.expr() if not s.at(';') else None
            s.accept(';')
            step = s.simple_statement() if not s.at(')') else ('empty',)
            s.accept(';')
            s.expect(')')
            st = ('for', init, cond, step, s.statement())
        elif s.accept('repeat'):
            n = s.expr(); st = ('repeat', n, s.statement())
        elif s.accept('with'):
            e = s.expr(); st = ('with', e, s.statement())
        elif s.accept('switch'):
            e = s.expr(); s.expect('{', 'begin'); cases = []
            while not s.at('}', 'end'):
                if s.accept('case'):
                    v = s.expr(); s.expect(':'); cases.append([v, []])
                elif s.accept('default'):
                    s.expect(':'); cases.append([None, []])
                else:
                    if not cases: cases.append([None, []])
                    cases[-1][1].append(s.statement())
            s.nxt(); st = ('switch', e, cases)
        elif s.accept('break'): st = ('break',)
        elif s.accept('continue'): st = ('continue',)
        elif s.accept('exit'): st = ('exit',)
        elif s.accept('return'): st = ('return', s.expr())
        else: st = s.simple_statement()
        s.accept(';')
        return st

    def vardecl(s, into):
        assigns = []
        while True:
            t = s.nxt()
            if t.t != 'id': raise ParseError(f'line {t.line}: bad var name {t.v!r}')
            into.append(t.v)
            if s.at('=', ':='):
                s.nxt(); assigns.append(('assign', ('name', t.v), '=', s.expr()))
            if not s.accept(','): break
        return ('block', assigns) if assigns else ('empty',)

    def simple_statement(s):
        t = s.peek()
        if s.at('++', '--'):
            op = s.nxt().v; return ('incr', s.postfix(), op)
        lhs = s.postfix()
        if s.at('=', ':=', '+=', '-=', '*=', '/=', '|=', '&=', '^='):
            op = s.nxt().v
            if op == ':=': op = '='
            return ('assign', lhs, op, s.expr())
        if s.at('++', '--'):
            return ('incr', lhs, s.nxt().v)
        if lhs[0] != 'call':
            raise ParseError(f'line {t.line}: statement is not an assignment or call near {t.v!r}')
        return ('expr', lhs)

    # ---------- expressions
    def expr(s): return s.logic()

    def logic(s):
        l = s.comp()
        while s.at('&&', '||', '^^', 'and', 'or', 'xor'):
            op = {'and': '&&', 'or': '||', 'xor': '^^'}.get(s.peek().v, s.peek().v); s.nxt()
            l = ('logic', op, l, s.comp())
        return l

    def comp(s):
        l = s.bitw()
        while s.at('<', '<=', '==', '!=', '<>', '>', '>=', '='):
            op = s.nxt().v
            op = {'=': '==', '<>': '!='}.get(op, op)
            l = ('cmp', op, l, s.bitw())
        return l

    def bitw(s):
        l = s.shift()
        while s.at('|', '&', '^'):
            op = s.nxt().v; l = ('bin', op, l, s.shift())
        return l

    def shift(s):
        l = s.add()
        while s.at('<<', '>>'):
            op = s.nxt().v; l = ('bin', op, l, s.add())
        return l

    def add(s):
        l = s.mul()
        while s.at('+', '-'):
            op = s.nxt().v; l = ('bin', op, l, s.mul())
        return l

    def mul(s):
        l = s.unary()
        while s.at('*', '/', '%', 'div', 'mod'):
            op = s.nxt().v; l = ('bin', op, l, s.unary())
        return l

    def unary(s):
        if s.at('!', 'not'): s.nxt(); return ('not', s.unary())
        if s.at('-'): s.nxt(); return ('neg', s.unary())
        if s.at('+'): s.nxt(); return s.unary()
        if s.at('~'): s.nxt(); return ('bnot', s.unary())
        if s.at('++', '--'):
            op = s.nxt().v; return ('preincr', s.postfix(), op)
        return s.postfix()

    def postfix(s):
        e = s.primary()
        while True:
            if s.accept('.'):
                t = s.nxt()
                if t.t == 'num':  # e.g. "a.0" never valid, but guard
                    raise ParseError(f'line {t.line}: bad field')
                e = ('field', e, t.v)
            elif s.at('['):
                s.nxt(); idx = [s.expr()]
                while s.accept(','): idx.append(s.expr())
                s.expect(']'); e = ('index', e, idx)
            elif s.at('(') and e[0] == 'name':
                s.nxt(); args = []
                if not s.at(')'):
                    args.append(s.expr())
                    while s.accept(','): args.append(s.expr())
                s.expect(')'); e = ('call', e[1], args)
            else:
                return e

    def primary(s):
        t = s.nxt()
        if t.t == 'num':
            v = t.v
            if v.startswith('.'): v = '0' + v
            return ('num', v)
        if t.t == 'str': return ('str', t.v)
        if t.t == 'id': return ('name', t.v)
        if t.t == 'op' and t.v == '(':
            e = s.expr(); s.expect(')'); return ('paren', e)
        raise ParseError(f'line {t.line}: unexpected {t.v!r}')


BOOL_KINDS = {'cmp', 'logic', 'not'}


class Emitter:
    def __init__(s, ctx, locals_, globalvars, is_script):
        s.ctx = ctx
        s.locals = {n: s.safe(n) for n in locals_}
        s.globalvars = globalvars
        s.is_script = is_script
        s.tmp = 0
        s.max_arg = -1
        s.uses_argarray = False

    @staticmethod
    def safe(n): return ('l_' + n) if n in JS_RESERVED else n

    def newtmp(s): s.tmp += 1; return f'__w{s.tmp}'

    # ---------- names
    def name(s, n):
        ctx = s.ctx
        if n in s.locals: return s.locals[n]
        m = re.fullmatch(r'argument(\d+)', n)
        if m:
            s.max_arg = max(s.max_arg, int(m.group(1))); return n
        if n == 'argument': s.uses_argarray = True; return 'argument'
        if n == 'argument_count': s.uses_argarray = True; return 'argument_count'
        if n == 'self': return 'self.id'
        if n == 'other': return 'other.id'
        if n == 'global': return 'G'
        if n == 'id': return 'self.id'
        if n in ('true', 'false'): return n
        if n == 'noone': return '(-4)'
        if n == 'all': return '(-3)'
        if n in s.globalvars or n in ctx.globalvars: return f'G.{n}'
        if n in ctx.constants: return f'K.{n}'
        if n in ctx.resources: return n
        if n in GLOBAL_BUILTINS or n.startswith(BUILTIN_PREFIXES):
            ctx.used_builtins.add(n); return f'B.{n}'
        return f'self.{s.safe_field(n)}'

    @staticmethod
    def safe_field(n): return n

    def base(s, e):
        """JS expression for the object whose field is accessed with e.field"""
        if e[0] == 'name':
            if e[1] == 'self': return 'self'
            if e[1] == 'other': return 'other'
            if e[1] == 'global': return 'G'
        return f'I({s.ex(e)})'

    def is_direct_base(s, e):
        return e[0] == 'name' and e[1] in ('self', 'other', 'global')

    # ---------- expressions
    def ex(s, e):
        k = e[0]
        if k == 'num': return e[1]
        if k == 'str': return json.dumps(e[1], ensure_ascii=False)
        if k == 'name': return s.name(e[1])
        if k == 'paren': return '(' + s.ex(e[1]) + ')'
        if k == 'field': return f'{s.base(e[1])}.{e[2]}'
        if k == 'index':
            arr = s.ex(e[1]); idx = [s.ex(i) for i in e[2]]
            return f'B.aget({arr}, {", ".join(idx)})'
        if k == 'call': return s.call(e[1], e[2])
        if k == 'not': return '!' + s.paren_if(s.bool(e[1]))
        if k == 'neg': return '-' + s.paren_if(s.ex(e[1]))
        if k == 'bnot': return '~' + s.paren_if(s.ex(e[1]))
        if k == 'cmp': return f'({s.ex(e[2])} {e[1]} {s.ex(e[3])})'
        if k == 'logic':
            a = s.bool(e[2]); b = s.bool(e[3])
            if e[1] == '^^': return f'({a} !== {b})'
            return f'({a} {e[1]} {b})'
        if k == 'bin':
            a = s.ex(e[2]); b = s.ex(e[3]); op = e[1]
            if op == 'div': return f'Math.trunc({a} / {b})'
            if op in ('mod', '%'): return f'({a} % {b})'
            if op in ('|', '&', '^', '<<', '>>'):
                return f'(Math.round({a}) {op} Math.round({b}))'
            return f'({a} {op} {b})'
        if k == 'preincr':
            return '(' + s.assign_expr(e[1], '+=' if e[2] == '++' else '-=', '1') + ')'
        raise ParseError(f'cannot emit expression {k}')

    @staticmethod
    def paren_if(x):
        return x if re.fullmatch(r'[\w.$]+|\(.*\)', x) and (not x.startswith('(') or Emitter.balanced(x)) else f'({x})'

    @staticmethod
    def balanced(x):
        d = 0
        for i, ch in enumerate(x):
            if ch == '(': d += 1
            elif ch == ')':
                d -= 1
                if d == 0 and i != len(x) - 1: return False
        return True

    def bool(s, e):
        """Emit an expression used as a condition (GM: true if value > 0.5)."""
        while e[0] == 'paren' and e[1][0] in BOOL_KINDS: e = e[1]
        if e[0] in BOOL_KINDS: return s.ex(e)
        if e[0] == 'name' and e[1] in ('true', 'false'): return e[1]
        return f'B.T({s.ex(e)})'

    def call(s, fname, args):
        a = [s.ex(x) for x in args]
        ctx = s.ctx
        if fname in ctx.scripts:
            return f'S.{fname}(' + ', '.join(['self', 'other'] + a) + ')'
        if fname == 'event_inherited': return 'B.event_inherited(self, other)'
        if fname == 'script_execute':
            return 'B.script_execute(' + ', '.join(['self', 'other'] + a) + ')'
        if fname == 'instance_create':
            return 'B.instance_create(' + ', '.join(a) + ')'
        ctx.used_builtins.add(fname)
        if fname in SELF_FUNCS:
            return f'B.{fname}(' + ', '.join(['self'] + a) + ')'
        return f'B.{fname}(' + ', '.join(a) + ')'

    def lvalue_parts(s, e):
        """Returns (kind, ...) describing how to assign to e."""
        k = e[0]
        if k == 'name':
            n = e[1]
            if n in ('self', 'other', 'global', 'id'):
                raise ParseError(f'cannot assign to {n}')
            return ('simple', s.name(n))
        if k == 'field':
            if s.is_direct_base(e[1]): return ('simple', f'{s.base(e[1])}.{e[2]}')
            return ('remote', s.ex(e[1]), e[2])
        if k == 'index':
            inner = e[1]
            if inner[0] == 'name':
                container = s.name(inner[1])
            elif inner[0] == 'field':
                container = f'{s.base(inner[1])}.{inner[2]}'
            else:
                raise ParseError('bad array target')
            idx = [s.ex(i) for i in e[2]]
            # B.toArr turns a never-assigned variable (which reads as 0) into a fresh array
            if len(idx) == 1:
                return ('simple', f'({container} = B.toArr({container}))[Math.round({idx[0]})]')
            return ('simple', f'B.toArr2({container} = B.toArr({container}), {idx[0]})[Math.round({idx[1]})]')
        raise ParseError(f'cannot assign to expression of kind {k}')

    def assign_expr(s, lhs, op, rhs_js):
        lp = s.lvalue_parts(lhs)
        if lp[0] == 'simple':
            return f'{lp[1]} {op} {rhs_js}'
        _, target, field = lp
        if op == '=':
            return f'B.setField({target}, "{field}", {rhs_js})'
        return f'B.setField({target}, "{field}", I({target}).{field} {op[0]} {rhs_js})'

    # ---------- statements
    def st(s, node, ind):
        pad = '    ' * ind
        k = node[0]
        if k == 'empty': return ''
        if k == 'block':
            return ''.join(s.st(x, ind) for x in node[1])
        if k == 'expr': return pad + s.ex(node[1]) + ';\n'
        if k == 'assign':
            return pad + s.assign_expr(node[1], node[2], s.ex(node[3])) + ';\n'
        if k == 'incr':
            return pad + s.assign_expr(node[1], '+=' if node[2] == '++' else '-=', '1') + ';\n'
        if k == 'if':
            out = f'{pad}if ({s.bool(node[1])}) {{\n{s.st(node[2], ind + 1)}{pad}}}'
            if node[3] is not None:
                if node[3][0] == 'if':
                    out += ' else ' + s.st(node[3], ind).lstrip()
                    return out
                out += f' else {{\n{s.st(node[3], ind + 1)}{pad}}}'
            return out + '\n'
        if k == 'while':
            return f'{pad}while ({s.bool(node[1])}) {{\n{s.st(node[2], ind + 1)}{pad}}}\n'
        if k == 'dountil':
            return f'{pad}do {{\n{s.st(node[1], ind + 1)}{pad}}} while (!{s.paren_if(s.bool(node[2]))});\n'
        if k == 'for':
            init = s.st(node[1], 0).strip().rstrip(';')
            cond = s.bool(node[2]) if node[2] is not None else ''
            step = s.st(node[3], 0).strip().rstrip(';')
            if '\n' in init or '\n' in step:
                raise ParseError('complex for-loop header')
            return f'{pad}for ({init}; {cond}; {step}) {{\n{s.st(node[4], ind + 1)}{pad}}}\n'
        if k == 'repeat':
            t = s.newtmp().replace('__w', '__r')
            return (f'{pad}for (let {t} = Math.round({s.ex(node[1])}); {t} > 0; {t}--) {{\n'
                    f'{s.st(node[2], ind + 1)}{pad}}}\n')
        if k == 'with':
            t = s.newtmp()
            return (f'{pad}{{ const {t} = B.with({s.ex(node[1])}, self, other);\n'
                    f'{pad}for (const [self, other] of {t}) {{\n'
                    f'{s.st(node[2], ind + 1)}{pad}}} }}\n')
        if k == 'switch':
            out = f'{pad}switch (B.sw({s.ex(node[1])})) {{\n'
            for val, body in node[2]:
                if val is None: out += f'{pad}    default:\n'
                else: out += f'{pad}    case B.sw({s.ex(val)}):\n'
                out += ''.join(s.st(b, ind + 2) for b in body)
            return out + f'{pad}}}\n'
        if k == 'break': return pad + 'break;\n'
        if k == 'continue': return pad + 'continue;\n'
        if k == 'exit': return pad + ('return 0;\n' if s.is_script else 'return;\n')
        if k == 'return': return pad + f'return {s.ex(node[1])};\n'
        raise ParseError(f'cannot emit statement {k}')


class Context:
    def __init__(s, resources, scripts, constants):
        s.resources = set(resources); s.scripts = set(scripts); s.constants = set(constants)
        s.globalvars = set(); s.used_builtins = set()


def prescan_globalvars(ctx, sources):
    for src in sources:
        for m in re.finditer(r'\bglobalvar\s+([\w\s,]+)', src):
            for n in m.group(1).split(','):
                n = n.strip().split()[0] if n.strip() else ''
                if n: ctx.globalvars.add(n)


def translate(ctx, src, is_script, ind=1):
    """Translate a piece of GML. Returns (body_js, max_arg, uses_argarray)."""
    p = Parser(src)
    ast = p.program()
    em = Emitter(ctx, p.locals, p.globalvars, is_script)
    body = em.st(ast, ind)
    decl = ''
    if p.locals:
        seen = []
        for n in p.locals:
            if em.locals[n] not in seen: seen.append(em.locals[n])
        decl = '    ' * ind + 'let ' + ', '.join(f'{n} = 0' for n in seen) + ';\n'
    return decl + body, em.max_arg, em.uses_argarray
