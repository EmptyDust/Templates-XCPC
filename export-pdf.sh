#!/bin/sh
# 导出全书 PDF：typst 直编 main.typ，顺带一张单独封面。
# 用法：./export-pdf.sh
# 产物：build/风铃的模板库-YYYY-MM-DD-<git短哈希>.pdf
#       build/封面-YYYY-MM-DD-<git短哈希>.pdf
# 工作区有未提交改动时哈希带 -dirty。两份文件同一日期哈希。
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
cover="build/封面-${stamp}-${rev}.pdf"

font_path=
if [ -d export/vendor/jetbrains-mono ]; then
  font_path="--font-path export/vendor/jetbrains-mono"
fi

mkdir -p build/export-logs
compile() {
  log=$1
  shift
  if ! typst compile --root . $font_path "$@" 2>"$log"; then
    cat "$log" >&2
    exit 1
  fi
  if grep -qi 'unknown font family' "$log"; then
    cat "$log" >&2
    echo "缺少所需字体，导出未通过检查" >&2
    exit 1
  fi
  cat "$log" >&2
}

compile build/export-logs/book.log \
  --input stamp="$stamp" --input rev="$rev" \
  main.typ "$out"
compile build/export-logs/cover.log \
  --input stamp="$stamp" --input rev="$rev" \
  export/cover.typ "$cover"
python3 export/flatten-pdf-dests.py "$out"
python3 tools/check_pdf.py --links "$out" "$cover"

echo "$out"
echo "$cover"
