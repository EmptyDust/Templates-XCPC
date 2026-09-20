# Export Pipeline

Native Typst structure. The book is written directly in Typst; there is no intermediate format and no conversion layer.

## Data flow

```
main.typ ──#include──▶ chapters/*.typ ──include-code──▶ code/**/*.cpp
    │                        │
theme.typ (layout)     images/ (localized)
prelude.typ (macros)         │
    └──────── typst compile ─┴──▶ build/风铃的模板库-YYYY-MM-DD-<hash>.pdf
                                 build/封面-YYYY-MM-DD-<hash>.pdf
```

- `main.typ` — entry: explicit chapter include list, cover merged into TOC page, page numbers counted from body.
- `theme.typ` — all layout: fonts, headings, code blocks, inline-code underline, running head, TOC style.
- `prelude.typ` — macros: `#O(...)` complexity notation, `include-code` (reads a `.cpp` file and renders the region between `// @book-begin` / `// @book-end` markers, dedented).
- `export/book-mono.tmTheme` — near-monochrome syntax highlighting theme (keyword = bold, string/number = mid gray, comment = light gray).
- `export/powershell.sublime-syntax` — minimal PowerShell syntax definition (Typst has none built in), vendored for the few powershell blocks in 杂项.
- `export/cover.typ` — standalone print cover (title + stamp); not part of the book page count.
- `export/vendor/jetbrains-mono/` — vendored code font (from the Debian package, unpacked locally); passed via `--font-path`.

Dependencies: Typst 0.15.1, Python 3 with pypdf (Debian/Ubuntu: `python3-pypdf`), Poppler (`poppler-utils`), and the font packages listed in README. GCC with GNU C++20 support is also required by `check.sh`. `export-pdf.sh` compiles the book, flattens TOC dests, and compiles `export/cover.typ` with the same date and git short hash (plus `-dirty` for tracked changes). The stamp is also passed into `main.typ` for the TOC-page line and PDF metadata. Untracked local notes do not affect it. Both PDFs are checked for Type 3 fonts and invalid internal destinations. Missing-font warnings fail export; compiler diagnostics are retained in `build/export-logs/`. `check.sh` and CI use this same export path, and CI uploads the PDFs and check logs.

## Known pitfalls

Read this section before touching the theme. Every entry is a bug that actually happened.

1. **`raw` carries a built-in 0.8em size reduction that multiplies with template em values.** Typst has an internal show-set rule shrinking raw text to 0.8em; `set text(size: 0.75em)` yields 0.75 × 0.8 × body size. To express "x times body size", write x/0.8 (see comments in theme.typ). Absolute pt values override the default instead.

2. **JetBrains Mono ligatures bypass syntect highlighting.** `ligatures: false` does not apply to highlighted fragments; `<=` renders as `≤`. The OpenType features themselves must be disabled (`features: (liga: 0, ...)`).

3. **Typst 0.15 treats multi-letter math identifiers as variable references.** `Sum_N` is an error, not italic text; write space-separated letters (`S u m_N`) or `upright(...)`. The compiler itself suggests the fix.

4. **Extracted code must stay compilable.** Files under `code/` are checked by `g++ -std=gnu++20 -fsyntax-only` in check.sh. Standalone syntax checking does not establish that the printed region compiles. Regression tests extract the actual printed blocks, supply only documented dependencies, instantiate their interfaces, and run the complete usage examples. Inline code needs the same checks. Synchronize registered editor snippets with `python3 tools/sync_snippets.py --write`.

5. **pdfinfo (poppler) prints `Syntax Error: Suspects object is wrong type (boolean)` on Typst-produced PDFs.** The entry is `/MarkInfo/Suspects false`, which is spec-valid boolean for tagged PDF; poppler emits a spurious strictness warning. Ghostscript, mutool, pdftotext, pdffonts all read the file cleanly. Benign.

6. **TOC clicks fail on CJK entries.** Typst stores outline links as named destinations, mixing UTF-8 byte names and PDFDocEncoding strings. Viewers often resolve `bitset` and miss `判断非递减 is_sorted`. `export/flatten-pdf-dests.py` rewrites those `/Dest` names to explicit `[page /XYZ …]` arrays after compile. Sidebar bookmarks already use direct dests and do not need this.

## Upgrade procedure

After upgrading typst, rebuild the whole book and run the gate:

```sh
./check.sh
```

Then spot-compare pages against the previous PDF (formula-dense, code-dense, image pages, TOC).

## Archives

- Tag `archive/chromium-final` — the last state where md+LaTeX was the content source and the Chromium chain was the default export. The md era and both legacy pipelines (pandoc→Typst, pandoc→HTML→Chromium) live in git history before the native migration.
