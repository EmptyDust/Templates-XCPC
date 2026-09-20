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

# 1. 与正式导出走同一路径：正文、独立封面、目录目的地和字体。
mkdir -p build
if ./export-pdf.sh >build/.check-export.log 2>&1; then
    ok "正文与封面导出、内部链接和字体检查通过"
else
    bad "PDF 导出检查失败（见 build/.check-export.log）"
fi

# 2. 孤儿章：chapters/ 里每个 .typ 必须被 main.typ include（漏 include 不报错，只会静默消失）
orphan=0
for f in chapters/*.typ; do
    grep -qF "#include \"$f\"" main.typ || { bad "$f: 未被 main.typ include"; orphan=1; }
done
[ $orphan -eq 0 ] && ok "无孤儿章"

# 3. 抽取的板子：code/ 里每个 .cpp 必须过 g++ 语法检查
cppbad=0
for f in code/*/*.cpp; do
    log="build/check-logs/${f#code/}.log"
    mkdir -p "$(dirname "$log")"
    g++ -std=gnu++20 -fsyntax-only "$f" 2>"$log" || { bad "$f: g++ 语法检查失败（见 $log）"; cppbad=1; }
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

# 7. 片段必须与登记来源一致；实际书稿接口和组合用法须通过运行验证。
python3 tools/sync_snippets.py || bad "片段来源检查失败"
python3 -m unittest discover -s tests -p 'test_*.py' -v || bad "模板回归失败"

exit $fail
