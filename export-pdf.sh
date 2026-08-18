#!/bin/sh
# Markdown + LaTeX 数学 → PDF。
# 不走 XeLaTeX / Typora：pandoc 把正文收成 Typst，公式经 mitex 仍按 LaTeX 渲染。
# 用法：
#   ./export-pdf.sh              # 先 build.sh，再导出 build/total.pdf
#   ./export-pdf.sh 博弈论.md    # 导出单章到 build/博弈论.pdf
set -eu
cd "$(dirname "$0")"

if ! command -v pandoc >/dev/null 2>&1; then
    echo "需要 pandoc" >&2
    exit 1
fi
if ! command -v typst >/dev/null 2>&1; then
    echo "需要 typst（当前机器在 ~/.local/bin/typst）" >&2
    exit 1
fi
if ! command -v python3 >/dev/null 2>&1; then
    echo "需要 python3" >&2
    exit 1
fi

src=${1:-total.md}
if [ "$src" = "total.md" ] || [ "$src" = "./total.md" ]; then
    ./build.sh
    src=total.md
fi
if [ ! -f "$src" ]; then
    echo "找不到 $src" >&2
    exit 1
fi

mkdir -p build
base=$(basename "$src" .md)
typ=build/${base}.typ
pdf=build/${base}.pdf

title=$base
if [ "$base" = "total" ]; then
    title="风铃的模板库"
fi

pandoc "$src" \
    --from markdown \
    --to typst \
    --lua-filter=export/mitex.lua \
    --include-in-header=export/preamble.typ \
    --metadata title="$title" \
    -V lang=zh \
    -V papersize=a4 \
    -o "$typ"

python3 - "$typ" <<'PY'
import sys
from pathlib import Path
p = Path(sys.argv[1])
t = p.read_text()
needle = "#show: doc => conf(\n"
if needle not in t:
    sys.exit("export-pdf: pandoc typst 模板里找不到 conf() 调用，无法补中文字体")
if "#show: doc => conf(\n  font:" not in t:
    t = t.replace(
        needle,
        needle
        + '  font: ("Noto Serif CJK SC", "New Computer Modern"),\n'
        + "  fontsize: 9.5pt,\n"
        + "  margin: (x: 12mm, y: 12mm),\n",
        1,
    )
    p.write_text(t)
PY

typst compile "$typ" "$pdf"
echo "$pdf"
