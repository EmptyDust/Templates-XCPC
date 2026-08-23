#!/bin/sh
# md + LaTeX 数学 → HTML → PDF。
# pandoc 把 Markdown 收成 HTML、$...$ 收成 MathML；公式语言不换。
# 打印就是 Chromium 打开这份 HTML，原生 MathML 排版，真文本可选中。
# 西文/代码/数学用 TTF（CID TrueType）；CJK 由 CFF TTC 转成 TTF 再嵌入，
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

# 数学走 pandoc --mathml + Chromium 原生 MathML，不用 MathJax。
# 数学字体 TeX Gyre Termes Math：Times 系，笔画与 Noto Serif 正文相配；
# 系统是 CFF OTF，转成 TTF 后 Chromium 才能打成 CID TrueType。

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
ensure_cjk "$fontdir/TeXGyreTermesMath-Regular.ttf" \
    /usr/share/texmf/fonts/opentype/public/tex-gyre-math/texgyretermes-math.otf "TeX Gyre Termes Math" PrintMath

mkdir -p build/fonts
cp "$fontdir/NotoSerifCJKsc-Regular.ttf" "$fontdir/NotoSerifCJKsc-Bold.ttf" \
   "$fontdir/NotoSansMonoCJKsc-Regular.ttf" "$fontdir/TeXGyreTermesMath-Regular.ttf" \
   build/fonts/
cp /usr/share/fonts/truetype/noto/NotoSerif-Regular.ttf \
   /usr/share/fonts/truetype/noto/NotoSerif-Bold.ttf \
   /usr/share/fonts/truetype/noto/NotoSerif-Italic.ttf \
   /usr/share/fonts/truetype/noto/NotoSerif-BoldItalic.ttf \
   build/fonts/
# JetBrains Mono：代码西文。取 Debian 包，apt 下载后本地解包（不安装、无需 root）。
jbm=export/vendor/jetbrains-mono
if [ ! -s "$jbm/JetBrainsMono-Regular.ttf" ]; then
    need apt-get
    need dpkg-deb
    echo "抽取 fonts-jetbrains-mono → $jbm"
    tmpd=$(mktemp -d)
    (cd "$tmpd" && apt-get download fonts-jetbrains-mono >/dev/null 2>&1)
    dpkg-deb -x "$tmpd"/fonts-jetbrains-mono_*_all.deb "$tmpd/x"
    mkdir -p "$jbm"
    for f in Regular Bold Italic BoldItalic; do
        cp "$tmpd/x/usr/share/fonts/truetype/jetbrains-mono/JetBrainsMono-$f.ttf" "$jbm/"
    done
    rm -rf "$tmpd"
fi
cp "$jbm/JetBrainsMono-Regular.ttf" "$jbm/JetBrainsMono-Bold.ttf" \
   "$jbm/JetBrainsMono-Italic.ttf" "$jbm/JetBrainsMono-BoldItalic.ttf" \
   build/fonts/

mkdir -p build
base=$(basename "$src" .md)
html=build/${base}.html
pdf=build/${base}.pdf
title=$base
if [ "$base" = "total" ]; then
    title="风铃的模板库"
fi

md=$src
cleanup=$(mktemp)
trap 'rm -f "$cleanup"' EXIT
# Typora 的 [TOC] 只是占位，真正的目录由 --toc 生成。
# 总册标题走 metadata，避免正文 h1 再进目录。
sed -e '/^\[TOC\]$/d' -e '/^# 风铃的模板库$/d' "$src" > "$cleanup"
md=$cleanup

# --mathml：正文公式直接转 MathML，Chromium 原生排版，真文本可选中。
# tango：浅底高亮，覆盖 pandoc 默认的 Menlo/Consolas。
# --toc：章（##）+ 节（###）。[TOC] 不是 pandoc 语法。
pandoc "$md" \
    --from markdown \
    --to html5 \
    --standalone \
    --template=export/template.html \
    --mathml \
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

print_pdf() {
    chromium --headless=new --disable-gpu --no-sandbox --disable-dev-shm-usage \
        --no-pdf-header-footer \
        --font-render-hinting=medium \
        --virtual-time-budget="$budget" \
        --timeout="$timeout" \
        --run-all-compositor-stages-before-draw \
        --print-to-pdf="$(pwd)/$pdf" \
        "file://$(pwd)/$html" >/dev/null
}

print_pdf
# Chromium 不支持 target-counter：先出一版拿到锚点页码，写进目录再打一次。
if python3 export/toc-pagenums.py "$html" "$(pwd)/$pdf"; then
    print_pdf
fi

# Chromium/Skia 写出的流几乎不压缩：CJK 子集和 SVG 公式路径会到二十多 MB。
# mutool 只做 deflate / 对象流 / 再子集，不重渲染。
if command -v mutool >/dev/null 2>&1; then
    tmppdf=$(mktemp --suffix=.pdf)
    if mutool clean -gg -z -f -i -t -Z -S "$(pwd)/$pdf" "$tmppdf"; then
        mv "$tmppdf" "$(pwd)/$pdf"
    else
        rm -f "$tmppdf"
    fi
fi
echo "$pdf"
