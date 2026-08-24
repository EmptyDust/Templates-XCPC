#!/bin/sh
# check.sh —— 书的完整性闸。改动后跑一遍，全过才算没破版。
# 原生 Typst 结构：语法/引用/锚点/脚注由 typst 编译器校验；
# 本脚本只查编译器视野之外的东西。
set -u
cd "$(dirname "$0")"
fail=0

say() { printf '%s %s\n' "$1" "$2"; }
bad() { say "FAIL" "$1"; fail=1; }
ok()  { say " ok " "$1"; }

# 1. 入口可编译：typst compile 本身就是闸门（语法、引用、文件读取全校验）
mkdir -p build
if typst compile --root . --font-path export/vendor/jetbrains-mono main.typ build/.check-book.pdf 2>build/.check-typst.log; then
    ok "main.typ 可编译"
else
    bad "main.typ 编译失败（见 build/.check-typst.log）"
fi
rm -f build/.check-book.pdf

# 2. 孤儿章：chapters/ 里每个 .typ 必须被 main.typ include（漏 include 不报错，只会静默消失）
orphan=0
for f in chapters/*.typ; do
    grep -qF "#include \"$f\"" main.typ || { bad "$f: 未被 main.typ include"; orphan=1; }
done
[ $orphan -eq 0 ] && ok "无孤儿章"

# 3. 抽取的板子：code/ 里每个 .cpp 必须过 g++ 语法检查
cppbad=0
for f in $(find code -name '*.cpp'); do
    g++ -std=gnu++20 -fsyntax-only "$f" 2>build/.check-gpp.log || { bad "$f: g++ 语法检查失败（见 build/.check-gpp.log）"; cppbad=1; }
done
[ $cppbad -eq 0 ] && ok "code/ 全部通过 g++ -fsyntax-only"

# 4. 目录级标题宽度：= / == 标题按 CJK=2、ASCII=1 计，须 ≤ 38（目录不折行的实测边界）
python3 - <<'PY' && ok "目录级标题宽度 ≤ 38" || bad "超宽标题（见上）"
import glob, sys
bad = []
for fn in glob.glob('chapters/*.typ'):
    for i, line in enumerate(open(fn, encoding='utf-8'), 1):
        s = line.strip()
        if s.startswith('= ') or s.startswith('== '):
            t = s.lstrip('=').strip()
            w = sum(2 if ord(c) > 0x2E7F else 1 for c in t)
            if w > 38: bad.append(f'{fn}:{i}: 宽 {w}: {t}')
print('\n'.join(bad)) if bad else None
sys.exit(1 if bad else 0)
PY

# 5. 图片引用：image("/images/...") 的文件必须存在
python3 - <<'PY' && ok "图片引用存在" || bad "缺图（见上）"
import glob, os, re, sys
missing = []
for fn in glob.glob('chapters/*.typ'):
    for i, line in enumerate(open(fn, encoding='utf-8'), 1):
        for m in re.finditer(r'image\("(/[^"]+)"\)', line):
            if not os.path.exists('.' + m.group(1)):
                missing.append(f'{fn}:{i}: {m.group(1)}')
print('\n'.join(missing)) if missing else None
sys.exit(1 if missing else 0)
PY

# 6. md 时代残渣：chapters/ 里不该出现 /END/、[TOC]、外链图片
junk=$(grep -rn '/END/\|\[TOC\]\|image("http' chapters/ 2>/dev/null | wc -l)
[ "$junk" -eq 0 ] && ok "无 md 时代残渣" || { grep -rn '/END/\|\[TOC\]\|image("http' chapters/ | head -5; bad "md 时代残渣 $junk 处"; }

# 7. 若存在 PDF 产物，检查嵌入字体无 Type 3
if [ -f build/total.pdf ]; then
    t3=$(pdffonts build/total.pdf 2>/dev/null | awk 'NR>2 && $2 ~ /Type 3/' | wc -l)
    [ "$t3" -eq 0 ] && ok "PDF 无 Type 3 字体" || bad "PDF 含 $t3 个 Type 3 字体"
fi

exit $fail
