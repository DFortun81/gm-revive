"""Reader for GameMaker project files.

Supported: GameMaker 8.0 (.gmk, file version 800).
Detected but not yet readable: GM 5.x/6.x (.gm6), GM 7 (.gmk v701/702, encrypted), GM 8.1 (.gm81, v810),
GameMaker Studio 1 (.gmx folders) and Studio 2 (.yyp).
"""
import os
import struct
import zlib

GMK_MAGIC = 1234321
RESOURCE_KINDS = ['sounds', 'sprites', 'backgrounds', 'paths', 'scripts', 'fonts', 'timelines', 'objects', 'rooms']


class UnsupportedFormat(Exception):
    """The file is a GameMaker project, but in a format this reader can't parse yet."""

    def __init__(self, fmt, message):
        super().__init__(message)
        self.format = fmt


def detect(path):
    """Identify a GameMaker project file. Returns (format_name, version) or (None, None)."""
    low = path.lower()
    if low.endswith('.yyp'):
        return 'GameMaker Studio 2 (.yyp)', None
    if low.endswith('.project.gmx'):
        return 'GameMaker Studio 1 (.gmx)', None
    if low.endswith('.exe'):
        return 'compiled executable (.exe)', None
    try:
        with open(path, 'rb') as fh:
            head = fh.read(8)
    except OSError:
        return None, None
    if len(head) < 8:
        return None, None
    magic, ver = struct.unpack('<ii', head)
    if magic != GMK_MAGIC:
        return None, None
    names = {530: 'GameMaker 5.3', 600: 'GameMaker 6', 701: 'GameMaker 7', 702: 'GameMaker 7',
             800: 'GameMaker 8.0', 810: 'GameMaker 8.1'}
    return names.get(ver, f'GameMaker (unknown version {ver})'), ver


class _Reader:
    __slots__ = ('b', 'p')

    def __init__(self, b, p=0):
        self.b = b
        self.p = p

    def int(self):
        v, = struct.unpack_from('<i', self.b, self.p)
        self.p += 4
        return v

    def double(self):
        v, = struct.unpack_from('<d', self.b, self.p)
        self.p += 8
        return v

    def bool(self):
        return self.int() != 0

    def str(self):
        n = self.int()
        v = self.b[self.p:self.p + n].decode('cp1252', errors='replace')
        self.p += n
        return v

    def skip(self, n):
        self.p += n

    def block(self):
        """A zlib-compressed sub-block (GM8 stores every resource in one)."""
        n = self.int()
        b = zlib.decompress(self.b[self.p:self.p + n])
        self.p += n
        return _Reader(b)

    def raw(self):
        n = self.int()
        v = self.b[self.p:self.p + n]
        self.p += n
        return v


def _read_action(r):
    a = {}
    r.int()  # version 440
    a['lib'] = r.int()
    a['id'] = r.int()
    a['kind'] = r.int()          # 0 normal, 1 begin, 2 end, 3 else, 4 exit, 5 repeat, 6 variable, 7 code
    a['relative_allowed'] = r.bool()
    a['question'] = r.bool()
    a['applies_allowed'] = r.bool()
    a['exec'] = r.int()          # 0 none, 1 function, 2 code
    a['func'] = r.str()
    a['code'] = r.str()
    a['argc'] = r.int()
    n = r.int()
    a['argkinds'] = [r.int() for _ in range(n)]
    a['applies'] = r.int()       # -1 self, -2 other, else object index
    a['relative'] = r.bool()
    n = r.int()
    a['args'] = [r.str() for _ in range(n)]
    a['not'] = r.bool()
    return a


def _read_actions(r):
    r.int()  # version 400
    return [_read_action(r) for _ in range(r.int())]


def load(path):
    """Parse a GameMaker 8.0 project. Raises UnsupportedFormat for other versions."""
    fmt, ver = detect(path)
    if fmt is None:
        raise UnsupportedFormat(None, f'{path}: not a GameMaker project file')
    if ver != 800:
        raise UnsupportedFormat(fmt, f'{path}: {fmt} files are not supported yet (only GameMaker 8.0 .gmk)')

    with open(path, 'rb') as fh:
        f = _Reader(fh.read())
    f.skip(8)                     # magic, version
    g = {'format': fmt, 'version': ver, 'constants': {}}
    g['game_id'] = f.int()
    f.skip(16)                    # GUID
    f.int()
    f.block()                     # game settings
    f.int()
    for _ in range(f.int()):      # triggers
        f.block()
    f.double()
    f.int()
    for _ in range(f.int()):      # constants
        k = f.str()
        g['constants'][k] = f.str()
    f.double()

    for kind in RESOURCE_KINDS:
        f.int()
        lst = []
        for idx in range(f.int()):
            r = f.block()
            if not r.bool():
                lst.append(None)
                continue
            res = {'name': r.str(), 'index': idx}
            r.double()            # last changed
            res['_r'] = r
            lst.append(res)
        g[kind] = lst

    for s in g['scripts']:
        if s:
            r = s.pop('_r'); r.int()
            s['code'] = r.str()

    for t in g['timelines']:
        if not t:
            continue
        r = t.pop('_r'); r.int()
        t['moments'] = []
        for _ in range(r.int()):
            step = r.int()
            t['moments'].append((step, _read_actions(r)))

    for o in g['objects']:
        if not o:
            continue
        r = o.pop('_r'); r.int()
        o['sprite'] = r.int(); o['solid'] = r.bool(); o['visible'] = r.bool(); o['depth'] = r.int()
        o['persistent'] = r.bool(); o['parent'] = r.int(); o['mask'] = r.int()
        nmain = r.int()
        o['events'] = []
        for et in range(nmain + 1):
            while True:
                en = r.int()
                if en == -1:
                    break
                o['events'].append((et, en, _read_actions(r)))

    for rm in g['rooms']:
        if not rm:
            continue
        r = rm.pop('_r'); r.int()
        rm['caption'] = r.str(); rm['width'] = r.int(); rm['height'] = r.int()
        r.int(); r.int(); r.bool()  # snap x/y, isometric grid
        rm['speed'] = r.int(); rm['persistent'] = r.bool()
        rm['color'] = r.int(); rm['draw_color'] = r.bool(); rm['code'] = r.str()
        rm['backgrounds'] = []
        for _ in range(r.int()):
            rm['backgrounds'].append({
                'visible': r.bool(), 'foreground': r.bool(), 'index': r.int(), 'x': r.int(), 'y': r.int(),
                'htiled': r.bool(), 'vtiled': r.bool(), 'hspeed': r.int(), 'vspeed': r.int(), 'stretch': r.bool()})
        rm['views_enabled'] = r.bool()
        rm['views'] = []
        for _ in range(r.int()):
            vis = r.bool()
            v = [r.int() for _ in range(13)]
            rm['views'].append({'visible': vis, 'x': v[0], 'y': v[1], 'w': v[2], 'h': v[3], 'px': v[4], 'py': v[5],
                                'pw': v[6], 'ph': v[7], 'hbor': v[8], 'vbor': v[9], 'hsp': v[10], 'vsp': v[11],
                                'obj': v[12]})
        rm['instances'] = []
        for _ in range(r.int()):
            x = r.int(); y = r.int(); obj = r.int(); iid = r.int(); code = r.str(); r.bool()
            rm['instances'].append({'x': x, 'y': y, 'object': obj, 'id': iid, 'code': code})
        rm['tiles'] = []
        for _ in range(r.int()):
            t = {'x': r.int(), 'y': r.int(), 'bg': r.int(), 'tx': r.int(), 'ty': r.int(),
                 'w': r.int(), 'h': r.int(), 'depth': r.int(), 'id': r.int()}
            r.bool()              # locked
            rm['tiles'].append(t)

    for sp in g['sprites']:
        if not sp:
            continue
        r = sp.pop('_r'); r.int()
        sp['ox'] = r.int(); sp['oy'] = r.int(); sp['frames'] = []
        for _ in range(r.int()):
            r.int(); w = r.int(); h = r.int()
            sp['frames'].append((w, h, r.raw() if w else b''))   # raw BGRA
        sp['shape'] = r.int(); sp['tol'] = r.int(); sp['sepmask'] = r.bool(); sp['bboxmode'] = r.int()
        sp['bbox'] = [r.int() for _ in range(4)]                   # left, right, bottom, top

    for b in g['backgrounds']:
        if not b:
            continue
        r = b.pop('_r'); r.int()
        b['tileset'] = r.bool()
        b['tile'] = [r.int() for _ in range(6)]   # tile w, h, hoffset, voffset, hsep, vsep
        r.int()
        w = r.int(); h = r.int()
        b['image'] = (w, h, r.raw() if w else b'')

    for sn in g['sounds']:
        if not sn:
            continue
        r = sn.pop('_r'); r.int()
        sn['kind'] = r.int(); sn['ext'] = r.str(); sn['file'] = r.str()
        sn['data'] = r.raw() if r.bool() else None
        sn['effects'] = r.int(); sn['volume'] = r.double(); sn['pan'] = r.double(); sn['preload'] = r.bool()

    for fn in g['fonts']:
        if not fn:
            continue
        r = fn.pop('_r'); r.int()
        fn['font'] = r.str(); fn['size'] = r.int(); fn['bold'] = r.bool(); fn['italic'] = r.bool()
        fn['first'] = r.int(); fn['last'] = r.int()

    for p in g['paths']:
        if not p:
            continue
        r = p.pop('_r'); r.int()
        p['smooth'] = r.bool(); p['closed'] = r.bool(); p['precision'] = r.int()
        r.int(); r.int(); r.int()  # room, snap x, snap y
        p['points'] = [(r.double(), r.double(), r.double()) for _ in range(r.int())]

    f.int(); f.int()               # last instance id, last tile id
    f.int()
    g['include_files'] = f.int()
    for _ in range(g['include_files']):
        f.block()
    f.int()
    g['extensions'] = [f.str() for _ in range(f.int())]
    f.int()
    gi = f.block()
    text = gi.b.decode('cp1252', errors='replace')
    i = text.find('{\\rtf')
    g['game_info_rtf'] = text[i:] if i >= 0 else ''
    return g


if __name__ == '__main__':
    import sys
    g = load(sys.argv[1])
    for k in RESOURCE_KINDS:
        print(k, len([x for x in g[k] if x]))
    print('extensions:', g['extensions'])
