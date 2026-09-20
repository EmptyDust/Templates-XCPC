#!/usr/bin/env python3
"""Replace named /Dest on link annotations with explicit [page /XYZ ...] arrays.

Typst emits CJK heading destinations as a mix of UTF-8 byte names and
PDFDocEncoding text strings. Many viewers fail to resolve those names, so
TOC entries look clickable but do not jump. Sidebar bookmarks already use
direct destinations and are unaffected.
"""
from __future__ import annotations

import sys
from pathlib import Path

from pypdf import PdfReader, PdfWriter
from pypdf.generic import ArrayObject, DictionaryObject, NameObject


def _variants(k):
    yield k
    if isinstance(k, bytes):
        yield k
        for enc in ("utf-8", "latin-1"):
            try:
                yield k.decode(enc)
            except UnicodeDecodeError:
                pass
    else:
        s = str(k)
        yield s
        for enc in ("utf-8", "latin-1"):
            try:
                yield s.encode(enc)
            except UnicodeEncodeError:
                pass


def name_map(root) -> dict:
    names = root.get("/Names")
    if names is None:
        return {}
    dests = names.get_object().get("/Dests")
    if dests is None:
        return {}
    out = {}
    stack = [dests]
    while stack:
        node = stack.pop().get_object()
        stack.extend(node.get("/Kids", []))
        arr = node.get("/Names", [])
        for i in range(0, len(arr), 2):
            k, v = arr[i], arr[i + 1]
            if hasattr(v, "get_object"):
                v = v.get_object()
            if isinstance(v, DictionaryObject) and "/D" in v:
                v = v["/D"].get_object()
            for var in _variants(k):
                out[var] = v
    return out


def already_explicit(dest) -> bool:
    if dest is None:
        return True
    if isinstance(dest, ArrayObject):
        return True
    if isinstance(dest, (str, bytes)):
        return False
    if hasattr(dest, "get_object") and not isinstance(dest, (str, bytes)):
        try:
            obj = dest.get_object()
        except Exception:
            return False
        return isinstance(obj, ArrayObject)
    return False


def flatten(src: Path, dst: Path) -> tuple[int, int]:
    reader = PdfReader(str(src))
    writer = PdfWriter()
    writer.clone_document_from_reader(reader)
    mapping = name_map(writer.root_object)
    replaced = 0
    missing = 0
    for page in writer.pages:
        annots = page.get("/Annots")
        if not annots:
            continue
        for annot in annots:
            obj = annot.get_object()
            if str(obj.get("/Subtype")) != "/Link":
                continue
            owner, key = obj, "/Dest"
            action = obj.get("/A")
            if action is not None and action.get_object().get("/S") == "/GoTo":
                owner, key = action.get_object(), "/D"
            dest = owner.get(key)
            if already_explicit(dest):
                continue
            resolved = mapping.get(dest)
            if resolved is None and isinstance(dest, str):
                resolved = mapping.get(dest.encode("utf-8", "replace"))
                if resolved is None:
                    resolved = mapping.get(dest.encode("latin-1", "replace"))
            if resolved is None:
                missing += 1
                continue
            owner[NameObject(key)] = resolved
            replaced += 1
    writer.write(str(dst))
    return replaced, missing


def main() -> int:
    if len(sys.argv) not in (2, 3):
        print("usage: flatten-pdf-dests.py SRC [DST]", file=sys.stderr)
        return 2
    src = Path(sys.argv[1])
    dst = Path(sys.argv[2]) if len(sys.argv) == 3 else src
    tmp = dst.with_name(dst.name + ".flattening")
    replaced, missing = flatten(src, tmp)
    print(f"flatten-pdf-dests: {replaced} named dests made explicit, {missing} unresolved")
    if missing:
        print(f"unresolved destinations; original retained, diagnostic output: {tmp}", file=sys.stderr)
        return 1
    tmp.replace(dst)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
