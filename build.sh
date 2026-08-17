#!/bin/sh
# 将各分章按固定顺序拼接为 total.md。
# total.md 由本脚本生成，请勿手改；修改分章后运行 ./build.sh 即可。
set -eu
cd "$(dirname "$0")"

{
    printf '# 风铃的模板库\n\n[TOC]\n\n\n\n'
    cat \
        STL与库函数.md \
        三维几何及常见例题.md \
        串.md \
        二维几何.md \
        动态规划.md \
        博弈论.md \
        图论.md \
        基础算法.md \
        多边形相关.md \
        多项式.md \
        常见例题.md \
        数据结构A.md \
        数据结构B.md \
        数论.md \
        杂项.md \
        树上问题.md \
        线性代数.md \
        组合数学.md \
        网络流.md
} > total.md
