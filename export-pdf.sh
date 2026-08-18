#!/bin/sh
# md + LaTeX 数学 → HTML → PDF。
# pandoc 只把 Markdown 收成 HTML、把 $...$ 收成 MathJax 能吃的 \(...\)；
# 公式语言不换。打印就是 Chromium 打开这份 HTML。
# 用法：
#   ./export-pdf.sh              # 先 build.sh，再导出 build/total.pdf
#   ./export-pdf.sh 博弈论.md    # 导出单章到 build/博弈论.pdf
set -eu
cd "$(dirname "$0")"

need() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "需要 $1" >&2
        exit 1
    fi
}
need pandoc
need chromium
need curl

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

# --mathjax：正文里的数学变成 \(...\)，不用默认模板里的 polyfill / 系统 MathJax 路径。
pandoc "$src" \
    --from markdown \
    --to html5 \
    --standalone \
    --template=export/template.html \
    --mathjax \
    --metadata title="$title" \
    --include-in-header=export/header.html \
    -o "$html"

budget=20000
timeout=30000
if [ "$base" = "total" ]; then
    budget=180000
    timeout=200000
fi

chromium --headless=new --disable-gpu --no-sandbox --disable-dev-shm-usage \
    --no-pdf-header-footer \
    --virtual-time-budget="$budget" \
    --timeout="$timeout" \
    --run-all-compositor-stages-before-draw \
    --print-to-pdf="$(pwd)/$pdf" \
    "file://$(pwd)/$html" >/dev/null
echo "$pdf"
