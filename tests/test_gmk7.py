"""Tests for the GameMaker 7 reader helpers (cipher and BMP decoding)."""
import os
import struct
import unittest

from gm_revive.gmk import _gm7_decode_table, _gm7_decrypt, _bmp_to_bgra, detect


def encode_table(seed):
    """Inverse of the decode table: what GameMaker 7 used to write files."""
    dec = _gm7_decode_table(seed)
    enc = [0] * 256
    for plain, cipher in enumerate(dec):
        enc[cipher] = plain
    return enc


def make_gm7(payload, seed=12345, s1=3, s2=5):
    header = struct.pack('<ii', 1234321, 702) + struct.pack('<ii', s1, s2)
    header += b'\x11' * (s1 * 4) + struct.pack('<i', seed) + b'\x22' * (s2 * 4)
    enc = encode_table(seed)
    start = len(header)
    out = bytearray(header + payload)
    for i in range(start + 1, len(out)):          # first byte of the payload stays in the clear
        out[i] = enc[(payload[i - start] + i) & 0xFF]
    return bytes(out), start


def bmp(w, h, bpp, pixel_rows, palette=None):
    """Build a bottom-up BMP from top-down rows of bytes."""
    stride = ((w * bpp + 31) // 32) * 4
    data = b''.join(row.ljust(stride, b'\0') for row in reversed(pixel_rows))
    pal = b''.join(c + b'\0' for c in (palette or []))
    off = 14 + 40 + len(pal)
    info = struct.pack('<IiiHHIIiiII', 40, w, h, 1, bpp, 0, len(data), 0, 0, len(palette or []), 0)
    return b'BM' + struct.pack('<IHHI', off + len(data), 0, 0, off) + info + pal + data


class CipherTests(unittest.TestCase):
    def test_decode_table_is_a_permutation(self):
        for seed in (0, 1, 249, 250, 6309, 99999):
            dec = _gm7_decode_table(seed)
            self.assertEqual(sorted(dec), list(range(256)))

    def test_decrypt_round_trip(self):
        payload = bytes(range(256)) * 4 + b'hello GameMaker 7'
        data, start = make_gm7(payload)
        plain, p = _gm7_decrypt(data)
        self.assertEqual(p, start)
        self.assertEqual(plain[p:], payload)

    def test_detect_reports_gm7(self):
        import tempfile
        data, _ = make_gm7(b'\0' * 64)
        with tempfile.NamedTemporaryFile(suffix='.gmk', delete=False) as fh:
            fh.write(data)
        try:
            self.assertEqual(detect(fh.name), ('GameMaker 7', 702))
        finally:
            os.unlink(fh.name)


class BmpTests(unittest.TestCase):
    def test_24bit_with_transparency_key(self):
        # 2x2 image; bottom-left pixel (magenta) is the transparent colour
        rows = [b'\x00\x00\xff' + b'\x00\xff\x00', b'\xff\x00\xff' + b'\xff\x00\x00']
        w, h, px = _bmp_to_bgra(bmp(2, 2, 24, rows), transparent=True)
        self.assertEqual((w, h), (2, 2))
        self.assertEqual(px[0:4], b'\x00\x00\xff\xff')     # top-left red, opaque
        self.assertEqual(px[8:12], b'\xff\x00\xff\x00')    # bottom-left magenta, transparent
        self.assertEqual(px[12:16], b'\xff\x00\x00\xff')

    def test_8bit_palette(self):
        palette = [b'\x10\x20\x30', b'\x40\x50\x60']
        rows = [bytes([0, 1, 1]), bytes([1, 0, 0])]
        w, h, px = _bmp_to_bgra(bmp(3, 2, 8, rows, palette), transparent=False)
        self.assertEqual(px[0:4], b'\x10\x20\x30\xff')
        self.assertEqual(px[4:8], b'\x40\x50\x60\xff')
        self.assertEqual(px[12:16], b'\x40\x50\x60\xff')


if __name__ == '__main__':
    unittest.main()
