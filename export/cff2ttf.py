#!/usr/bin/env python3
"""Extract a named font from a TTC/OTF (CFF) and write a TrueType TTF.

Chromium's Skia PDF embeds TTF as CID TrueType (vector). CFF/OTC becomes
Type 3 bitmaps and looks soft when zoomed or printed.
"""
from __future__ import annotations

import sys
from pathlib import Path

from fontTools.pens.cu2quPen import Cu2QuPen
from fontTools.pens.ttGlyphPen import TTGlyphPen
from fontTools.ttLib import TTCollection, TTFont, newTable

MAX_ERR = 1.0


def _open_named(src: Path, family: str | None) -> TTFont:
    raw = src.read_bytes()[:4]
    if raw == b"ttcf":
        col = TTCollection(str(src))
        if family is None:
            return col.fonts[0]
        for font in col.fonts:
            name = font["name"].getDebugName(1) or ""
            if name == family:
                return font
        have = [f["name"].getDebugName(1) for f in col.fonts]
        raise SystemExit(f"no family {family!r} in {src}; have {have}")
    return TTFont(str(src))


def rename_family(font: TTFont, family: str) -> None:
    """Avoid colliding with system CFF/OTC of the same PostScript name."""
    table = font["name"]
    ps = "".join(family.split())
    for nid in (1, 4, 16):
        table.setName(family, nid, 3, 1, 0x409)
    table.setName(ps, 6, 3, 1, 0x409)


def cff_to_ttf(font: TTFont) -> None:
    if "CFF " not in font:
        return
    order = font.getGlyphOrder()
    gs = font.getGlyphSet()
    glyf = newTable("glyf")
    glyf.glyphOrder = order
    glyf.glyphs = {}
    for name in order:
        pen = TTGlyphPen(gs)
        gs[name].draw(Cu2QuPen(pen, MAX_ERR, reverse_direction=True))
        glyf.glyphs[name] = pen.glyph()
    del font["CFF "]
    if "VORG" in font:
        del font["VORG"]
    font["glyf"] = glyf
    font["loca"] = newTable("loca")
    font.sfntVersion = "\x00\x01\x00\x00"
    mp = font["maxp"]
    mp.tableVersion = 0x00010000
    for attr, val in (
        ("maxZones", 2),
        ("maxTwilightPoints", 0),
        ("maxStorage", 0),
        ("maxFunctionDefs", 0),
        ("maxInstructionDefs", 0),
        ("maxStackElements", 0),
        ("maxSizeOfInstructions", 0),
        ("maxComponentElements", 0),
        ("maxComponentDepth", 0),
    ):
        if not hasattr(mp, attr):
            setattr(mp, attr, val)


def main() -> None:
    if len(sys.argv) < 3:
        print("usage: cff2ttf.py SRC DST [FAMILY] [NEW_FAMILY]", file=sys.stderr)
        raise SystemExit(2)
    src = Path(sys.argv[1])
    dst = Path(sys.argv[2])
    family = sys.argv[3] if len(sys.argv) > 3 else None
    new_family = sys.argv[4] if len(sys.argv) > 4 else None
    dst.parent.mkdir(parents=True, exist_ok=True)
    font = _open_named(src, family)
    cff_to_ttf(font)
    if new_family:
        rename_family(font, new_family)
    font.save(str(dst))


if __name__ == "__main__":
    main()
