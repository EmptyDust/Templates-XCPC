# Export Pipeline

Native Typst structure. The book is written directly in Typst; there is no intermediate format and no conversion layer.

## Data flow

```
main.typ ──#include──▶ chapters/*.typ ──include-code──▶ code/**/*.cpp
    │                        │
theme.typ (layout)     images/ (localized)
prelude.typ (macros)         │
    └──────── typst compile ─┴──▶ build/total.pdf
```

- `main.typ` — entry: explicit chapter include list, cover merged into TOC page, page numbers counted from body.
- `theme.typ` — all layout: fonts, headings, code blocks, inline-code underline, running head, TOC style.
- `prelude.typ` — macros: `#O(...)` complexity notation, `include-code` (reads a `.cpp` file and renders the region between `// @book-begin` / `// @book-end` markers, dedented).
- `export/book-mono.tmTheme` — near-monochrome syntax highlighting theme (keyword = bold, string/number = mid gray, comment = light gray).
- `export/powershell.sublime-syntax` — minimal PowerShell syntax definition (Typst has none built in), vendored for the few powershell blocks in 杂项.
- `export/vendor/jetbrains-mono/` — vendored code font (from the Debian package, unpacked locally); passed via `--font-path`.

Dependency: `typst`. Build is a single `typst compile`; `export-pdf.sh` is a thin wrapper.

## Known pitfalls

Read this section before touching the theme. Every entry is a bug that actually happened.

1. **`raw` carries a built-in 0.8em size reduction that multiplies with template em values.** Typst has an internal show-set rule shrinking raw text to 0.8em; `set text(size: 0.75em)` yields 0.75 × 0.8 × body size. To express "x times body size", write x/0.8 (see comments in theme.typ). Absolute pt values override the default instead.

2. **JetBrains Mono ligatures bypass syntect highlighting.** `ligatures: false` does not apply to highlighted fragments; `<=` renders as `≤`. The OpenType features themselves must be disabled (`features: (liga: 0, ...)`).

3. **Typst 0.15 treats multi-letter math identifiers as variable references.** `Sum_N` is an error, not italic text; write space-separated letters (`S u m_N`) or `upright(...)`. The compiler itself suggests the fix.

4. **Extracted code must stay compilable.** Files under `code/` are checked by `g++ -std=gnu++20 -fsyntax-only` in check.sh. Book-only fragments (macros, undefined helpers) belong outside the `@book-begin`/`@book-end` region or stay inline in the chapter.

5. **pdfinfo (poppler) prints `Syntax Error: Suspects object is wrong type (boolean)` on Typst-produced PDFs.** The entry is `/MarkInfo/Suspects false`, which is spec-valid boolean for tagged PDF; poppler emits a spurious strictness warning. Ghostscript, mutool, pdftotext, pdffonts all read the file cleanly. Benign.

## Upgrade procedure

After upgrading typst, rebuild the whole book and run the gate:

```sh
./check.sh
```

Then spot-compare pages against the previous PDF (formula-dense, code-dense, image pages, TOC).

## Archives

- Tag `archive/chromium-final` — the last state where md+LaTeX was the content source and the Chromium chain was the default export. The md era and both legacy pipelines (pandoc→Typst, pandoc→HTML→Chromium) live in git history before the native migration.
