#import "../prelude.typ": *

= STL 与库函数
<stl-与库函数>
语言与标准库层的速查：函数行为与陷阱、进制转换、位运算内建、容器用法与自定义哈希。赛时对某个库函数的语义、边界或写法拿不准，翻这章。

== contest.hpp（公共头）
<contest-hpp>
抄任何板子前先抄这份：`i64` 等别名、`mod` / `N` / `M` / `eps` / `PI` 常量，以及莫队板子用的元组别名 `a2` / `a3` / `a4`。板子正文里出现的这些名字都出自这里；`mod`、`N`、`M` 按题目改。

#include-code("code/contest.hpp")

== 数组打乱 shuffle
<数组打乱-shuffle>
均匀打乱。引擎用 `mt19937_64`，不要 `srand` + 已弃用的 `random_shuffle`。对拍造数据、随机化算法用。

```cpp
mt19937_64 rng(chrono::steady_clock::now().time_since_epoch().count());  // 用系统时间做种子，防 hack
shuffle(ver.begin(), ver.end(), rng);
```

== bit 库与位运算函数 \_\_builtin\_\_
<bit-库与位运算函数-__builtin__>
GCC/Clang 内建，比手写循环快。`long long` 后缀 `ll`。

#pitfall[`x = 0` 时 `clz / ctz` 未定义，调用前先判零。]

```cpp
__builtin_popcount(x)  // 返回x二进制下含1的数量，例如x=15=(1111)时答案为4
__builtin_ffs(x) // 返回x右数第一个1的位置(1-idx)，1(1) 返回 1，8(1000) 返回 4，26(11010) 返回 2
__builtin_ctz(x) // 返回x二进制下后导0的个数，1(1) 返回 0，8(1000) 返回 3
__builtin_clz(x) // 返回x二进制下前导0的个数，8(1000) 返回 28；x为0时未定义
bit_width(x)  // 返回x二进制下的位数，9(1001) 返回 4，26(11010) 返回 5
```

注：以上函数为 GCC/Clang 内建，`i64` 版本只需在函数名后加 `ll`（如 `__builtin_popcountll(x)`），`unsigned long long` 加 `ull`；`bit_width` 为 C++20 标准库函数。

== 数字转字符串函数
<数字转字符串函数>
`itoa` 虽然能将整数转换成任意进制的字符串，但是其不是标准的 C 函数，且为 Windows 独有，且不支持 `i64` ，建议手写。

```cpp
// to_string函数会直接将你的各种类型的数字转换为字符串。
// string to_string(T val);
double val = 12.12;
cout << to_string(val);
```

#include-code("code/STL与库函数/数字转字符串函数.cpp")

== 字符串转数字
<字符串转数字>
`stoi`/`stoll` 是 C++ 标准，可指定进制；`atoi` 是 C，非法时给 $0$、不抛异常。前导空白会跳过。

#include-code("code/STL与库函数/字符串转数字.cpp")

#include-code("code/STL与库函数/字符串转数字-2.cpp")

== 全排列 next/prev\_permutation
<全排列-nextprev_permutation>
在提及 `next_permutation` 时，我们先补充几点字典序相关的知识。

#quote(block: true)[
对于三个字符所组成的序列`{a,b,c}`，其按照字典序的 6 种排列分别为： `{abc}`，`{acb}`，`{bac}`，`{bca}`，`{cab}`，`{cba}` 其排序原理是：先固定 `a` \(序列内最小元素)，再对之后的元素排列。而 `b` \< `c` ，所以 `abc` \< `acb` 。同理，先固定 `b` \(序列内次小元素)，再对之后的元素排列。即可得出以上序列。
]

`next_permutation` 算法，即是按照#strong[字典序顺序];输出的全排列；相对应的，`prev_permutation` 则是按照#strong[逆字典序顺序];输出的全排列。可以是数字，亦可以是其他类型元素。其直接在序列上进行更新，故直接输出序列即可。

#include-code("code/STL与库函数/全排列-nextprev_permutation.cpp")

== 字符串转换为数值函数 sto
<字符串转换为数值函数-sto>
可以快捷的将#strong[一串字符串];转换为#strong[指定进制的数字];。

使用方法

- `stoi(字符串, 0, x进制)` ：将一串 $x$ 进制的字符串转换为 `int` 型数字。

```cpp
cout << stoi("1010", 0, 2) << endl;          // 10
cout << stoi("c", 0, 16) << endl;            // 12
cout << stoi("0x3f3f3f3f", 0, 0) << endl;    // 1061109567
cout << stoi("10", 0, 8) << endl;            // 8
cout << stoll("aaaaaaaaaaa", 0, 16) << endl; // 11728124029610
```

- `stoll(字符串, 0, x进制)` ：将一串 $x$ 进制的字符串转换为 `i64` 型数字。
- `stoull`、`stod`、`stold` 同理。

== 数值转换为字符串函数 to\_string
<数值转换为字符串函数-to_string>
允许将#strong[各种数值类型];转换为字符串类型。

```cpp
//将数值num转换为字符串s
string s = to_string(num);
```

== 判断非递减 is\_sorted
<判断非递减-is_sorted>
`is_sorted(l, r)` 为真当且仅当区间非降。自定义序传比较器。

```cpp
//a数组[start,end)区间是否是非递减的，返回bool型
cout << is_sorted(a + start, a + end);
```

== 累加 accumulate
<累加-accumulate>
`accumulate(l, r, init)` 从 `init` 起累加（或传入二元运算）。初值类型决定结果类型，求和用 `0LL`。

```cpp
//将a数组[start,end)区间的元素进行累加，并输出累加和+x的值
cout << accumulate(a + start, a + end, x);
```

== 迭代器 iterator
<迭代器-iterator>
指向容器元素的指针状对象。`begin` 首元素，`end` 尾后。随机访问容器可加减整数。

```cpp
//构建一个UUU容器的正向迭代器，名字叫it
UUU::iterator it;

vector<int>::iterator it;  //创建一个正向迭代器，++ 操作时指向下一个
vector<int>::reverse_iterator it;  //创建一个反向迭代器，++ 操作时指向上一个
```

== 特殊函数 `next` 和 `prev` 详解：
<特殊函数-next-和-prev-详解>
不修改原迭代器，返回前进/后退 $n$ 步的副本。`list` 等没有 `+`，用这两个。

```cpp
auto it = s.find(x);  // 建立一个迭代器
prev(it); // 返回迭代器it的前一个迭代器
next(it); // 返回迭代器it的后一个迭代器
prev(it, 2); // 可选参数k：返回it前k个的迭代器
next(it, 2); // 返回it后k个的迭代器

/* 以下是一些应用 */
auto pre = prev(s.lower_bound(x));  // 返回第一个<x的迭代器
int ed = *prev(S.end(), 1);  // 返回最后一个元素
```

== 其他函数
<其他函数>
`exp2(x)` ：返回 $2^x$

`log2(x)` ：返回 $"log"_2 (x)$

`gcd(x, y) / lcm(x, y)` ：C++17 标准库函数，$cal(O)("log" "min" (lr(|x|) , lr(|y|)))$ 返回 $"gcd" (lr(|x|) , lr(|y|))$ 与 $upright("lcm") (lr(|x|) , lr(|y|))$，返回值恒为正。注意 `lcm` 先除后乘不会溢出。

== 容器与成员函数
<容器与成员函数>
=== 优先队列 priority\_queue
<优先队列-priority_queue>
默认大根堆（堆顶最大），自定义排序需要重载 `<`（比较语义与 `sort` 相反，见下例）。

```cpp
//没有clear函数，可用 swap(p, priority_queue<int, vector<int>, greater<int>>()) 清空
priority_queue<int, vector<int>, greater<int> > p;  //重定义为小根堆（堆顶最小）
push(x);  //向栈顶插入x
top(); //获取栈顶元素
pop(); //弹出栈顶元素
```

#include-code("code/STL与库函数/优先队列-priority_queue.cpp")

=== bitset
<bitset>
定长位集：每元素占 1 bit，`[i]` 访问第 $i$ 位（$0$ 为最低位），支持整体位运算（`&`、`|`、`^`、`~`、`<<`、`>>`），常用于状压与位并行加速。位数在编译期固定，`count()` 数 $1$ 的个数。

```cpp
// 如果输入的是01字符串，可以直接使用">>"读入
bitset<10> s;
cin >> s;

//使用只含01的字符串构造——bitset<容器长度>B (字符串)
string S; cin >> S;
bitset<32> B (S);

//使用整数构造（两种方式）
int x; cin >> x;
bitset<32> B1 (x);
bitset<32> B2 = x;

// 构造时，尖括号里的数字不能是变量
int x; cin >> x;
bitset<x> ans;  // 错误构造

[]  //随机访问
set(x) //将第x位置1，x省略时默认全部位置1
reset(x)  //将第x位置0，x省略时默认全部位置0
flip(x) //将第x位取反，x省略时默认全部位取反
to_ullong() //整体转换为ULL类型
to_string() //转换为"01..."字符串
count() //返回1的个数
any()  //判断是否至少有一个1
none() //判断是否全为0

_Find_first() // 找到从低位到高位第一个1的位置（libstdc++ 内部函数）
_Find_next(x) // 找到当前位置x的下一个1的位置，复杂度 O(n/w + count)

bitset<23> B1("11101001"), B2("11101000");
cout << (B1 ^ B2) << "\n";  //按位异或
cout << (B1 | B2) << "\n";  //按位或
cout << (B1 & B2) << "\n";  //按位与
cout << (B1 == B2) << "\n"; //比较是否相等
cout << B1 << " " << B2 << "\n";  //你可以直接使用cout输出
```

=== 哈希系列 unordered
<哈希系列-unordered>
通常指代 unordered\_map、unordered\_set、unordered\_multimap、unordered\_multiset，与原版相比不进行排序。

如果将不支持哈希的类型作为 `key` 值代入，编译器就无法正常运行，这时需要我们为其手写哈希函数。而我们写的这个哈希函数的正确性其实并不是特别重要（但是不可以没有），当发生冲突时编译器会调用 `key` 的 `operator ==` 函数进行进一步判断。#link("https://finixlei.blog.csdn.net/article/details/110267430?spm=1001.2101.3001.6650.3&utm_medium=distribute.pc_relevant.none-task-blog-2%7Edefault%7EBlogCommendFromBaidu%7ERate-3-110267430-blog-101406104.topnsimilarv1&depth_1-utm_source=distribute.pc_relevant.none-task-blog-2%7Edefault%7EBlogCommendFromBaidu%7ERate-3-110267430-blog-101406104.topnsimilarv1&utm_relevant_index=4")[参考]

==== 对 pair、tuple 定义哈希
<对-pairtuple-定义哈希>
`unordered_map` 默认不能以 `pair` 为键。把两维哈希异或/相乘混一下；自定义结构体同理。

#include-code("code/STL与库函数/对-pair、tuple-定义哈希.cpp")

==== 对结构体定义哈希
<对结构体定义哈希>
需要两个条件，一个是在结构体中重载等于号（区别于非哈希容器需要重载小于号，如上所述，当冲突时编译器需要根据重载的等于号判断），第二是写一个哈希函数。注意 `hash<>()` 的尖括号中的类型匹配。

#include-code("code/STL与库函数/对结构体定义哈希.cpp")

==== 对 vector 定义哈希
<对-vector-定义哈希>
以下两个方法均可。注意 `hash<>()` 的尖括号中的类型匹配。

#include-code("code/STL与库函数/对-vector-定义哈希.cpp")

#include-code("code/STL与库函数/对-vector-定义哈希-2.cpp")

== 参数传递与形
<参数传递与形>
板子是零件：普通数据进、普通数据出，外加一个回调。整数用 `i64`。别名写 `using`，不要 `typedef`。类型用 `struct` 全公开。

#specline([16B 走寄存器], [4MB × $10^5$：按值 8.2s，`const&` ≈ 0])
g++ 14 `-O2`，x86-64 SysV，Ryzen 7 5800H（表内 ns 按约 4.4 GHz）。被测函数编成单独的 `.o` 再链接——写在同一个文件里，按值拷贝会被优化掉。函数只读对象头尾各一字节，量的是传参本身。

按值是给函数一份复制。整数类结构体不超过 16 字节时，整颗进寄存器。再大，调用方先拷到自己的栈上，被调方从栈读；17 字节和 128 字节同一条路，只是量变大。`const T&` 寄存器里只传 8 字节地址，不先拷一份。`const` 是不许改，指令和 `T&` 一样。左值按值是拷贝，不是 move。表上 16B 两栏都是 1.14 ns，是两边都停在 5 拍，机器码不是同一段。

4MB 的 `vector` 传 $10^5$ 次，按值约 8.2s。`-O3` 也消不掉：拷的是堆上那坨数据，不是壳。

#figure(
align(center)[#table(
  columns: 4,
  align: (right, right, right, right),
  [$N$ (B)], [按值 (ns)], [`const&` (ns)], [按值 / 引用],
  [8], [1.14], [1.37], [0.83],
  [16], [1.14], [1.14], [1.00],
  [17], [1.37], [1.37], [1.00],
  [64], [1.36], [1.14], [1.20],
  [128], [2.27], [1.13], [2.00],
  [512], [13.98], [1.13], [12.4],
  [65536], [960], [1.13], [850],
)]
)

#figure(
align(center)[#table(
  columns: 2,
  align: (left, left),
  [场景], [写法],
  [只读容器 / `string` / 大 struct], [`const T&`],
  [有意改副本（`sort` / `shuffle` / `resize`）], [按值，加注释],
  [$lt.eq$ 16B 的 `int` / `pair` / 坐标], [按值],
  [返回值], [按值],
  [回调], [`F&&`，调用处 `[&]`],
  [`std::move`], [只在所有权交接处],
)]
)

`T` 接任意表达式，函数内是独立副本。`const T&` 接左值、const 对象、临时值。`T&` 只接可修改左值：`f({1, 2, 3})`、`T = string` 时的 `f("abc")`、`f(const 对象)` 三处都编不过。

#pitfall[`vector` 重分配后，指向元素的引用、指针、迭代器全部失效。`reserve` 到足够容量之后的 `push_back` 不触发重分配。]

range-for 进门把 `begin()`、`end()` 各求一次，之后只 `!=` 和 `++`。循环里对 `vector` `push_back`：扩容则迭代器失效。`list` 上无条件 `push_back` 会走成死循环。BFS / 拓扑用下标：

```cpp
vector<int> q = {s};
for (int i = 0; i < (int)q.size(); i++) {
    int u = q[i];
    q.push_back(v);
}
```

具体类型 `T&&` 只接右值。模板里 `F&&` 按实参折叠：左值变成 `T&`，右值变成 `T&&`。板子回调写 `F&&`。

```cpp
i64 query(int u, const vector<int> &a);
vector<int> sorted(vector<int> a) {  // 按值：sort 自己的副本
    sort(a.begin(), a.end());
    return a;
}
template<class F>
void path(int u, int v, F &&op) {
    op(l, r);
}
path(u, v, [&](int l, int r) { ans += bit.ask(l, r); });
```

```cpp
i64 query(int u, vector<int> a);                       // 每次整份拷贝
void path(int u, int v, function<void(int, int)> op);  // 类型擦除
void subtree(int u, int &l, int &r);                   // 出参，写不成 g(f(x))
for (int u : q) q.push_back(v);                        // 扩容则迭代器失效
```

`void sort_inplace(vector<int> &a)` 与 `std::sort` 同类：改原件。
