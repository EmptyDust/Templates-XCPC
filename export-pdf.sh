#!/usr/bin/env bash
# Typst 导出管线：md+LaTeX → pandoc(texmath→typst) → 修正层 → typst compile
# 与 export-pdf.sh（Chromium 管线）并行，产物 build/total.pdf
set -euo pipefail
cd "$(dirname "$0")"

BUILD=build
mkdir -p "$BUILD/images"
need() { command -v "$1" >/dev/null || { echo "缺工具: $1" >&2; exit 1; }; }
need pandoc
need typst

# 单章模式：./export-pdf.sh 博弈论.md
if [ $# -ge 1 ]; then
    SRC="$BUILD/$(basename "$1" .md).typst.md"
    sed -e 's/^\[TOC\]$//' "$1" > "$SRC"
    OUT="$BUILD/$(basename "$1" .md)"
else
    ./build.sh
    SRC="$BUILD/total.typst.md"
    sed -e 's/^# 风铃的模板库$//' -e 's/^\[TOC\]$//' total.md > "$SRC"
    OUT="$BUILD/total"
fi

# 外链图片缓存到 build/images/ 并改写为相对路径（typst 不抓 URL）
python3 - "$SRC" << 'PY'
import re, subprocess, sys, os
path = sys.argv[1]
t = open(path, encoding='utf-8').read()
os.makedirs('build/images', exist_ok=True)
urls = []
def local(url):
    if url not in urls:
        urls.append(url)
    return f'images/img-{urls.index(url)+1:02d}.png'
# pandoc 的 typst writer 丢弃 raw HTML：<img> 标签先改写成 markdown 图片语法
t = re.sub(r'<img\s+src="(https?://[^"]+)"[^>]*>', lambda m: f'![]({local(m.group(1))})', t)
t = re.sub(r'src="(https?://[^"]+)"', lambda m: f'src="{local(m.group(1))}"', t)
t = re.sub(r'(!\[[^\]]*\]\()(https?://[^)]+)(\))', lambda m: m.group(1) + local(m.group(2)) + m.group(3), t)
open(path, 'w', encoding='utf-8').write(t)
for i, u in enumerate(urls, 1):
    dst = f'build/images/img-{i:02d}.png'
    if os.path.exists(dst):
        continue
    print('下载', u)
    # 防盗链 CDN（如 zhimg）需要 Referer/UA；Referer 按目标域名生成
    from urllib.parse import urlparse
    host = urlparse(u).netloc
    base = ['curl', '-fsSL', '--retry', '2',
            '-H', 'User-Agent: Mozilla/5.0', '-H', f'Referer: https://{host}/']
    try:
        subprocess.run(base + ['-o', dst, u], check=True)
    except subprocess.CalledProcessError:
        subprocess.run(base + ['--proxy', 'socks5h://192.168.50.213:1233', '-o', dst, u], check=True)
    # 有些 URL 给的是 webp 但按 .png 存，typst 只认真实格式，统一转 PNG
    with open(dst, 'rb') as f:
        magic = f.read(12)
    if not magic.startswith(b'\x89PNG'):
        from PIL import Image
        Image.open(dst).convert('RGB').save(dst)
PY

# pandoc → typst，修正层，拼模板
pandoc -f markdown -t typst --wrap=none "$SRC" -o "$OUT.body.typ"
python3 export/typst-fix.py "$OUT.body.typ" "$OUT.body.typ"
cp export/book-mono.tmTheme "$BUILD/"
sed 's|export/book-mono.tmTheme|book-mono.tmTheme|' export/template.typ > "$OUT.typ"
cat "$OUT.body.typ" >> "$OUT.typ"

typst compile --root . --font-path export/vendor/jetbrains-mono "$OUT.typ" "$OUT.pdf"
echo "$OUT.pdf"
