#!/bin/sh
# 导出全书 PDF：typst 直编 main.typ。
# 用法：./export-pdf.sh           # 全书 → build/total.pdf
set -eu
cd "$(dirname "$0")"

mkdir -p build
typst compile --root . --font-path export/vendor/jetbrains-mono main.typ build/total.pdf
python3 export/flatten-pdf-dests.py build/total.pdf
echo "build/total.pdf"
