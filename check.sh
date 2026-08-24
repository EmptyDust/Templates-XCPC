#!/bin/sh
# check.sh —— 书的完整性闸。改动后跑一遍，全过才算没破版。
# 检查项对应 export/AGENTS.md 里记录过的历史坑。
set -u
cd "$(dirname "$0")"
fail=0
TMP_TOTAL=$(mktemp)

say() { printf '%s %s\n' "$1" "$2"; }
bad() { say "FAIL" "$1"; fail=1; }
ok()  { say " ok " "$1"; }

# 1. 围栏配平：每个分章的 ``` 数必须是偶数
for f in *.md; do
    [ "$f" = "total.md" ] && continue
    n=$(grep -c '^```' "$f")
    if [ $((n % 2)) -ne 0 ]; then bad "$f: 围栏 $n 个（奇数）"; fi
done
ok "围栏配平"

# 2. /END/ 分页标记：build.sh 收进 total 的每章都必须有
miss=0
for f in $(sed -n 's/^cat "\(.*\)"$/\1/p' build.sh); do
    grep -q '^/END/$' "$f" || { bad "$f: 缺 /END/"; miss=1; }
done
[ $miss -eq 0 ] && ok "/END/ 分页标记"

# 3. texmath 警告：pandoc 转换全书必须 0 警告（公式写法合规）
w=$(pandoc --from=gfm --to=typst --wrap=none total.md -o /dev/null 2>&1 | grep -c '\[WARNING\]')
[ "$w" -eq 0 ] && ok "texmath 0 警告" || bad "texmath $w 条警告"

# 4. 目录级标题宽度：## / ### 标题按 CJK=2、ASCII=1 计，须 ≤ 38（目录不折行的实测边界）
python3 - <<'PY' && ok "目录级标题宽度 ≤ 38" || bad "超宽标题（见上）"
import glob, sys
bad = []
for fn in glob.glob('*.md'):
    if fn == 'total.md': continue
    for i, line in enumerate(open(fn, encoding='utf-8'), 1):
        if line.startswith('## ') or line.startswith('### '):
            t = line.lstrip('#').strip()
            w = sum(2 if ord(c) > 0x2E7F else 1 for c in t)
            if w > 38: bad.append(f'{fn}:{i}: 宽 {w}: {t}')
print('\n'.join(bad)) if bad else None
sys.exit(1 if bad else 0)
PY

# 5. total.md 与分章同步（重新生成后内容不变即同步）
cp total.md "$TMP_TOTAL"
./build.sh >/dev/null 2>&1
cmp -s "$TMP_TOTAL" total.md && ok "total.md 与分章同步" || bad "total.md 落后分章，跑 ./build.sh"
rm -f "$TMP_TOTAL"

# 6. 若存在 PDF 产物，检查嵌入字体无 Type 3
if [ -f build/total.pdf ]; then
    t3=$(pdffonts build/total.pdf 2>/dev/null | awk 'NR>2 && $2 ~ /Type 3/' | wc -l)
    [ "$t3" -eq 0 ] && ok "PDF 无 Type 3 字体" || bad "PDF 含 $t3 个 Type 3 字体"
fi

# 7. 死链检查：md 内部锚点必须都存在
python3 - <<'PY' && ok "内部锚点" || bad "内部锚点（见上）"
import re, sys, unicodedata, glob
def anchor(t):
    t = unicodedata.normalize('NFC', t.strip().lower())
    t = re.sub(r'[`*_\\]', '', t)
    return re.sub(r'[^\w一-鿿 -]', '', t).replace(' ', '-')
anchors, links = set(), []
for fn in glob.glob('*.md'):
    if fn == 'total.md': continue
    for i, line in enumerate(open(fn, encoding='utf-8'), 1):
        m = re.match(r'^(#{2,5})\s+(.*)', line)
        if m: anchors.add(anchor(m.group(2)))
        for m in re.finditer(r'\[[^\]]*\]\(#([^)]+)\)', line):
            links.append((fn, i, m.group(1)))
missing = [(fn, i, a) for fn, i, a in links if a not in anchors]
for fn, i, a in missing: print(f'{fn}:{i}: 死锚 #{a}')
sys.exit(1 if missing else 0)
PY

# 8. 悬空脚注：[^name] 引用必须有对应的 [^name]: 定义
python3 - <<'PY' && ok "脚注引用有定义" || bad "悬空脚注（见上）"
import re, glob, sys
refs, defs = set(), set()
for fn in glob.glob('*.md'):
    if fn == 'total.md': continue
    src = open(fn, encoding='utf-8').read()
    src = re.sub(r'```.*?```', '', src, flags=re.S)   # 代码围栏
    src = re.sub(r'\$\$.*?\$\$|\$[^$\n]+\$', '', src, flags=re.S)  # 数学区
    refs.update(m.group(1) for m in re.finditer(r'\[\^([^\]]+)\](?!:)', src))
    defs.update(m.group(1) for m in re.finditer(r'^\[\^([^\]]+)\]:', src, re.M))
missing = refs - defs
for name in sorted(missing): print(f'悬空脚注：[^{name}]')
sys.exit(1 if missing else 0)
PY

# ---- 原生 Typst 结构（main.typ / chapters/ / code/）----

# 9. 入口可编译：typst compile 本身就是闸门（语法、引用、文件读取全校验）
if [ -f main.typ ]; then
    mkdir -p build
    if typst compile --root . --font-path export/vendor/jetbrains-mono main.typ build/.check-book.pdf 2>build/.check-typst.log; then
        ok "main.typ 可编译"
    else
        bad "main.typ 编译失败（见 build/.check-typst.log）"
    fi
    rm -f build/.check-book.pdf
fi

# 10. 孤儿章：chapters/ 里每个 .typ 必须被 main.typ include
if [ -d chapters ]; then
    orphan=0
    for f in chapters/*.typ; do
        grep -qF "#include \"$f\"" main.typ || { bad "$f: 未被 main.typ include"; orphan=1; }
    done
    [ $orphan -eq 0 ] && ok "无孤儿章"
fi

# 11. 抽取的板子：code/ 里每个 .cpp 必须过 g++ 语法检查
if [ -d code ]; then
    cppbad=0
    for f in $(find code -name '*.cpp'); do
        g++ -std=gnu++20 -fsyntax-only "$f" 2>build/.check-gpp.log || { bad "$f: g++ 语法检查失败（见 build/.check-gpp.log）"; cppbad=1; }
    done
    [ $cppbad -eq 0 ] && ok "code/ 全部通过 g++ -fsyntax-only"
fi

exit $fail
