#!/bin/sh
# md + LaTeX 数学 → HTML → PDF。
# pandoc 只把 Markdown 收成 HTML、把 $...$ 收成 MathJax 能吃的 \(...\)；
# 公式语言不换。打印就是 Chromium 打开这份 HTML。
# 西文/代码用系统 TTF（CID TrueType）；CJK 由 CFF TTC 转成 TTF 再嵌入，
# 避免 Chromium 把 CFF 打成 Type 3 位图。
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

fetch() {
    dest=$1
    url=$2
    if [ -s "$dest" ]; then
        return 0
    fi
    mkdir -p "$(dirname "$dest")"
    echo "拉取 → $dest"
    if ! curl -fsSL --max-time 30 -o "$dest" "$url"; then
        curl -fsSL --max-time 40 --proxy socks5h://192.168.50.213:1233 -o "$dest" "$url"
    fi
}

# MathJax SVG：公式是矢量路径，不依赖网页字体。
fetch export/vendor/tex-svg-full.js \
    https://cdn.jsdelivr.net/npm/mathjax@3.2.2/es5/tex-svg-full.js

# CJK TTC 是 CFF，Chromium 会打成 Type 3。转成 TTF 后按 CID TrueType 嵌入。
fontdir=export/vendor/fonts
mkdir -p "$fontdir"
ensure_cjk() {
    dest=$1
    ttc=$2
    family=$3
    new_family=$4
    if [ -s "$dest" ]; then
        return 0
    fi
    need python3
    echo "转换 $family → $dest"
    python3 export/cff2ttf.py "$ttc" "$dest" "$family" "$new_family"
}
ensure_cjk "$fontdir/NotoSerifCJKsc-Regular.ttf" \
    /usr/share/fonts/opentype/noto/NotoSerifCJK-Regular.ttc "Noto Serif CJK SC" PrintSerifCJK
ensure_cjk "$fontdir/NotoSerifCJKsc-Bold.ttf" \
    /usr/share/fonts/opentype/noto/NotoSerifCJK-Bold.ttc "Noto Serif CJK SC" PrintSerifCJK
ensure_cjk "$fontdir/NotoSansMonoCJKsc-Regular.ttf" \
    /usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc "Noto Sans Mono CJK SC" PrintMonoCJK

mkdir -p build/fonts
cp "$fontdir/NotoSerifCJKsc-Regular.ttf" "$fontdir/NotoSerifCJKsc-Bold.ttf" \
   "$fontdir/NotoSansMonoCJKsc-Regular.ttf" build/fonts/
cp /usr/share/fonts/truetype/noto/NotoSerif-Regular.ttf \
   /usr/share/fonts/truetype/noto/NotoSerif-Bold.ttf \
   /usr/share/fonts/truetype/noto/NotoSerif-Italic.ttf \
   /usr/share/fonts/truetype/noto/NotoSerif-BoldItalic.ttf \
   build/fonts/
cp /usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf \
   /usr/share/fonts/truetype/dejavu/DejaVuSansMono-Bold.ttf \
   /usr/share/fonts/truetype/dejavu/DejaVuSansMono-Oblique.ttf \
   /usr/share/fonts/truetype/dejavu/DejaVuSansMono-BoldOblique.ttf \
   build/fonts/

mkdir -p build
base=$(basename "$src" .md)
html=build/${base}.html
pdf=build/${base}.pdf
title=$base
if [ "$base" = "total" ]; then
    title="风铃的模板库"
fi

cp export/vendor/tex-svg-full.js build/tex-svg-full.js

md=$src
cleanup=$(mktemp)
trap 'rm -f "$cleanup"' EXIT
# Typora 的 [TOC] 只是占位，真正的目录由 --toc 生成。
# 总册标题走 metadata，避免正文 h1 再进目录。
sed -e '/^\[TOC\]$/d' -e '/^# 风铃的模板库$/d' "$src" > "$cleanup"
md=$cleanup

# --mathjax：正文里的数学变成 \(...\)，公式由 SVG 输出。
# tango：浅底高亮，覆盖 pandoc 默认的 Menlo/Consolas。
# --toc：章（##）+ 节（###）。[TOC] 不是 pandoc 语法。
pandoc "$md" \
    --from markdown \
    --to html5 \
    --standalone \
    --template=export/template.html \
    --mathjax \
    --highlight-style=tango \
    --toc \
    --toc-depth=3 \
    --metadata title="$title" \
    --metadata toc-title=目录 \
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
    --font-render-hinting=medium \
    --virtual-time-budget="$budget" \
    --timeout="$timeout" \
    --run-all-compositor-stages-before-draw \
    --print-to-pdf="$(pwd)/$pdf" \
    "file://$(pwd)/$html" >/dev/null
echo "$pdf"
