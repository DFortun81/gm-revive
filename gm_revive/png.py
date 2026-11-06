"""A small PNG reader (no third-party libraries): enough for sprite sheets in overrides.

Supports non-interlaced PNGs of every colour type at 8 bits per channel, palette images at 1/2/4/8
bits with tRNS transparency, and 16-bit images (reduced to 8 bits). Returns (width, height, rgba)
where rgba is bytes, 4 per pixel, rows top to bottom.
"""
import struct
import zlib


class PNGError(Exception):
    pass


def read(path):
    with open(path, 'rb') as fh:
        data = fh.read()
    return decode(data)


def decode(data):
    if data[:8] != b'\x89PNG\r\n\x1a\n':
        raise PNGError('not a PNG file')
    pos, idat, palette, trns = 8, [], None, None
    w = h = depth = ctype = interlace = None
    while pos < len(data):
        length, kind = struct.unpack('>I4s', data[pos:pos + 8])
        body = data[pos + 8:pos + 8 + length]
        pos += 12 + length
        if kind == b'IHDR':
            w, h, depth, ctype, _, _, interlace = struct.unpack('>IIBBBBB', body)
        elif kind == b'PLTE':
            palette = [tuple(body[i:i + 3]) for i in range(0, len(body), 3)]
        elif kind == b'tRNS':
            trns = body
        elif kind == b'IDAT':
            idat.append(body)
        elif kind == b'IEND':
            break
    if w is None:
        raise PNGError('missing IHDR')
    if interlace:
        raise PNGError('interlaced PNGs are not supported (re-save it without interlacing)')
    channels = {0: 1, 2: 3, 3: 1, 4: 2, 6: 4}.get(ctype)
    if channels is None or depth not in (1, 2, 4, 8, 16) or (depth < 8 and ctype not in (0, 3)):
        raise PNGError(f'unsupported PNG (colour type {ctype}, bit depth {depth})')
    raw = zlib.decompress(b''.join(idat))
    bpp = max(1, channels * depth // 8)                      # bytes per pixel for filtering
    stride = (w * channels * depth + 7) // 8
    rows, prev, p = [], bytearray(stride), 0
    for _ in range(h):
        ft = raw[p]
        line = bytearray(raw[p + 1:p + 1 + stride])
        p += 1 + stride
        for i in range(stride):
            a = line[i - bpp] if i >= bpp else 0
            b = prev[i]
            c = prev[i - bpp] if i >= bpp else 0
            if ft == 1:
                line[i] = (line[i] + a) & 255
            elif ft == 2:
                line[i] = (line[i] + b) & 255
            elif ft == 3:
                line[i] = (line[i] + ((a + b) >> 1)) & 255
            elif ft == 4:
                pa, pb, pc = abs(b - c), abs(a - c), abs(a + b - 2 * c)
                line[i] = (line[i] + (a if pa <= pb and pa <= pc else b if pb <= pc else c)) & 255
            elif ft != 0:
                raise PNGError(f'bad filter type {ft}')
        rows.append(line)
        prev = line

    def samples(line):
        if depth == 8:
            return line
        if depth == 16:
            return line[0::2]
        out, mask = [], (1 << depth) - 1
        for byte in line:
            for shift in range(8 - depth, -1, -depth):
                out.append((byte >> shift) & mask)
        return out

    out = bytearray(w * h * 4)
    o = 0
    for line in rows:
        s = samples(line)
        for x in range(w):
            if ctype == 3:
                idx = s[x]
                r, g, b = palette[idx] if palette and idx < len(palette) else (0, 0, 0)
                al = trns[idx] if trns is not None and idx < len(trns) else 255
            elif ctype == 0:
                v = s[x] if depth >= 8 else s[x] * 255 // ((1 << depth) - 1)
                r = g = b = v
                al = 255
                if trns is not None and len(trns) >= 2 and s[x] == struct.unpack('>H', trns[:2])[0] >> (8 if depth == 16 else 0):
                    al = 0
            elif ctype == 4:
                r = g = b = s[x * 2]; al = s[x * 2 + 1]
            elif ctype == 2:
                r, g, b = s[x * 3:x * 3 + 3]; al = 255
                if trns is not None and len(trns) >= 6:
                    tr = struct.unpack('>HHH', trns[:6])
                    if depth == 16:
                        tr = tuple(t >> 8 for t in tr)
                    if (r, g, b) == tr:
                        al = 0
            else:
                r, g, b, al = s[x * 4:x * 4 + 4]
            out[o:o + 4] = bytes((r, g, b, al))
            o += 4
    return w, h, bytes(out)
