#!/usr/bin/env python3
"""同步已建立来源的片段；默认检查，--write 只更新对应正文。"""
import argparse
import json
from pathlib import Path
import re
import textwrap

ROOT = Path(__file__).resolve().parents[1]

# (片段文件, 条目, [(来源, Typst 锚点), ...])。未登记的历史条目保留原样。
SOURCES = [
    ('misc', 'mypow', [('code/基础算法/快速幂与常用函数.cpp', None)]),
    ('misc', 'zmod', [('code/杂项/取模类.cpp', None)]),
    ('misc', 'frac', [('code/杂项/分数运算类.cpp', None)]),
    ('misc', 'bigint', [('code/杂项/大整数类-高精度计算.cpp', None)]),
    ('misc', 'mypow10', [('code/杂项/魔改十进制快速幂暴力计算.cpp', None)]),
    ('misc', 'getc', [('code/杂项/快读.cpp', None)]),
    ('math', 'matrix', [('code/数论/矩阵四则运算.cpp', None)]),
    ('math', 'mul_2', [('code/数论/Miller---Rabin-素数测试.cpp', None)]),
    ('math', 'pr', [('code/数论/Pollard---Rho-因式分解.cpp', None)]),
    ('math', 'lb', [('code/线性代数/高斯消元法.cpp', None)]),
    ('math', 'exgcd', [('chapters/数论.typ', '扩展欧几里得解')]),
    ('math', 'min25', [('chapters/数论.typ', 'min25-筛')]),
    ('poly', 'poly', [('chapters/多项式.typ', '多项式封装')]),
    ('poly', 'Poly', [('code/杂项/取模类.cpp', None), ('chapters/多项式.typ', '离散傅里叶变换-dft-与其逆变换-idft'), ('chapters/多项式.typ', '多项式封装')]),
    ('poly', 'findprimitiveroot', [('chapters/多项式.typ', '离散傅里叶变换-dft-与其逆变换-idft')]),
    ('poly', 'polynomial', [('chapters/多项式.typ', '快速数论变换-ntt')]),
    ('poly', 'qpow', [('code/多项式/快速数论变换-NTT-2.cpp', None)]),
    ('poly', 'lagrange', [('chapters/多项式.typ', '拉格朗日插值')]),
]


def printed(path, anchor=None, index=0, *, region="book"):
    source = (ROOT / path).read_text(encoding="utf-8")
    if anchor is not None:
        section = source.split(f"\n<{anchor}>\n", 1)[1]
        source = re.findall(r"```cpp\n(.*?)\n```", section, flags=re.S)[index]
    else:
        lines = source.splitlines()
        begin, finish = f"// @{region}-begin", f"// @{region}-end"
        assert lines.count(begin) == lines.count(finish) == 1, path
        start, end = lines.index(begin), lines.index(finish)
        assert start < end, path
        source = "\n".join(lines[start + 1:end])
    return textwrap.dedent(source).strip() + "\n"


def load_snippets(path):
    # 库内 JSONC 只在独立行使用 // 注释；不触碰字符串中的 C++ 注释。
    source = path.read_text(encoding="utf-8")
    return json.loads(re.sub(r"^\s*//.*$", "", source, flags=re.M))


def escape(body):
    return body.replace("\\", "\\\\").replace("$", "\\$").splitlines()


def inserted(body):
    if isinstance(body, list):
        body = "\n".join(body)
    return re.sub(r"\\([\\$}])", r"\1", body).strip() + "\n"


def sync(write=False):
    failures = []
    for file, key, sources in SOURCES:
        path = ROOT / "code-snippets" / (file + ".code-snippets")
        expected = escape("\n".join(printed(*source) for source in sources))
        if load_snippets(path)[key]["body"] == expected:
            continue
        if not write:
            failures.append(f"{path.name}:{key}")
            continue
        text = path.read_text(encoding="utf-8")
        entry = re.search(r"^\t" + re.escape(json.dumps(key)) + r":\s*\{", text, re.M)
        assert entry is not None, key
        field = re.search(r'"body"\s*:\s*', text[entry.end():])
        start = entry.end() + field.end()
        old, length = json.JSONDecoder().raw_decode(text[start:])
        body = json.dumps(expected, ensure_ascii=False, indent="\t").replace("\n", "\n\t\t")
        path.write_text(text[:start] + body + text[start + length:], encoding="utf-8")
    if failures:
        raise SystemExit("片段与来源不同；运行 python3 tools/sync_snippets.py --write：\n" + "\n".join(failures))
    print(f"片段来源一致：{len(SOURCES)} 项")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--write", action="store_true")
    sync(parser.parse_args().write)
