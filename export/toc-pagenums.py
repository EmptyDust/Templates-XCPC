#!/usr/bin/env python3
"""Fill TOC entries with PDF page numbers (Chromium has no target-counter)."""
from __future__ import annotations

import re
import sys
from pathlib import Path
from urllib.parse import unquote


def dest_page_map(pdf_path: Path) -> dict[str, int]:
    from pypdf import PdfReader

    reader = PdfReader(str(pdf_path))
    id2page = {page.indirect_reference.idnum: i for i, page in enumerate(reader.pages, 1)}
    out: dict[str, int] = {}
    for key, dest in (reader.named_destinations or {}).items():
        name = str(key).lstrip("/")
        try:
            decoded = unquote(name)
        except Exception:
            decoded = name
        page = None
        if isinstance(dest, dict):
            page = dest.get("/Page")
        else:
            page = getattr(dest, "page", None)
        pn = id2page.get(getattr(page, "idnum", None))
        if pn:
            out[decoded] = pn
            out[name] = pn
    return out


def lookup(href: str, dests: dict[str, int]) -> int | None:
    if href in dests:
        return dests[href]
    u = unquote(href)
    if u in dests:
        return dests[u]
    best = None
    best_len = 0
    for name, pn in dests.items():
        if href.startswith(name.rstrip("%")) or name.startswith(href):
            if len(name) > best_len:
                best, best_len = pn, len(name)
    return best


def patch_html(html: str, dests: dict[str, int]) -> tuple[str, int, int]:
    pre, sep, rest = html.partition('id="TOC"')
    if not sep:
        return html, 0, 0
    nav, sep2, post = rest.partition("</nav>")
    if not sep2:
        return html, 0, 0

    hit = miss = 0

    def repl(m: re.Match[str]) -> str:
        nonlocal hit, miss
        href, attrs, inner = m.group(1), m.group(2), m.group(3)
        if 'class="toc-page"' in inner:
            return m.group(0)
        pn = lookup(href, dests)
        text = re.sub(r"\s+", " ", inner).strip()
        if pn is None:
            miss += 1
            return m.group(0)
        hit += 1
        return (
            f'<a href="#{href}"{attrs}>'
            f'<span class="toc-text">{text}</span>'
            f'<span class="toc-dots"></span>'
            f'<span class="toc-page">{pn}</span>'
            f"</a>"
        )

    nav2 = re.sub(
        r'<a href="#([^"]+)"([^>]*)>(.*?)</a>',
        repl,
        nav,
        flags=re.S,
    )
    return pre + sep + nav2 + sep2 + post, hit, miss


def main() -> int:
    if len(sys.argv) != 3:
        print("usage: toc-pagenums.py HTML PDF", file=sys.stderr)
        return 2
    html_path = Path(sys.argv[1])
    pdf_path = Path(sys.argv[2])
    dests = dest_page_map(pdf_path)
    html, hit, miss = patch_html(html_path.read_text(encoding="utf-8"), dests)
    html_path.write_text(html, encoding="utf-8")
    print(f"toc page numbers: {hit} filled, {miss} missed")
    return 0 if hit else 1


if __name__ == "__main__":
    raise SystemExit(main())
