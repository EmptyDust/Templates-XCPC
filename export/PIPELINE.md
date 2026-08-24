# Export Pipeline

Rendering chains from Markdown + LaTeX sources to PDF. Typst is the default; the Chromium chain is kept for visual comparison.

## Data flow

```
19 chapter .md ──build.sh──▶ total.md ──pandoc -t typst──▶ .typ (intermediate)
                                                              │
                                    typst-fix.py (patch layer)◀┘
                                                              │
                                    template.typ (layout) + book-mono.tmTheme (highlight theme)
                                                              │
                                                              ▼
                                                    typst compile ──▶ build/*.pdf
```

- `export-pdf.sh` — default export (Typst chain). `./export-pdf.sh` builds the full book → `build/total.pdf`; `./export-pdf.sh 博弈论.md` builds a single chapter.
- `export-pdf-chromium.sh` — legacy Chromium chain (pandoc → HTML + MathML → Chromium print → mutool deflate), kept for rendering comparison.
- `typst-fix.py` — patch layer between pandoc's Typst output and the actual Typst version (see Known pitfalls).
- `template.typ` — all layout: fonts, TOC, page numbers, code blocks, inline-code underline.

Dependencies: `pandoc`, `typst`, `curl` (image cache). No Chromium, no mutool, no font conversion.

## Known pitfalls

Read this section before touching the pipeline. Every entry is a bug that actually happened.

1. **`raw` carries a built-in 0.8em size reduction that multiplies with template em values.** Typst has an internal show-set rule shrinking raw text to 0.8em; `set text(size: 0.75em)` yields 0.75 × 0.8 × body size. To express "x times body size", write x/0.8 (see comments in template.typ). Absolute pt values override the default instead.

2. **JetBrains Mono ligatures bypass syntect highlighting.** `ligatures: false` does not apply to highlighted fragments; `<=` renders as `≤`. The OpenType features themselves must be disabled (`features: (liga: 0, ...)`).

3. **pandoc drops raw HTML.** `<img src=...>` tags never reach the Typst output; images vanish silently. Preprocessing rewrites HTML images into Markdown image syntax before conversion.

4. **The `/END/` page-break marker gets wrapped as `#block[/END/]` by pandoc.** A naive replacement produces `#block[#pagebreak()]`, which is an illegal container pagebreak. Replace the whole block and use a weak pagebreak to avoid a trailing blank page.

5. **Image hotlinking and format lies.** zhimg requires a Referer header; one `.png` is actually WebP and must be converted by content sniffing. Images are cached in `build/images/`; the export never fetches them online at render time.

6. **Symbol-table drift between pandoc's Typst writer and Typst itself.** pandoc emits the old symbol table; newer Typst renamed symbols: `sect`→`inter`, `angle.l`→`chevron.l`, `times.circle` is invalid, etc. Each rule in `typst-fix.py` covers one class. **After upgrading pandoc or typst, rebuild the whole book and check for new warnings.**

7. **Never wrap code-block content in `par()`.** It swallows the entire raw block (all 373 code blocks disappeared once). Set paragraph properties inside the block with `set par(...)` instead.

## Upgrade procedure

After upgrading pandoc / typst:

```sh
./export-pdf.sh            # full rebuild; compile warnings signal a broken patch rule
```

Then spot-compare pages against the previous PDF (formula-dense pages, code-dense pages, image pages, TOC). Add new drift fixes to `typst-fix.py`, one rule per class, with a comment stating what it patches.

## Archives

- Tag `archive/chromium-final` — the last state where md+LaTeX content was final and the Chromium chain was the default export.
- The final Chromium-chain PDF can be rebuilt anytime with `./export-pdf-chromium.sh`.

## Known cosmetic quirks

- `pdfinfo` (poppler) prints `Syntax Error: Suspects object is wrong type (boolean)` on Typst-produced PDFs. The entry is `/MarkInfo/Suspects false`, which is spec-valid boolean for tagged PDF; poppler emits a spurious strictness warning. Ghostscript, mutool, pdftotext, pdffonts all read the file cleanly. Benign.
