"""Generates simple placeholder PNG textures for the prototype (no external art assets available).
Run once during setup: python tools/generate_assets.py
"""
import os
import struct
import zlib

OUT_DIR = os.path.join(os.path.dirname(__file__), "..", "assets")


def _chunk(tag: bytes, data: bytes) -> bytes:
    return (
        struct.pack(">I", len(data))
        + tag
        + data
        + struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF)
    )


def write_png(path: str, width: int, height: int, pixel_fn) -> None:
    raw = bytearray()
    for y in range(height):
        raw.append(0)  # filter type: none
        for x in range(width):
            r, g, b, a = pixel_fn(x, y)
            raw += bytes((r, g, b, a))
    sig = b"\x89PNG\r\n\x1a\n"
    ihdr = struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0)
    idat = zlib.compress(bytes(raw), 9)
    png = sig + _chunk(b"IHDR", ihdr) + _chunk(b"IDAT", idat) + _chunk(b"IEND", b"")
    with open(path, "wb") as f:
        f.write(png)


def solid_with_border(fill, border, border_px=3):
    def fn(x, y, w, h):
        if x < border_px or y < border_px or x >= w - border_px or y >= h - border_px:
            return border
        return fill
    return fn


def circle(fill, border, radius, cx, cy, border_px=2):
    def fn(x, y, w, h):
        dx = x - cx
        dy = y - cy
        dist = (dx * dx + dy * dy) ** 0.5
        if dist > radius:
            return (0, 0, 0, 0)
        if dist > radius - border_px:
            return border
        return fill
    return fn


def make(name, size, fn):
    write_png(os.path.join(OUT_DIR, name), size, size, lambda x, y: fn(x, y, size, size))
    print(f"wrote {name}")


os.makedirs(OUT_DIR, exist_ok=True)

make("floor_tile.png", 64, solid_with_border((70, 55, 65, 255), (55, 42, 50, 255), border_px=2))
make("wall.png", 64, solid_with_border((40, 20, 22, 255), (20, 8, 10, 255), border_px=3))
make("barrel.png", 48, circle((92, 58, 30, 255), (55, 32, 15, 255), radius=22, cx=24, cy=24))
make("player.png", 32, circle((90, 20, 40, 255), (35, 5, 15, 255), radius=15, cx=16, cy=16))
make("station.png", 56, solid_with_border((40, 110, 100, 255), (200, 170, 60, 255), border_px=4))
make("wine_bottle.png", 24, circle((120, 20, 55, 255), (200, 170, 60, 255), radius=10, cx=12, cy=12))
make("king.png", 64, solid_with_border((90, 20, 110, 255), (220, 180, 60, 255), border_px=4))
make("counter.png", 56, solid_with_border((110, 90, 70, 255), (70, 55, 42, 255), border_px=4))

print("done")
