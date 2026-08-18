#!/bin/sh
# Markdown + LaTeX 数学 → HTML（MathJax）→ Chromium 打 PDF。
# 不走 Typora / XeLaTeX / Typst。
# 用法：
#   ./export-pdf.sh              # 先 build.sh，再导出 build/total.pdf
#   ./export-pdf.sh 博弈论.md    # 导出单章到 build/博弈论.pdf
set -eu
cd "$(dirname "$0")"

if ! command -v pandoc >/dev/null 2>&1; then
    echo "需要 pandoc" >&2
    exit 1
fi
if ! command -v chromium >/dev/null 2>&1; then
    echo "需要 chromium" >&2
    exit 1
fi
if ! command -v python3 >/dev/null 2>&1; then
    echo "需要 python3" >&2
    exit 1
fi
if ! command -v curl >/dev/null 2>&1; then
    echo "需要 curl（首次拉取 MathJax）" >&2
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

vendor=export/vendor/tex-chtml-full.js
if [ ! -s "$vendor" ]; then
    mkdir -p export/vendor
    url=https://cdn.jsdelivr.net/npm/mathjax@3.2.2/es5/tex-chtml-full.js
    echo "拉取 MathJax → $vendor"
    if ! curl -fsSL --max-time 30 -o "$vendor" "$url"; then
        curl -fsSL --max-time 40 --proxy socks5h://192.168.50.213:1233 -o "$vendor" "$url"
    fi
fi

mkdir -p build
base=$(basename "$src" .md)
html=build/${base}.html
pdf=build/${base}.pdf
title=$base
if [ "$base" = "total" ]; then
    title="风铃的模板库"
fi

cp "$vendor" build/tex-chtml-full.js

pandoc "$src" \
    --from markdown \
    --to html \
    --standalone \
    --mathjax \
    --metadata title="$title" \
    --include-in-header=export/header.html \
    -o "$html"

python3 - "$html" <<'PY'
import re
import sys
from pathlib import Path
p = Path(sys.argv[1])
t = p.read_text()
t = re.sub(r'<script src="https://polyfill\.io[^"]*"></script>\s*', "", t)
t = re.sub(
    r'<script src="/usr/share/javascript/mathjax/MathJax\.js"\s*type="text/javascript"></script>\s*',
    "",
    t,
)
t = t.replace('lang=""', 'lang="zh-CN"', 1)
p.write_text(t)
PY

budget=20000
timeout=30000
if [ "$base" = "total" ]; then
    budget=180000
    timeout=200000
fi

html_abs=$(pwd)/$html
pdf_abs=$(pwd)/$pdf
chromium --headless=new --disable-gpu --no-sandbox --disable-dev-shm-usage \
    --no-pdf-header-footer \
    --virtual-time-budget="$budget" \
    --timeout="$timeout" \
    --run-all-compositor-stages-before-draw \
    --print-to-pdf="$pdf_abs" \
    "file://$html_abs" >/dev/null
echo "$pdf"
