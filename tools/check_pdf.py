#!/usr/bin/env python3
"""检查 PDF 字体；--links 还检查内部链接和书签是否指向有效页面。"""
import argparse
import re
import subprocess
import sys


def check(path):
    result = subprocess.run(["pdffonts", str(path)], capture_output=True, text=True)
    if result.returncode:
        raise RuntimeError(f"{path}: pdffonts 失败\n{result.stderr}")
    type3 = [line for line in result.stdout.splitlines()[2:]
             if re.search(r"^\S+\s+Type\s+3\s+", line)]
    if type3:
        raise RuntimeError(f"{path}: 含 Type 3 字体\n" + "\n".join(type3))


def check_links(path):
    from pypdf import PdfReader
    from pypdf.generic import ArrayObject, IndirectObject

    reader = PdfReader(str(path))
    pages = {(p.indirect_reference.idnum, p.indirect_reference.generation) for p in reader.pages}
    if not pages:
        raise RuntimeError(f"{path}: PDF 没有页面")

    def destination(dest):
        dest = dest.get_object() if hasattr(dest, "get_object") else dest
        if not isinstance(dest, ArrayObject) or len(dest) < 2:
            raise RuntimeError(f"{path}: 内部链接目的地未展开或格式错误：{dest!r}")
        page = dest[0]
        if not isinstance(page, IndirectObject) or (page.idnum, page.generation) not in pages:
            raise RuntimeError(f"{path}: 内部链接指向不存在的页面：{page!r}")

    def link(obj):
        if "/Dest" in obj:
            destination(obj["/Dest"])
        action = obj.get("/A")
        if action is not None:
            action = action.get_object()
            if action.get("/S") == "/GoTo":
                destination(action.get("/D"))

    for page in reader.pages:
        for annotation in page.get("/Annots", []):
            obj = annotation.get_object()
            if obj.get("/Subtype") == "/Link":
                link(obj)
    outline = reader.trailer["/Root"].get("/Outlines")
    stack = [outline.get_object().get("/First")] if outline is not None else []
    while stack:
        ref = stack.pop()
        if ref is None:
            continue
        obj = ref.get_object()
        link(obj)
        stack.extend([obj.get("/First"), obj.get("/Next")])


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--links", action="store_true")
    parser.add_argument("paths", nargs="+")
    args = parser.parse_args()
    try:
        for path in args.paths:
            check(path)
            if args.links:
                check_links(path)
    except (OSError, RuntimeError) as error:
        raise SystemExit(str(error))
