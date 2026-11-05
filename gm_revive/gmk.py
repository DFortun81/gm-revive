"""Reader for GameMaker project files.

Supported: GameMaker 7 (.gmk, file version 701/702) and GameMaker 8.0 (.gmk, version 800).
Detected but not yet readable: GM 5.x/6.x (.gm6), GM 8.1 (.gm81, v810),
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
    if ver in (701, 702):
        return _load_gm7(path, fmt, ver)
    if ver != 800:
        raise UnsupportedFormat(fmt, f'{path}: {fmt} files are not supported yet')

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
    _read_room_order(f, g)
    return g


def _read_room_order(f, g):
    """Library creation code, then the room execution order (the game starts in the first room)."""
    try:
        f.int()
        for _ in range(f.int()):
            f.str()
        f.int()
        g['room_order'] = [f.int() for _ in range(f.int())]
    except struct.error:
        g['room_order'] = []
    if not g['room_order']:
        g['room_order'] = [r['index'] for r in g['rooms'] if r]


if __name__ == '__main__':
    import sys
    g = load(sys.argv[1])
    for k in RESOURCE_KINDS:
        print(k, len([x for x in g[k] if x]))
    print('extensions:', g['extensions'])


# ---------------------------------------------------------------------------------------------------
# GameMaker 7 (.gmk version 701/702)
#
# GM7 files are obfuscated with a byte-substitution cipher. The header holds two runs of junk ints with
# the seed between them; everything after the first byte of the game id is encoded as
#     plain = (table[cipher] - position_in_file) & 0xFF
# Unlike GM8, resources are stored sequentially (not one zlib block each) and images are zlib-compressed
# BMP files.

def _gm7_decode_table(seed):
    t = list(range(256))
    a = 6 + seed % 250
    b = seed // 250
    for i in range(1, 10001):
        j = 1 + ((i * a + b) % 254)
        t[j], t[j + 1] = t[j + 1], t[j]
    dec = [0] * 256
    for i in range(1, 256):
        dec[t[i]] = i
    return dec


def _gm7_decrypt(data):
    """Returns (plaintext bytes, offset where the game id starts)."""
    s1, s2 = struct.unpack_from('<ii', data, 8)
    p = 16 + s1 * 4
    seed, = struct.unpack_from('<i', data, p)
    p += 4 + s2 * 4
    dec = _gm7_decode_table(seed)
    out = bytearray(data)
    for i in range(p + 1, len(data)):    # the first byte of the game id is stored in the clear
        out[i] = (dec[data[i]] - i) & 0xFF
    return bytes(out), p


def _bmp_to_bgra(bmp, transparent):
    """Decode an uncompressed BMP (1/4/8/24/32 bpp) to top-down BGRA bytes.
    If transparent is set, the bottom-left pixel's colour becomes fully transparent (GameMaker 7 rule)."""
    if bmp[:2] != b'BM':
        raise ValueError('not a BMP image')
    off, = struct.unpack_from('<I', bmp, 10)
    hdr, = struct.unpack_from('<I', bmp, 14)
    w, h, _, bpp, comp = struct.unpack_from('<iiHHI', bmp, 18)
    if comp not in (0, 3):
        raise ValueError(f'compressed BMP (mode {comp}) not supported')
    ncolors, = struct.unpack_from('<I', bmp, 46) if hdr >= 40 else (0,)
    palette = []
    if bpp <= 8:
        n = ncolors or (1 << bpp)
        pbase = 14 + hdr
        palette = [bmp[pbase + 4 * k:pbase + 4 * k + 3] + b'\xff' for k in range(n)]
    bottom_up = h > 0
    h = abs(h)
    stride = ((w * bpp + 31) // 32) * 4
    out = bytearray(w * h * 4)
    for row in range(h):
        src = off + (h - 1 - row if bottom_up else row) * stride
        line = bmp[src:src + stride]
        o = row * w * 4
        if bpp == 32:
            for x in range(w):
                out[o + 4 * x:o + 4 * x + 4] = line[4 * x:4 * x + 3] + b'\xff'
        elif bpp == 24:
            for x in range(w):
                out[o + 4 * x:o + 4 * x + 4] = line[3 * x:3 * x + 3] + b'\xff'
        elif bpp in (1, 4, 8):
            per = 8 // bpp
            mask = (1 << bpp) - 1
            for x in range(w):
                byte = line[x // per]
                idx = (byte >> ((per - 1 - x % per) * bpp)) & mask
                out[o + 4 * x:o + 4 * x + 4] = palette[idx] if idx < len(palette) else b'\0\0\0\xff'
        elif bpp == 16:
            for x in range(w):
                v, = struct.unpack_from('<H', line, 2 * x)
                r, g, b = (v >> 10) & 31, (v >> 5) & 31, v & 31
                out[o + 4 * x:o + 4 * x + 4] = bytes([b * 255 // 31, g * 255 // 31, r * 255 // 31, 255])
        else:
            raise ValueError(f'{bpp}-bit BMP not supported')
    if transparent and w and h:
        key = bytes(out[(h - 1) * w * 4:(h - 1) * w * 4 + 3])
        for k in range(0, len(out), 4):
            if out[k:k + 3] == key:
                out[k + 3] = 0
    return w, h, bytes(out)


def _gm7_image(r, transparent):
    n = r.int()
    data = zlib.decompress(r.b[r.p:r.p + n])
    r.p += n
    return _bmp_to_bgra(data, transparent)


def _load_gm7(path, fmt, ver):
    with open(path, 'rb') as fh:
        raw = fh.read()
    plain, p = _gm7_decrypt(raw)
    f = _Reader(plain, p)
    g = {'format': fmt, 'version': ver, 'constants': {}, 'extensions': [], 'include_files': 0}
    g['game_id'] = f.int()
    f.skip(16)

    # --- settings (version 702): only the parts we need, the rest is skipped field by field
    sver = f.int()
    f.int(); f.int(); f.int(); f.int(); f.int()   # fullscreen, interpolate, no border, cursor, scaling
    f.int(); f.int(); f.int()                     # resizable, on top, colour outside room
    f.int(); f.int(); f.int(); f.int()            # set resolution, depth, resolution, frequency
    f.int(); f.int()                              # no buttons, vsync
    f.int(); f.int(); f.int(); f.int()            # F4, F1, Esc, F5/F6
    if sver > 600:
        f.int(); f.int()                          # F9, close as Esc
    f.int(); f.int()                              # priority, freeze
    load_bar = f.int()
    if load_bar == 2:
        for _ in range(2):
            if f.int() != -1:
                f.skip(f.int())
    if f.bool():                                  # custom load image
        if f.int() != -1:
            f.skip(f.int())
    f.int(); f.int(); f.int()                     # partially transparent, alpha, scale bar
    f.skip(f.int())                               # icon
    f.int(); f.int(); f.int()                     # display errors, log, abort
    g['uninit_as_zero'] = bool(f.int() & 1)
    f.str()                                       # author
    if sver > 600:
        f.str()
    else:
        f.int()
    f.double()
    f.str()                                       # information
    for _ in range(f.int()):
        k = f.str()
        g['constants'][k] = f.str()
    if sver > 600:
        f.int(); f.int(); f.int(); f.int()
        f.str(); f.str(); f.str(); f.str()
    else:
        for _ in range(f.int()):
            f.str()
        f.int(); f.int(); f.int()

    def header(kind_list):
        exists = f.bool()
        if not exists:
            kind_list.append(None)
            return None
        res = {'name': f.str(), 'index': len(kind_list)}
        kind_list.append(res)
        return res

    # sounds
    f.int(); g['sounds'] = []
    for _ in range(f.int()):
        sn = header(g['sounds'])
        if not sn:
            continue
        sv = f.int()
        sn['kind'] = f.int(); sn['ext'] = f.str(); sn['file'] = f.str()
        sn['data'] = None
        if f.bool():
            n = f.int()
            blob = f.b[f.p:f.p + n]; f.p += n
            sn['data'] = zlib.decompress(blob) if sv == 600 else blob
        sn['effects'] = f.int(); sn['volume'] = f.double(); sn['pan'] = f.double(); sn['preload'] = f.bool()

    # sprites
    f.int(); g['sprites'] = []
    for _ in range(f.int()):
        sp = header(g['sprites'])
        if not sp:
            continue
        f.int()
        f.int(); f.int()                          # width, height
        left, right, bottom, top = f.int(), f.int(), f.int(), f.int()
        transparent = f.bool()
        f.bool(); f.bool()                        # smooth, preload
        sp['bboxmode'] = f.int()
        sp['shape'] = 0 if f.bool() else 1        # precise -> 0
        sp['ox'] = f.int(); sp['oy'] = f.int()
        sp['frames'] = []
        for _ in range(f.int()):
            if f.int() == -1:
                continue
            sp['frames'].append(_gm7_image(f, transparent))
        sp['bbox'] = [left, right, bottom, top]
        sp['tol'] = 0; sp['sepmask'] = False

    # backgrounds
    f.int(); g['backgrounds'] = []
    for _ in range(f.int()):
        bg = header(g['backgrounds'])
        if not bg:
            continue
        f.int()
        f.int(); f.int()
        transparent = f.bool()
        f.bool(); f.bool()
        bg['tileset'] = f.bool()
        bg['tile'] = [f.int() for _ in range(6)]
        bg['image'] = (0, 0, b'')
        if f.bool() and f.int() != -1:
            bg['image'] = _gm7_image(f, transparent)

    # paths
    f.int(); g['paths'] = []
    for _ in range(f.int()):
        pa = header(g['paths'])
        if not pa:
            continue
        f.int()
        pa['smooth'] = f.bool(); pa['closed'] = f.bool(); pa['precision'] = f.int()
        f.int(); f.int(); f.int()
        pa['points'] = [(f.double(), f.double(), f.double()) for _ in range(f.int())]

    # scripts
    f.int(); g['scripts'] = []
    for _ in range(f.int()):
        s = header(g['scripts'])
        if s:
            f.int(); s['code'] = f.str()

    # fonts
    f.int(); g['fonts'] = []
    for _ in range(f.int()):
        fo = header(g['fonts'])
        if not fo:
            continue
        f.int()
        fo['font'] = f.str(); fo['size'] = f.int(); fo['bold'] = f.bool(); fo['italic'] = f.bool()
        fo['first'] = f.int() & 0xFFFF; fo['last'] = f.int()

    # timelines
    f.int(); g['timelines'] = []
    for _ in range(f.int()):
        t = header(g['timelines'])
        if not t:
            continue
        f.int(); t['moments'] = []
        for _ in range(f.int()):
            step = f.int()
            t['moments'].append((step, _read_actions(f)))

    # objects
    f.int(); g['objects'] = []
    for _ in range(f.int()):
        o = header(g['objects'])
        if not o:
            continue
        f.int()
        o['sprite'] = f.int(); o['solid'] = f.bool(); o['visible'] = f.bool(); o['depth'] = f.int()
        o['persistent'] = f.bool(); o['parent'] = f.int(); o['mask'] = f.int()
        o['events'] = []
        for et in range(f.int() + 1):
            while True:
                en = f.int()
                if en == -1:
                    break
                o['events'].append((et, en, _read_actions(f)))

    # rooms
    f.int(); g['rooms'] = []
    for _ in range(f.int()):
        rm = header(g['rooms'])
        if not rm:
            continue
        rver = f.int()
        rm['caption'] = f.str(); rm['width'] = f.int(); rm['height'] = f.int()
        f.int(); f.int(); f.bool()
        rm['speed'] = f.int(); rm['persistent'] = f.bool(); rm['color'] = f.int()
        rm['draw_color'] = bool(f.int() & 1); rm['code'] = f.str()
        rm['backgrounds'] = []
        for _ in range(f.int()):
            rm['backgrounds'].append({
                'visible': f.bool(), 'foreground': f.bool(), 'index': f.int(), 'x': f.int(), 'y': f.int(),
                'htiled': f.bool(), 'vtiled': f.bool(), 'hspeed': f.int(), 'vspeed': f.int(), 'stretch': f.bool()})
        rm['views_enabled'] = f.bool(); rm['views'] = []
        for _ in range(f.int()):
            vis = f.bool()
            x, y, w, h, px, py = (f.int() for _ in range(6))
            pw, ph = (f.int(), f.int()) if rver > 520 else (w, h)
            hb, vb, hs, vs, obj = (f.int() for _ in range(5))
            rm['views'].append({'visible': vis, 'x': x, 'y': y, 'w': w, 'h': h, 'px': px, 'py': py, 'pw': pw,
                                'ph': ph, 'hbor': hb, 'vbor': vb, 'hsp': hs, 'vsp': vs, 'obj': obj})
        rm['instances'] = []
        for _ in range(f.int()):
            x = f.int(); y = f.int(); obj = f.int(); iid = f.int(); code = f.str(); f.bool()
            rm['instances'].append({'x': x, 'y': y, 'object': obj, 'id': iid, 'code': code})
        rm['tiles'] = []
        for _ in range(f.int()):
            t = {'x': f.int(), 'y': f.int(), 'bg': f.int(), 'tx': f.int(), 'ty': f.int(),
                 'w': f.int(), 'h': f.int(), 'depth': f.int(), 'id': f.int()}
            f.bool()
            rm['tiles'].append(t)
        f.bool(); f.int(); f.int()                # remember window size, editor w/h
        for _ in range(8):
            f.bool()                              # editor display options
        if rver == 520:
            f.skip(24)
        f.int(); f.int(); f.int()                 # current tab, scroll x/y

    f.int(); f.int()                              # last instance / tile id
    if ver >= 700:
        f.int()
        g['include_files'] = f.int()
        for _ in range(g['include_files']):
            f.int(); f.str(); f.str(); f.bool(); f.int()
            if f.bool():
                f.skip(f.int())
            f.int(); f.str(); f.bool(); f.bool(); f.bool()
        f.int()
        g['extensions'] = [f.str() for _ in range(f.int())]
    f.int()
    f.int(); f.bool()
    if True:
        f.str(); f.int(); f.int(); f.int(); f.int(); f.bool(); f.bool(); f.bool(); f.bool()
    g['game_info_rtf'] = f.str()
    _read_room_order(f, g)
    return g
