#!/usr/bin/env python3
"""pandoc -t typst 输出的修正层。

pandoc 3.1 的 typst writer 与 typst 0.15 的符号表有版本漂移，
以下每条规则修正一类已实测触发的问题。pandoc 升级后应逐条复核。
"""
import re
import sys

def fix_bold_commas(t):
    """bold(...) 内含顶层逗号时 typst 当成多个实参。包一层 {} 合成一个参数。"""
    out = []
    i = 0
    while i < len(t):
        if t.startswith('bold(', i):
            depth, j = 0, i + 4
            start = j + 1
            while j < len(t):
                if t[j] == '(':
                    depth += 1
                elif t[j] == ')':
                    depth -= 1
                    if depth == 0:
                        break
                j += 1
            inner = t[start:j]
            d, top_comma = 0, False
            for ch in inner:
                if ch == '(':
                    d += 1
                elif ch == ')':
                    d -= 1
                elif ch == ',' and d == 0:
                    top_comma = True
            out.append(t[i:start] + '{' + inner + '})' if top_comma else t[i:j + 1])
            i = j + 1
        else:
            out.append(t[i])
            i += 1
    return ''.join(out)

def main(src, dst):
    t = open(src, encoding='utf-8').read()
    rules = [
        # (说明, 模式, 替换)
        (r'\bsect\b', 'inter'),                    # \cap → sect，0.15 已改名 inter
        ('#horizontalrule', '#line(length: 100%)'),  # pandoc 把 --- 映射为不存在的函数
        (r'\bangle\.l\b', 'chevron.l'),            # \langle 在 0.15 的合法名
        (r'\bangle\.r\b', 'chevron.r'),            # \rangle 同上
        (r'\btimes\.circle\b', '⊙'),               # \odot 映射名非法，直接用字符
        ('delim: "||"', 'delim: "‖"'),             # mat 的 delim 必须单字符
    ]
    for pat, rep in rules:
        t = re.sub(pat, rep, t) if pat.startswith('\\') or '\\b' in pat else t.replace(pat, rep)
    t = fix_bold_commas(t)
    # /END/ 分章标记：pandoc 把它包成 #block[/END/] 段落，整块换成分页
    # weak 避免文末多出一页空白
    t = re.sub(r'#block\[\s*/END/\s*\]', '#pagebreak(weak: true)', t)
    t = re.sub(r'^/END/$', '#pagebreak(weak: true)', t, flags=re.M)
    t = re.sub(r'(#pagebreak\(weak: true\)\s*)+$', '', t)
    open(dst, 'w', encoding='utf-8').write(t)

if __name__ == '__main__':
    main(sys.argv[1], sys.argv[2])
