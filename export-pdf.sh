#!/bin/sh
# 导出全书 PDF：typst 直编 main.typ。
# 用法：./export-pdf.sh
# 产物：build/风铃的模板库-YYYY-MM-DD-<git短哈希>.pdf
# 工作区有未提交改动时哈希带 -dirty。封面与 PDF 元数据带同一日期。
set -eu
cd "$(dirname "$0")"

mkdir -p build
stamp=$(date +%Y-%m-%d)
rev=unknown
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  rev=$(git rev-parse --short HEAD)
  if ! git diff --quiet || ! git diff --cached --quiet; then
    rev="${rev}-dirty"
  fi
fi
out="build/风铃的模板库-${stamp}-${rev}.pdf"

font_path=
if [ -d export/vendor/jetbrains-mono ]; then
  font_path="--font-path export/vendor/jetbrains-mono"
fi

typst compile --root . $font_path \
  --input stamp="$stamp" --input rev="$rev" \
  main.typ "$out"
python3 export/flatten-pdf-dests.py "$out"
echo "$out"
