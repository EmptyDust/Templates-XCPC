#import "../prelude.typ": *

= 杂项
<杂项>
赛场零碎的百宝箱：开场模板、取模/分数/大整数类、LIS、快读与 int128 读写、对拍与随机构造、Python 速查与编译器设置。写题前先把这里的"胶水"备齐。整数用 `i64`。`N` / `mod` / `MAXN` 按题目改。

== 单测多测
<单测多测>
开场模板：头部就是 STL 章首的 `contest.hpp`（`i64` / `a2` 系 / `mod` / `N` 从那里来），此处只补 `rng`、`ranges`/`views` 简写、`inf` 与多测骨架。多测把 `//cin >> t` 打开。末尾固定换行，单测题若判多空行再删。

#include-code("code/杂项/单测多测.cpp")

== 三路比较运算符
<三路比较运算符>
C++20。放进结构体里，一次生成 `==` `<` 等。`V` 换成自己的类型。

```cpp
auto operator<=>(const V &) const = default;
```

== 取模类
<取模类>
`Zmod<P>` 把值包成自动保持在 $\[ 0 , p \)$ 的模整数类型，四则与快速幂直接对对象写，不用每步手动 `%`。模数写在类型上：`using Z = Zmod<998244353>;`，双模就是两个互不相干的类型 `Zmod<1000000007>` / `Zmod<998244353>`。多项式、双模哈希用这一份；组合数不用——阶乘表加 `% mod` 手写就够（见组合数学章）。附编译期 `mypow`。

#include-code("code/杂项/取模类.cpp")

== 分数运算类
<分数运算类>
有符号整数分数的四则运算与比较；分母非零，除数的分子非零。构造时调整分母符号，`norm()` 返回约分后的值。分子、分母、绝对值和交叉乘积均须能由 `T` 表示；需要更大中间值时选 `i128`。

#include-code("code/杂项/分数运算类.cpp")

== 大整数类 \(高精度计算)
<大整数类-高精度计算>
九位一节，符号在 `sign`。支持整个 `i64` 范围的构造，以及正负 `int` 标量乘除；除法向零截断，余数符号随被除数，除数必须非零。零统一表示为正号。位数很大时仍须核算 Karatsuba 中间系数是否超出 `i64`。

#include-code("code/杂项/大整数类-高精度计算.cpp")

== 阿达马矩阵 \(Hadamard matrix)
<阿达马矩阵-hadamard-matrix>
构造题用，其有一些性质：将 $0$ 看作 $- 1$；$1$ 看作 $+ 1$，整个矩阵可以构成一个 $2^k$ 维向量组，任意两个行、列向量的点积均为 $0$ #link("https://codeforces.com/contest/610/problem/C")[See];。例如，在 $k = 2$ 时行向量 $arrow(2)$ 和行向量 $arrow(3)$ 的点积为 $1 dot 1 + (- 1) dot 1 + 1 dot (- 1) + (- 1) dot (- 1) = 0$ 。

$k = 1$ 时行为 `11`、`10`；$k = 2$ 时行为 `1111`、`1010`、`1100`、`1001`。

#include-code("code/杂项/阿达马矩阵-Hadamard-matrix.cpp")

== 幻方
<幻方>
构造题用，其有一些性质（保证 $N$ 为奇数）：$1$ 到 $N^2$ 每个数字恰好使用一次，且每行、每列及两条对角线上的数字之和都相同，且为奇数 #link("https://codeforces.com/contest/710/problem/C")[See] 。

构造方式：将 $1$ 写在第一行的中间，随后不断向右上角位置填下一个数字，直到填满。

$N = 3$ 时结果为：

```text
8 1 6
3 5 7
4 9 2
```

#include-code("code/杂项/幻方.cpp")

== 最长严格/非严格递增子序列 \(LIS)
<最长严格非严格递增子序列-lis>
#specline([#O($N "log" N$)])
子序列可不连续。`val[i]` 表示长 $i + 1$ 的上升子序列的最小结尾；新数二分插入，能替换则换、否则追加。长度即 LIS。

#pitfall[`upper_bound` 对应#strong[严格];递增、`lower_bound` 对应#strong[非严格];递增——两个 bound 换错，LIS 语义就变了。]

=== 一维
<一维>
Dilworth：剖成最少单调不升子序列的个数 $=$ 最长上升子序列长度。

#quote(block: true)[
Dilworth: 对于任意有限偏序集，其最大反链中元素的数目必等于最小链划分中链的数目. 将一个序列剖成若干个单调不升子序列的最小个数等于该序列最长上升子序列的个数
]

#include-code("code/杂项/一维.cpp")

=== 二维+输出方案
<二维输出方案>
先按第一维升序，第一维相同则第二维降序（避免等 $x$ 误接），再对第二维做 LIS。`pre` 记前驱，从最长结尾回溯。

#include-code("code/杂项/二维+输出方案.cpp")

== cout 输出流控制
<cout-输出流控制>
设置字段宽度：`setw(x)` ，该函数可以使得补全 $x$ 位输出，默认用空格补全。

```cpp
bool Solve() {
    cout << 12 << endl;
    cout << setw(12) << 12 << endl;
    return 0;
}
```

输出（第二行右对齐，前导 10 个空格）：

```text
12
          12
```

设置填充字符：`setfill(x)` ，该函数可以设定补全类型，注意这里的 $x$ 只能为 `char` 类型。

```cpp
bool Solve() {
    cout << 12 << endl;
    cout << setw(12) << setfill('*') << 12 << endl;
    return 0;
}
```

输出：

```text
12
**********12
```

== 读取一行数字，个数未知
<读取一行数字个数未知>
先 `getline` 再 `stringstream`。前面如果刚 `cin >>` 过，先 `cin.ignore` 吃掉行尾。

#include-code("code/杂项/读取一行数字，个数未知.cpp")

== 日期换算 \(基姆拉尔森公式)
<日期换算-基姆拉尔森公式>
已知年月日，求星期。返回 $1 dots.c 7$（周一到周日，看 `%7+1` 约定）。格里高利历。

```cpp
int week(int y,int m,int d){
    if(m<=2)m+=12,y--;
    return (d+2*m+3*(m+1)/5+y+y/4-y/100+y/400)%7+1;
}
```

== 高精度快速幂
<高精度快速幂>
求解 $n^k mod p$，其中 $0 lt.eq n , k lt.eq 10^1000000 , med 1 lt.eq p lt.eq 10^9$。容易发现 $n$ 可以直接取模，瓶颈在于 $k$ #link("https://codeforces.com/contest/17/problem/D")[See];。

=== 魔改十进制快速幂（暴力计算）
<魔改十进制快速幂暴力计算>
该算法复杂度 $cal(O)("len" (k))$。

#include-code("code/杂项/魔改十进制快速幂暴力计算.cpp")

=== 扩展欧拉定理（欧拉降幂公式）
<扩展欧拉定理欧拉降幂公式>
$ n^k equiv {n^(k mod phi (p)) & "gcd" (n , p) = 1\
n^(k mod phi (p) + phi (p)) & "gcd" (n , p) eq.not 1 and k gt.eq phi (p)\
n^k & "gcd" (n , p) eq.not 1 and k < phi (p) $

最终我们可以将幂降到 $phi (p)$ 的级别，使得能够直接使用快速幂解题，复杂度瓶颈在求解欧拉函数 $cal(O)(sqrt(p))$ 。

```cpp
int phi(int n) { //求解 phi(n)
    int ans = n;
    for (int i = 2; i <= n / i; i++) {
        if (n % i == 0) {
            ans = ans / i * (i - 1);
            while (n % i == 0) {
                n /= i;
            }
        }
    }
    if (n > 1) { //特判 n 为质数的情况
        ans = ans / n * (n - 1);
    }
    return ans;
}
signed main() {
    string n_, k_;
    int p;
    cin >> n_ >> k_ >> p;

    int n = 0;  // 转化并计算 n % p
    for (auto it : n_) {
        n = n * 10 + it - '0';
        n %= p;
    }
    int mul = phi(p), type = 0, k = 0;  // 转化 k
    for (auto it : k_) {
        k = k * 10 + it - '0';
        type |= (k >= mul);
        k %= mul;
    }
    if (type) {
        k += mul;
    }
    cout << mypow(n, k, p) << endl;
}
```

== 快读
<快读>
用 `fread` 分块缓冲读入，适合批量整数输入。约定输入为以空白分隔的合法十进制整数，数值在目标类型范围内。`Cin(x)` 成功返回 true；跳过空白后遇 EOF 返回 false，保留 x 原值。`Cin(a,b,...)` 遇 EOF 即停止，此前读成功的参数保留新值。支持正负号、有符号整数的最小值及无符号整数；`Cout(x)` 不带换行。不要与 `cin` 混用，也不适合需要即时交互的输入。

#include-code("code/杂项/快读.cpp")

读到 EOF 并逐行输出的完整用法：

```cpp
int main() {
    i64 x;
    while (Cin(x)) {
        Cout(x);
        putchar('\n');
    }
}
```

== int128 输入输出流控制
<int128-输入输出流控制>
`__int128` 是编译器扩展，需要编译器和目标平台支持，并非 Linux 专属。本库使用 GNU C++20，有符号范围为 $-2^127 dots.c 2^127-1$。下面的流运算符仅用于范围内的非负十进制整数；含负数时可使用上一节的 `Cin` / `Cout`。

```cpp
using i128 = __int128;

std::istream& operator>>(std::istream& is, i128& n) {
    std::string s;is >> s;
    n = 0;
    for (char i : s) n = n * 10 + i - '0';
    return is;
}
std::ostream& operator<<(std::ostream& os, i128 n) {
    if (n == 0) {
        return os << 0;
    }
    std::string s;
    while (n) {
        s += '0' + n % 10;
        n /= 10;
    }
    std::reverse(s.begin(), s.end());
    return os << s;
}
```

== 对拍板子
<对拍板子>
同目录多题：`A.cpp` / `A-std.cpp` / `A-gen.cpp`。 一题多份源（`F.cpp` / `F-1.cpp` / `F-Brute.cpp`）共用该题一份暴力和生成器。 对拍器做成函数追加到 shell init（Linux `~/.bashrc`、Windows `$PROFILE`），两边接口相同；Windows 上机器若有 Python，`stress.py` 更好读。 prefix：`stress A` 或 `stress F-1`。被测用完整参数，std/gen 只取第一段连字符前的题号。 manual：`stress a.cpp brute.cpp gen.cpp`，三个路径原样用。 其它个数直接返回。 编译产物与中间文件均在临时目录固定路径，下次覆盖，不 `rm`。 挂了去看临时目录里的输入输出。三个 `g++` 都成功才进入循环。

Linux（`~/.bashrc` 末尾）：

```bash
# prefix: stress A / stress F-1 → F-1.cpp F-std.cpp F-gen.cpp
# manual: stress a.cpp brute.cpp gen.cpp
# /tmp/x /tmp/xstd /tmp/gen /tmp/test.in /tmp/x.out /tmp/xstd.out
stress() {
    case $# in
    1)
        sol=$1.cpp
        p=${1%%-*}
        std=$p-std.cpp
        gen=$p-gen.cpp
        ;;
    3)
        sol=$1
        std=$2
        gen=$3
        ;;
    *)
        return
        ;;
    esac
    g++ -std=gnu++20 -O2 -pipe -o /tmp/gen "$gen" &&
    g++ -std=gnu++20 -O2 -pipe -o /tmp/x "$sol" &&
    g++ -std=gnu++20 -O2 -pipe -o /tmp/xstd "$std" && {
        t=1
        while :; do
            echo $t
            /tmp/gen > /tmp/test.in
            /tmp/x < /tmp/test.in > /tmp/x.out
            /tmp/xstd < /tmp/test.in > /tmp/xstd.out
            diff -q /tmp/x.out /tmp/xstd.out || break
            t=$((t + 1))
        done
    }
}
```

Windows PowerShell（`$PROFILE` 末尾），输出用 `fc` 比对：

```powershell
# prefix: stress A / stress F-1 → F-1.cpp F-std.cpp F-gen.cpp
# manual: stress a.cpp brute.cpp gen.cpp
function stress {
    switch ($args.Count) {
        1 {
            $sol = "$($args[0]).cpp"
            $p = ($args[0] -split '-', 2)[0]
            $std = "$p-std.cpp"
            $gen = "$p-gen.cpp"
        }
        3 {
            $sol = $args[0]
            $std = $args[1]
            $gen = $args[2]
        }
        default { return }
    }
    g++ -std=gnu++20 -O2 -pipe -o "$env:TEMP\gen.exe" $gen
    if (-not $?) { return }
    g++ -std=gnu++20 -O2 -pipe -o "$env:TEMP\x.exe" $sol
    if (-not $?) { return }
    g++ -std=gnu++20 -O2 -pipe -o "$env:TEMP\xstd.exe" $std
    if (-not $?) { return }
    $t = 1
    while ($true) {
        Write-Host $t
        & "$env:TEMP\gen.exe" > "$env:TEMP\test.in"
        & "$env:TEMP\x.exe" < "$env:TEMP\test.in" > "$env:TEMP\x.out"
        & "$env:TEMP\xstd.exe" < "$env:TEMP\test.in" > "$env:TEMP\xstd.out"
        fc.exe "$env:TEMP\x.out" "$env:TEMP\xstd.out"
        if ($LASTEXITCODE -ne 0) { break }
        $t++
    }
}
```

Windows Python（存成 `stress.py`），更好读，输出在语言内比字节：

```python
# prefix: python stress.py A / python stress.py F-1 → F-1.cpp F-std.cpp F-gen.cpp
# manual: python stress.py a.cpp brute.cpp gen.cpp
# %TEMP%\x.exe %TEMP%\xstd.exe %TEMP%\gen.exe %TEMP%\test.in %TEMP%\x.out %TEMP%\xstd.out
import os, sys

def run(c):
    if os.system(c): sys.exit(1)

a = sys.argv[1:]
if len(a) == 1:          # prefix：python stress.py A
    p = a[0].split('-')[0]
    sol, std, gen = a[0] + '.cpp', p + '-std.cpp', p + '-gen.cpp'
elif len(a) == 3:        # manual：python stress.py a.cpp brute.cpp gen.cpp
    sol, std, gen = a
else:
    sys.exit(1)

T = os.environ['TEMP'] + '\\'  # Linux 写成 '/tmp/'，并删去各处的 .exe
run(f'g++ -std=gnu++20 -O2 -pipe -o {T}gen.exe {gen}')
run(f'g++ -std=gnu++20 -O2 -pipe -o {T}x.exe {sol}')
run(f'g++ -std=gnu++20 -O2 -pipe -o {T}xstd.exe {std}')

t = 1
while True:
    print(t)
    run(f'{T}gen.exe > {T}test.in')
    run(f'{T}x.exe < {T}test.in > {T}x.out')
    run(f'{T}xstd.exe < {T}test.in > {T}xstd.out')
    if open(f'{T}x.out', 'rb').read() != open(f'{T}xstd.out', 'rb').read():
        break
    t += 1
```

生成器骨架（存成 `A-gen.cpp`）：

#include-code("code/杂项/对拍板子.cpp")

== 随机数生成与样例构造
<随机数生成与样例构造>
`graph(n, root, m)` 返回 1-index 连通无向简单图的边表。先生成树再补边，不保证所有连通图等概率。要求 $n >= 1$、$n-1 <= m <= n(n-1)/2$；省略 m 时生成树。root 是从 0 开始的编号偏移，-1 为随机；不表示有向根。复现用 `rnd.seed(seed)`。稀疏图拒绝采样，稠密图枚举补边，存储为 $cal(O)(m)$。
`r(a,b)` 在 int 闭区间 $[a,b]$ 上均匀采样，要求 $a <= b$。

#include-code("code/杂项/随机数生成与样例构造.cpp")

```cpp
int main() {
    int n, m;
    cin >> n >> m;
    for (auto [u, v] : graph(n, -1, m)) cout << u << " " << v << '\n';
}
```

== 手工哈希
<手工哈希>
给 `unordered_map` 用的整数/ pair 哈希。SplitMix64 搅匀再 xor 时间种子，减轻被卡。自定义 `unordered_map<K,V,myhash>`。

#include-code("code/杂项/手工哈希.cpp")

== Python 常用语法
<python-常用语法>
大整数、高精度、简单脚本用。递归默认深度约 $1000$，要改 `setrecursionlimit`。输出用 `print`，大量输出注意不要逐行 flush。

=== 读入与定义
<读入与定义>
- 读入多个变量并转换类型：`X, Y = map(int, input().split())`
- 读入列表：`X = eval(input())`
- 多维数组定义：`X = [[0 for j in range(0, 100)] for i in range(0, 200)]`

=== 格式化输出
<格式化输出>
- 保留小数输出：`print("{:.12f}".format(X))` 指保留 $12$ 位小数
- 对齐与宽度：`print("{:<12f}".format(X))` 指左对齐，保留 $12$ 个宽度

=== 排序
<排序>
- 倒序排序：使用 `reverse` 实现倒序 `X.sort(reverse=True)`

- 自定义排序：下方代码实现了先按第一关键字降序、再按第二关键字升序排序。

  ```python
  X.sort(key=lambda x: x[1])
  X.sort(key=lambda x: x[0], reverse=True)
  ```

=== 文件 IO
<文件-io>
- 打开要读取的文件：`r = open('X.txt', 'r', encoding='utf-8')`
- 打开要写入的文件：`w = open('Y.txt', 'w', encoding='utf-8')`
- 按行写入：`w.write(XX)`

=== 增加输出流长度、递归深度
<增加输出流长度递归深度>
`sys.setrecursionlimit` 把递归上限抬高；`sys.set_int_max_str_digits` 允许超长整数转字符串（3.11+）。过大可能爆栈。

```python
import sys
sys.set_int_max_str_digits(200000)
sys.setrecursionlimit(100000)
```

=== 自定义结构体
<自定义结构体>
`sort(key=lambda x: ...)` 按成员排序自定义对象，`reverse=True` 降序。

```python
class node:
    def __init__(self, A, B, C):
        self.A = A
        self.B = B
        self.C = C

w = []
for i in range(1, 5):
    a, b, c = input().split()
    w.append(node(a, b, c))
w.sort(key=lambda x: x.C, reverse=True)
for i in w:
    print(i.A, i.B, i.C)
```

=== 数据结构
<数据结构>
- 模拟 C++ 的 `map`，定义：`dic = dict()`
- 模拟栈与队列：使用常见的 `list` 即可完成，`list.insert(0, X)` 实现头部插入、`list.pop()` 实现尾部弹出、`list.pop(0)` 实现头部弹出

=== 其他
<其他>
- 获取 ASCII 码：`ord()` 函数
- 转换为 ASCII 字符：`chr()` 函数

== OJ 测试
<oj-测试>
对于一个未知属性的 OJ，应当在正式赛前进行以下全部测试：

=== GNU C++ 版本测试
<gnu-c-版本测试>
用预定义宏看编译器版本，确认 `__int128`、pbds、gnu++20 能不能用。

#include-code("code/杂项/GNU-C++-版本测试.cpp")

=== 编译器位数测试
<编译器位数测试>
`sizeof` 指针或 `long` 判断 32/64 位。OJ 几乎都是 64 位。

```cpp
using i128 = __int128;  // 64 位 GNU C++11 支持
```

=== 评测器环境测试
<评测器环境测试>
Windows 系统输出 $- 1$ ；反之则为一个随机数。

```cpp
#define int long long
map<int, int> dic;
int x = dic.size() - 1;
cout << x << endl;
```

=== 运算速度测试
<运算速度测试>
测下面第一段三重循环（`n = 4E3`），表中数字为毫秒。「手动加速」指打开 `#pragma GCC optimize("Ofast", "unroll-loops")`。第二段是另一档负载（$3.4 times 10^8$ 次 `mt19937`），不在表内。

#figure(
align(center)[#table(
  columns: 8,
  align: (col, row) => (center,center,center,center,center,center,center,center,).at(col),
  inset: 6pt,
  [], [本地-20\(64)], [#link("https://codeforces.com/problemset/customtest")[CodeForces-20\(64)];], [#link("https://atcoder.jp/contests/practice/custom_test")[AtCoder-20\(64)];], [#link("https://ac.nowcoder.com/acm/problem/21122")[牛客-17\(64)];], [#link("http://39.98.219.132/problem/2230")[学院 OJ];], [CodeForces-17\(32)], [#link("https://www.matiji.net/exam/brushquestion/14/915/520382963B32011DA740D5275AB1C1BF")[马蹄集];],
  [#strong[4E3 量级-硬跑];],
  [2454],
  [2886],
  [874],
  [4121],
  [4807],
  [2854],
  [4986],
  [#strong[4E3 量级-手动加速];],
  [556],
  [686],
  [873],
  [1716],
  [1982],
  [2246],
  [2119],
)]
)

#include-code("code/杂项/运算速度测试.cpp")

```cpp
// #pragma GCC optimize("Ofast", "unroll-loops")

#include <bits/stdc++.h>
using namespace std;
mt19937 rnd(chrono::steady_clock::now().time_since_epoch().count());

signed main() {
    size_t n = 340000000, seed = 0;
    for (int i = 1; i <= n; i++) {
        seed ^= rnd();
    }

    return 0;
}
```

== 编译器设置
<编译器设置>
`-std=gnu++20`：GNU 扩展下的 C++20 方言，相对 `-std=c++20` 允许 `__int128`、`pbds` 等。代价：偏离 ISO，可移植性下降。

`-pipe`：驱动在 `cc1` 与 `as` 之间以管道传递汇编文本，替代临时 `.s`。不改变语义与目标码。代价：汇编器须能从标准输入读取（GNU `as` 可以，部分专有实现不行，故驱动默认关闭）；汇编失败时没有可事后打开的 `.s`；管道缓冲使两阶段紧耦合，缓冲满则前端阻塞；`/tmp` 若为 tmpfs，与落盘临时文件的差异可忽略。小翻译单元上收益通常可忽略。

`-O2`：启用较完整的优化通道。代价：编译时延明显上升（常见约 $1.5$–$3$ 倍）；调试时语句与指令对应变差。

`-O0`：关闭优化。代价：运行时性能差。

`-g`：写入调试符号。代价：目标文件增大；与高优化等级并用时行号可能漂移。

`-Wall -Wextra`：较广的静态诊断集合。代价：噪音与误报；不改变代码生成。

`-fsanitize=address`：AddressSanitizer，检测越界、use-after-free 等。代价：运行时显著变慢、内存占用上升；依赖运行时库；不宜提交评测机。

`-fsanitize=undefined`：UndefinedBehaviorSanitizer。代价：同上；覆盖并不完全。

`-Wl,--stack=`：向链接器传递栈预留，仅 MinGW。代价：在 Linux 上无效。

将下列函数追加到默认 init 末尾：Linux 为 `~/.bashrc`，Windows PowerShell 为 `$PROFILE`。不要使用 `~/.bashrc.d`。 `run` 不启用优化；`runo` 使用 `-O2`；`rund` 用于本地诊断。 目标文件固定单一临时路径，下次覆盖，不删除。

Linux（`~/.bashrc` 末尾）：

```bash
# run a.cpp < in.txt
# /tmp/a.out，下次覆盖
run() {
    g++ -std=gnu++20 -pipe "$1" -o /tmp/a.out &&
    /tmp/a.out
}
runo() {
    g++ -O2 -std=gnu++20 -pipe "$1" -o /tmp/a.out &&
    /tmp/a.out
}
rund() {
    g++ -O0 -g -std=gnu++20 -pipe -Wall -Wextra -fsanitize=address,undefined "$1" -o /tmp/a.out &&
    /tmp/a.out
}
```

Windows 只考虑 PowerShell（`$PROFILE` 末尾）。`rm` 是 `Remove-Item` 的别名。不用 `&&`（5.1 没有；7 才有）。`$?` 为上一命令是否成功。

```powershell
# run a.cpp    Get-Content in.txt | run a.cpp
# $env:TEMP\a.exe，下次覆盖
function run {
    g++ -std=gnu++20 -pipe $args[0] -o "$env:TEMP\a.exe"
    if ($?) { & "$env:TEMP\a.exe" }
}
function runo {
    g++ -O2 -std=gnu++20 -pipe $args[0] -o "$env:TEMP\a.exe"
    if ($?) { & "$env:TEMP\a.exe" }
}
function rund {
    g++ -O0 -g -std=gnu++20 -pipe -Wall -Wextra -fsanitize=address,undefined $args[0] -o "$env:TEMP\a.exe"
    if ($?) { & "$env:TEMP\a.exe" }
}
```
