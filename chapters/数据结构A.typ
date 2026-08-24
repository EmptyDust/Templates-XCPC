#import "../prelude.typ": *

= 数据结构 A
<数据结构-a>
== 笛卡尔树
<笛卡尔树>
小根笛卡尔树：下标为键（中序遍历为原序列）、值为堆（小根）的二叉树，单调栈 $cal(O) (N)$ 建树。常用于 RMQ 与 LCA 互转（区间最小值 \= 两端点 LCA 处的值）。下方 `ls/rs` 为左右儿子，`-1` 表示空。

#include-code("code/数据结构A/笛卡尔树.cpp")

== dsu 并查集
<dsu-并查集>
维护不相交集合：同一块共用一个根。路径压缩把访问链直接接到根上，按秩/按大小合并压树高，均摊约 $cal(O) (alpha (N))$。判连通、Kruskal、维护块内点数/边数都用它。下标按各封装是 $0 . . n - 1$ 或 $1 . . n$。

=== 路径优化\(普遍)
<路径优化普遍>
只做路径压缩，合并不看大小。最短，均摊仍约 $cal(O) (alpha (N))$。下标 $1 . . n$。`merge` 成功返回 true。

#include-code("code/数据结构A/路径优化普遍.cpp")

=== 根据集合的大小优化
<根据集合的大小优化>
数组版并查集：根为正数存集合大小的相反约定——这里根存#strong[正整数大小];，非根存#strong[负的父编号];（`unicnt[x] <= 0` 时 `-unicnt[x]` 为父）；`uni` 按大小合并。均摊约 $cal(O) (alpha (N))$。

#include-code("code/数据结构A/根据集合的大小优化.cpp")

=== 按秩合并优化
<按秩合并优化>
按秩（树高下界）合并 + 路径压缩，均摊约 $cal(O) (alpha (N))$，且比朴素路径压缩有更严格的最坏界。

#include-code("code/数据结构A/按秩合并优化.cpp")

=== 常用操作
<常用操作>
路径压缩，并维护块内点数 `p`、边数 `e`、是否有自环 `f`。`merge` 把编号小的根挂到大的上。`same` / `size` / `E` / `F` 查询前都会先 `get` 到根。

#include-code("code/数据结构A/常用操作.cpp")

== ST 表
<st-表>
用于解决区间可重复贡献问题，需要满足 $x upright(" 运算符 ") x = x$ （如区间最大值：$max (x , x) = x$ 、区间 $gcd$：$gcd (x , x) = x$ 等），但是不支持修改操作。$cal(O) (N log N)$ 预处理，$cal(O) (1)$ 查询。下方 `vt` 的第二维硬编码为 `30`（支持 $n lt.eq 2^30$），按 $n$ 改为 `__lg(n)+1` 即可；合并运算由 `Info::operator+` 表达。

#include-code("code/数据结构A/ST-表.cpp")

== Fenwick Tree 树状数组
<fenwick-tree-树状数组>
下标从 $1$ 开始。`x & -x` 取出最低位 $1$，沿这条链走到父区间；单点加往上走、前缀和往下走，是同一棵隐式树的对偶。`ask(l, r)` 为 $[l , r]$ 区间和。不能直接区间覆盖（改差分）。构造时从 `in`（下标 $1 . . n$）逐点加入。

#include-code("code/数据结构A/Fenwick-Tree-树状数组.cpp")

=== 逆序对扩展
<逆序对扩展>
把元素按值从小到大排序逐个插入树状数组（位置为 `idx`），`ask(idx + 1, n)` 统计#strong[已插入且位置更靠后];的个数——即当前元素的逆序对贡献（等值元素按位置先小后大排序，不会被误计）。总复杂度 $cal(O) (N log N)$。

```cpp
struct BIT {
    int n;
    vector<int> w, chk;  // chk 为传入的待处理数组
    BIT(int n, auto &in) : n(n), w(n + 1), chk(in) {}
    /* 需要全部常规封装 */
    int get() {
        vector<array<int, 2>> alls;
        for (int i = 1; i <= n; i++) {
            alls.push_back({chk[i], i});
        }
        sort(alls.begin(), alls.end());
        int ans = 0;
        for (auto [val, idx] : alls) {
            ans += ask(idx + 1, n);
            add(idx, 1);
        }
        return ans;
    }
};
```

=== 前驱后继扩展（常规+第 k 小值查询+元素排名查询+元素前驱后继查询）
<前驱后继扩展常规第-k-小值查询元素排名查询元素前驱后继查询>
树状数组上按 $2^k$ 步长倍增下落，用前缀和计数定位第 $k$ 小，排名与前驱后继同理。注意，被查询的值都应该小于等于 $N$ ，否则会越界；如果离散化不可使用，则需要使用平衡树替代。

```cpp
struct BIT {
    int n;
    vector<int> w;
    BIT(int n) : n(n), w(n + 1) {}
    void add(int x, int v) {
        for (; x <= n; x += x & -x) {
            w[x] += v;
        }
    }
    int kth(int k) { // 查找第 k 小的值
        int ans = 0;
        for (int i = __lg(n); i >= 0; i--) {
            int val = ans + (1 << i);
            if (val <= n && w[val] < k) { // val <= n：原来写成 < n，漏掉 w[n] 的情况
                k -= w[val];
                ans = val;
            }
        }
        return ans + 1;
    }
    int get(int x) { // 查找 x 的排名
        int ans = 1;
        for (x--; x; x -= x & -x) {
            ans += w[x];
        }
        return ans;
    }
    int pre(int x) { return kth(get(x) - 1); } // 查找 x 的前驱
    int suf(int x) { return kth(get(x + 1)); } // 查找 x 的后继
};
const int N = 10000000;  // 可以用于在线处理平衡二叉树的全部要求
signed main() {
    BIT bit(N + 1);  // 在线处理不能够离散化，一定要开到比最大值更大
    int n;
    cin >> n;
    for (int i = 1; i <= n; i++) {
        int op, x;
        cin >> op >> x;
        if (op == 1) bit.add(x, 1);  // 插入 x
        else if (op == 2) bit.add(x, -1); // 删除任意一个 x
        else if (op == 3) cout << bit.get(x) << "\n"; // 查询 x 的排名
        else if (op == 4) cout << bit.kth(x) << "\n"; // 查询排名为 x 的数
        else if (op == 5) cout << bit.pre(x) << "\n"; // 求小于 x 的最大值（前驱）
        else if (op == 6) cout << bit.suf(x) << "\n"; // 求大于 x 的最小值（后继）
    }
}
```

=== 最值查询扩展（常规+区间最值查询+单点赋值）
<最值查询扩展常规区间最值查询单点赋值>
`update` 单点赋值、`getMax` 区间最值均为 $cal(O) (log N)$（原标注 $log log N$ 有误）。#strong[注意 `update` 里 `base[x] = max(base[x], v)` 只能把值改大];，若需要改小（如删除/下调）请改用线段树。

```cpp
template<typename T> struct BIT {
    int n;
    vector<T> w, base;
    #define low(x) (x & -x)
    BIT(int n, auto &in) : n(n), w(n + 1), base(n + 1) {
        for (int i = 1; i <= n; i++) {
            update(i, in[i]);
        }
    } /* 可以增加并使用常规封装中的几个函数 */
    void update(int x, int v) {  // 单点赋值
        base[x] = max(base[x], v);
        for (; x <= n; x += low(x)) {
            w[x] = max(w[x], v);
        }
    }
    T getMax(int l, int r) {  // 最值查询
        T ans = T();
        while (r >= l) {
            ans = max(base[r], ans);
            for (r--; r - low(r) >= l; r -= low(r)) {
                ans = max(w[r], ans);
            }
        }
        return ans;
    }
};
```

== 二维树状数组
<二维树状数组>
#strong[封装一：该版本不能同时进行区间修改+区间查询。];无离散化版本的空间占用为 $cal(O) (N M)$ 、建树复杂度为 $cal(O) (N M)$ 、单次查询复杂度为 $cal(O) (log N dot.op log M)$ 。

#include-code("code/数据结构A/二维树状数组.cpp")

#strong[封装二：该版本支持全部操作。];但是时空复杂度均比上一个版本多 $4$ 倍。

```cpp
struct BIT_2D {
    int n, m;
    vector<vector<int>> b1, b2, b3, b4;

    BIT_2D(int n, int m) : n(n), m(m) {
        b1.resize(n + 1, vector<int>(m + 1));
        b2.resize(n + 1, vector<int>(m + 1));
        b3.resize(n + 1, vector<int>(m + 1));
        b4.resize(n + 1, vector<int>(m + 1));
    }
    void add(auto &w, int x, int y, int k) {  // 单点修改
        for (int i = x; i <= n; i += i & -i) {
            for (int j = y; j <= m; j += j & -j) {
                w[i][j] += k;
            }
        }
    }
    void add(int x, int y, int k) {  // 多了一步计算
        add(b1, x, y, k);
        add(b2, x, y, k * (x - 1));
        add(b3, x, y, k * (y - 1));
        add(b4, x, y, k * (x - 1) * (y - 1));
    }
    void add(int x, int y, int X, int Y, int k) {  // 区块修改：二维差分
        X++, Y++;
        add(x, y, k), add(X, y, -k);
        add(X, Y, k), add(x, Y, -k);
    }
    int ask(auto &w, int x, int y) {  // 单点查询
        int ans = 0;
        for (int i = x; i; i -= i & -i) {
            for (int j = y; j; j -= j & -j) {
                ans += w[i][j];
            }
        }
        return ans;
    }
    int ask(int x, int y) {  // 多了一步计算
        int ans = 0;
        ans += x * y * ask(b1, x, y);
        ans -= y * ask(b2, x, y);
        ans -= x * ask(b3, x, y);
        ans += ask(b4, x, y);
        return ans;
    }
    int ask(int x, int y, int X, int Y) {  // 区块查询：二维前缀和
        x--, y--;
        return ask(X, Y) - ask(x, Y) - ask(X, y) + ask(x, y);
    }
};
```

== 线段树
<线段树>
把区间递归对半切开，每个节点管一段。区间修改打懒标记，下推时才传给儿子；查询把路过的节点合并起来。比树状数组慢，能做的运算更宽（最值、取模、可判谓词）。本板区间均为 $\[ l , r \)$。

=== LazyInfoTag 线段树
<lazyinfotag-线段树>
用法约定：区间#strong[左闭右开 $\[ l , r \)$];；`Info` 需提供 `operator+`（合并）与 `apply(Tag)`（打懒标记），`Tag` 需提供复合自身的 `apply(Tag)`；`modify(p, v)` 单点赋值，`rangeQuery(l,r)` / `rangeApply(l,r,tag)` 区间查询/区间标记，`findFirst/findLast(l, r, pred)` 在区间内找第一个/最后一个使 `pred` 为真的位置（返回 `-1` 表示不存在，要求 `pred` 具有区间可判性）。下方 `Info/Tag` 为空白壳，按题目自行填写（如区间加：`Tag.x` 为增量，`Info::apply` 累加长度倍增量）。

```cpp
template<typename Info, typename Tag>
struct LazySegmentTree {
    int n;
    std::vector<Info> info;
    std::vector<Tag> tag;
    LazySegmentTree() : n(0) {}
    LazySegmentTree(int n_, Info v_ = Info()) {
        init(n_, v_);
    }
    template<typename T>
    LazySegmentTree(std::vector<T> init_) {
        init(init_);
    }
    void init(int n_, Info v_ = Info()) {
        init(std::vector(n_, v_));
    }
    template<typename T>
    void init(std::vector<T> init_) {
        n = init_.size();
        info.assign(4 << std::__lg(n), Info());
        tag.assign(4 << std::__lg(n), Tag());
        std::function<void(int, int, int)> build = [&](int p, int l, int r) {
            if (r - l == 1) {
                info[p] = init_[l];
                return;
            }
            int m = (l + r) / 2;
            build(2 * p, l, m);
            build(2 * p + 1, m, r);
            pull(p);
            };
        build(1, 0, n);
    }
    void pull(int p) {
        info[p] = info[2 * p] + info[2 * p + 1];
    }
    void apply(int p, const Tag& v) {
        info[p].apply(v);
        tag[p].apply(v);
    }
    void push(int p) {
        apply(2 * p, tag[p]);
        apply(2 * p + 1, tag[p]);
        tag[p] = Tag();
    }
    void modify(int p, int l, int r, int x, const Info& v) {
        if (r - l == 1) {
            info[p] = v;
            return;
        }
        int m = (l + r) / 2;
        push(p);
        if (x < m) {
            modify(2 * p, l, m, x, v);
        }
        else {
            modify(2 * p + 1, m, r, x, v);
        }
        pull(p);
    }
    void modify(int p, const Info& v) {
        modify(1, 0, n, p, v);
    }
    Info rangeQuery(int p, int l, int r, int x, int y) {
        if (l >= y || r <= x) {
            return Info();
        }
        if (l >= x && r <= y) {
            return info[p];
        }
        int m = (l + r) / 2;
        push(p);
        return rangeQuery(2 * p, l, m, x, y) + rangeQuery(2 * p + 1, m, r, x, y);
    }
    Info rangeQuery(int l, int r) {
        return rangeQuery(1, 0, n, l, r);
    }
    void rangeApply(int p, int l, int r, int x, int y, const Tag& v) {
        if (l >= y || r <= x) {
            return;
        }
        if (l >= x && r <= y) {
            apply(p, v);
            return;
        }
        int m = (l + r) / 2;
        push(p);
        rangeApply(2 * p, l, m, x, y, v);
        rangeApply(2 * p + 1, m, r, x, y, v);
        pull(p);
    }
    void rangeApply(int l, int r, const Tag& v) {
        return rangeApply(1, 0, n, l, r, v);
    }
    template<typename F>
    int findFirst(int p, int l, int r, int x, int y, F pred) {
        if (l >= y || r <= x || !pred(info[p])) {
            return -1;
        }
        if (r - l == 1) {
            return l;
        }
        int m = (l + r) / 2;
        push(p);
        int res = findFirst(2 * p, l, m, x, y, pred);
        if (res == -1) {
            res = findFirst(2 * p + 1, m, r, x, y, pred);
        }
        return res;
    }
    template<typename F>
    int findFirst(int l, int r, F pred) {
        return findFirst(1, 0, n, l, r, pred);
    }
    template<typename F>
    int findLast(int p, int l, int r, int x, int y, F pred) {
        if (l >= y || r <= x || !pred(info[p])) {
            return -1;
        }
        if (r - l == 1) {
            return l;
        }
        int m = (l + r) / 2;
        push(p);
        int res = findLast(2 * p + 1, m, r, x, y, pred);
        if (res == -1) {
            res = findLast(2 * p, l, m, x, y, pred);
        }
        return res;
    }
    template<typename F>
    int findLast(int l, int r, F pred) {
        return findLast(1, 0, n, l, r, pred);
    }
};

struct Tag {
    i64 x = 0;
    void apply(Tag t) {
    }
};

struct Info {
    i64 x = 0;
    void apply(Tag t) {
    }
};
Info operator+(Info a, Info b) {
    return { a.x + b.x };
}
```

=== 快速线段树（单点修改+区间最值）
<快速线段树单点修改区间最值>
zkw 式非递归线段树，单点修改/区间最值均为 $cal(O) (log N)$，常数极小；区间为#strong[左闭右开 $\[ l , r \)$];，初值 `-2E9` 按题目改成对应下界（最小时用 `2E9`）。

#include-code("code/数据结构A/快速线段树单点修改+区间最值.cpp")

=== 区间取模
<区间取模>
原题需要进行“单点赋值+区间取模+区间求和” #link("https://codeforces.com/contest/438/problem/D")[See] 。该操作不需要懒标记。

需要额外维护一个区间最大值，当模数大于区间最大值时剪枝，否则进行单点取模。由于单点 $upright(M O D) < x$ 时 $x med mod med upright(M O D) < x / 2$ ，故单点取模至 $0$ 最劣只需要 $log x$ 次 。

=== 拆位运算
<拆位运算>
原题同上。每一位一棵线段树（或 bitset），区间异或变成该位的区间翻转。位之间独立，答案再拼回去。

== 树套树
<树套树>
外层按位置分区间，内层按值排序。一次操作拆成 $log N$ 个外节点，每个再 $log N$，故 $cal(O) (log^2 N)$。用来做动态区间第 $k$ 小、排名、前驱后继。

=== 线段树套平衡树
<线段树套平衡树>
线段树每个节点放一棵 pbds `tree`（存 `{值, 下标}` 去重键），单次 $cal(O) (log^2 N)$ 支持区间排名/前驱/后继：外区间拆成 $log N$ 个节点，内层 `order_of_key` 等为 $cal(O) (log N)$。`build(a)` 按位置建树并启发式合并，`update(pos, old_val, new_val)` 单点修改，查询区间半开 $\[ x , y \)$；前驱/后继不存在时返回 `±inf`。需要包含 pbds 头文件。

```cpp
#include <bits/stdc++.h>
#include <ext/pb_ds/assoc_container.hpp>
using namespace __gnu_pbds;
using pii = std::pair<int, int>;
const int inf = 2147483647;

tree<pii, null_type, std::less<pii>, rb_tree_tag, tree_order_statistics_node_update> ver;

template<typename Info>
struct SegmentTree {
    int n;
    std::vector<Info> info;

    SegmentTree() : n(0) {}

    void init(int n_) {
        n = n_;
        info.assign(4 << std::__lg(n), Info());
    }

public:
    // --- 初始化与构建 ---
    void build(const std::vector<int>& a) {
        _build(1, 0, n, a);
    }

private:
    void _build(int p, int l, int r, const std::vector<int>& a) {
        // 从叶子节点开始，向上启发式合并来构建整棵树
        if (r - l == 1) {
            if (l < a.size()) info[p].ver.insert({ a[l], l });
            return;
        }
        int m = (l + r) / 2;
        _build(2 * p, l, m, a);
        _build(2 * p + 1, m, r, a);

        // 启发式合并 (小树合并到大树)
        if (info[2 * p].ver.size() > info[2 * p + 1].ver.size()) {
            info[p].ver = info[2 * p].ver;
            for (const auto& item : info[2 * p + 1].ver) info[p].ver.insert(item);
        }
        else {
            info[p].ver = info[2 * p + 1].ver;
            for (const auto& item : info[2 * p].ver) info[p].ver.insert(item);
        }
    }

public:
    // 单点修改
    void update(int pos, int old_val, int new_val) {
        _update(1, 0, n, pos, old_val, new_val);
    }

    // 查询排名 (返回比 k 小的数的个数)
    int query_rank_count(int l, int r, int k) {
        return _query_rank_count(1, 0, n, l, r, k);
    }

    // 查询前驱
    int query_pred(int l, int r, int k) {
        return _query_pred(1, 0, n, l, r, k);
    }

    // 查询后继
    int query_succ(int l, int r, int k) {
        return _query_succ(1, 0, n, l, r, k);
    }

private:
    void _update(int p, int l, int r, int pos, int old_val, int new_val) {
        info[p].ver.erase({ old_val, pos });
        info[p].ver.insert({ new_val, pos });
        if (r - l == 1) return;
        int m = (l + r) / 2;
        if (pos < m) _update(2 * p, l, m, pos, old_val, new_val);
        else _update(2 * p + 1, m, r, pos, old_val, new_val);
    }

    int _query_rank_count(int p, int l, int r, int x, int y, int k) {
        if (l >= y || r <= x) return 0;
        if (l >= x && r <= y) {
            return info[p].ver.order_of_key({ k, -1 });
        }
        int m = (l + r) / 2;
        return _query_rank_count(2 * p, l, m, x, y, k) + _query_rank_count(2 * p + 1, m, r, x, y, k);
    }

    int _query_pred(int p, int l, int r, int x, int y, int k) {
        if (l >= y || r <= x) return -inf;
        if (l >= x && r <= y) {
            auto it = info[p].ver.lower_bound({ k, -1 });
            if (it == info[p].ver.begin()) return -inf;
            return (--it)->first;
        }
        int m = (l + r) / 2;
        return std::max(_query_pred(2 * p, l, m, x, y, k), _query_pred(2 * p + 1, m, r, x, y, k));
    }

    int _query_succ(int p, int l, int r, int x, int y, int k) {
        if (l >= y || r <= x) return inf;
        if (l >= x && r <= y) {
            auto it = info[p].ver.upper_bound({ k, inf });
            if (it == info[p].ver.end()) return inf;
            return it->first;
        }
        int m = (l + r) / 2;
        return std::min(_query_succ(2 * p, l, m, x, y, k), _query_succ(2 * p + 1, m, r, x, y, k));
    }
};

struct Info {
    tree<pii, null_type, std::less<pii>, rb_tree_tag, tree_order_statistics_node_update> ver;
};
```

== 小波矩阵树：高效静态区间第 K 大查询
<小波矩阵树高效静态区间第-k-大查询>
手写 `bitset` 压位，以 $cal(O) (N log N)$ 的时间复杂度和 $cal(O) (N + frac(N log N, 64))$ 的空间建树后，实现单次 $cal(O) (log N)$ 复杂度的区间第 $k$ 大值询问。建议使用 $mono("0-idx")$ 计数法，但是经测试 $mono("1-idx")$ 也有效，但需要更多的检验。使用前定义 `using u64 = unsigned long long;`。

#include-code("code/数据结构A/小波矩阵树：高效静态区间第-K-大查询.cpp")

== 主席树 \(可持久化线段树)
<主席树-可持久化线段树>
$cal(O) (N log N)$ 建树与单点修改（每步新建一条链），查询 $cal(O) (log N)$。原理：每次修改只新建根到目标叶子的一条链（$log$ 个节点），其余子树与旧版本共享——`root[i]` 因此就是「前 $i$ 个元素」的权值线段树，区间 $[l , r]$ 的信息由两版本相减得到（`kth` 里的 `cnt` 相减即此）。用法：把值域离散化到 $[1 , m]$，`modify(root[i] = root[i - 1], ..., 离散值)` 建版本；静态区间第 $k$ 小查询 `kth(root[r], root[l - 1], 1, m, k)`。数组开 `4 * N + 17 * N`（约 17 层/次修改），`N` 按题目改。

#include-code("code/数据结构A/主席树-可持久化线段树.cpp")

== 普通莫队
<普通莫队>
离线区间询问：按左端点所在块排序，同一块内右端点来回扫（奇偶块反向），相邻询问的区间差均摊 $O (sqrt(N))$。先写 `add`/`del` 维护当前窗口答案 `val`，再扩缩 $[l , r]$。下标 $1 . . n$；块长可取 $n \/ sqrt(q)$，也可 $sqrt(n)$ 或 $317$（对应 $n = 10^5$）。

#include-code("code/数据结构A/普通莫队.cpp")

需要注意的是，在普通莫队中，`K` 数组的作用是根据左边界的值进行排序，当询问次数很少时（$q lt.double n$），可以直接合并到 `query` 数组中。`add`/`del` 与 `val` 均为#strong[待填钩子];：`add(x)` 加入一个元素并更新当前答案 `val`，`del(x)` 反之，最后 `ans[id] = val` 记答案。

== 带修改的莫队 \(带时间维度的莫队)
<带修改的莫队-带时间维度的莫队>
普通莫队再加时间维：询问记下「做到第几次修改」，$l , r , t$ 三个指针一起移动。块长取 $n^(2 \/ 3)$（$n = 10^5$ 时约 $2154$，也可用 `pow(n, 2./3)`），三维移动均摊 $cal(O) (n^(5 \/ 3))$。`time` 把修改点换进窗口或撤销；`a2`/`a4` 需自行定义，`add`/`del` 为钩子，答案记在 `val`。

```cpp
void solve(){
    int n, m;    
    std::cin >> n >> m;
    std::vector<int> a(n + 1);
    for (int i = 1;i <= n;i++)   std::cin >> a[i];

    std::vector<a4> q{ {} };        // {左区间, 右区间, 累计修改次数, 下标}
    std::vector<a2> upd{ {} };      // {修改位置，修改的值}
    for (int i = 1;i <= m;i++) {
        char op;    std::cin >> op;
        if (op == 'Q') {
            int l, r;   std::cin >> l >> r;
            q.push_back(a4{ l,r,(int)upd.size() - 1 ,(int)q.size() });
        }
        else {
            int idx, val;   std::cin >> idx >> val;
            upd.push_back({ idx,val });
        }
    }

    int block = max(1, (int)pow(n, 2.0 / 3));  // n ^ (2 / 3)，原写死 2610 须按 n 改
    std::vector<int> b(n + 1);
    for (int i = 1;i <= n;i++) b[i] = (i - 1) / block + 1;
    std::sort(q.begin() + 1, q.end(), [&](auto x, auto y) {
        if (b[x[0]] != b[y[0]]) return x[0] < y[0];
        if (b[x[1]] != b[y[1]]) return x[1] < y[1];
        return x[3] < y[3];
        });

    n = q.size() - 1;
    int l = 1, r = 0, t = 0, val = 0;
    std::vector<int> ans(n + 1);
    for (int i = 1;i <= n;i++) {
        auto [ql, qr, qt, id] = q[i];

        auto add = [&](int x) {};
        auto del = [&](int x) {};
        auto time = [&](int t, int l, int r) {
            int pos = upd[t][0];
            int& val = upd[t][1];
            if (pos >= l && pos <= r) {
                del(a[pos]);
                add(val);
            }
            std::swap(a[pos], val);
            };

        while (l > ql) add(a[--l]);
        while (r < qr) add(a[++r]);
        while (l < ql) del(a[l++]);
        while (r > qr) del(a[r--]);
        while (t < qt) time(++t, ql, qr);
        while (t > qt) time(t--, ql, qr);

        ans[id] = val;  // 原来写成 cnt（未定义变量）
    }
    for (int i = 1;i <= n;i++)    std::cout << ans[i] << '\n';
}
```

== 回滚莫队
<回滚莫队>
用于#strong[删除难实现];的问题（信息只有”加”容易撤销：如并查集、众数）：只比普通莫队多一个”右指针单调向右，左指针临时左移后回滚”的技巧。同一块内的询问直接暴力（三次遍历做”加入/统计/撤销”），跨块询问中右端点只增、左端点每次临时扩展后 `del` 撤销（#strong[不真正删除];，而是退回临时指针）。复杂度 $cal(O) (N sqrt(Q) dot.op T_(a d d))$。`a3 = array<int, 3>` 需自行定义，`add(x, res)` 中 `res` 引用传递更新答案。

```cpp
void solve(){
    std::vector<a3> q(m + 1);
    for (int i = 1;i <= m;i++) {
        int l, r;   std::cin >> l >> r;
        q[i] = { l,r,i };
    }
    int block = n / std::min<int>(n, sqrt(m));
    std::vector<int> b(n + 1);
    for (int i = 1;i <= n;i++) b[i] = (i - 1) / block + 1;
    std::sort(q.begin() + 1, q.end(), [&](auto x, auto y) {
        if (b[x[0]] != b[y[0]]) return x[0] < y[0];
        return x[1] < y[1];
        });

    int l = 1, r = 0, cur_block = 0, tmpl;
    int res = 0;
    std::vector<i64> ans(m + 1);
    for (int i = 1;i <= m;i++) {
        auto [ql, qr, id] = q[i];

        if (b[ql] == b[qr]) {
            //暴力
            for (int j = ql;j <= qr;j++);
            //遍历答案
            for (int j = ql;j <= qr;j++);
            //撤销
            for (int j = ql;j <= qr;j++);
            continue;
        }

        auto add = [&](int x, i64& res) {};
        auto del = [&](int x) {};

        //若当前更新到了一个新的块
        if (b[ql] != cur_block) {
            while (r > b[ql] * block) del(w[r--]);
            while (l < b[ql] * block + 1) del(w[l++]);
            res = 0;
            cur_block = b[ql];
        }
        //先移动右指针
        while (r < qr) add(w[++r], res);
        tmpl = l;
        i64 tmpres = res;
        //查询答案
        while (tmpl > ql) add(w[--tmpl], tmpres);
        ans[id] = tmpres;
        //回滚
        while (tmpl < l) del(w[tmpl++]);
    }

    for (int i = 1;i <= m;i++)   std::cout << ans[i] << '\n';
}
```

== 对顶堆
<对顶堆>
用两个 `multiset` 维护#strong[动态中位数];（支持插入/删除），哨兵 `±kInf` 避免边界判断：`less` 保存较小的一半（含中位数），`greater` 保存较大的一半，`adjust()` 保持两者大小差 $lt.eq 1$。插入按与 `*greater.begin()` 比较分流，删除在两个集合内查找；当前中位数为 `*less.rbegin()`（奇数个元素时正中间）。若改为严格对顶”堆”，把 `multiset` 换成 `priority_queue` 并在删除时惰性弹出（配合标记）可更快。

#include-code("code/数据结构A/对顶堆.cpp")

== KD Tree
<kd-tree>
第 $k$ 维上的单次查询复杂度最坏为 $cal(O) (n^(1 - k^(- 1)))$。数组版（容量 `N = 1e5 + 10`，`K` 维），`insert` 平衡因子 $alpha = 0.725$ 触发拍平重建；`build` 按#strong[方差最大的维];划分、`nth_element` 取中位数。下方 `query(a)` 统计#strong[所有维都 ≤ a\[i\]] 的点数（`out` 剪枝整块在查询域之外，`all` 整块皆计入，`in` 单点判定）；常见扩展：最近点查询改成带界最值剪枝。

#include-code("code/数据结构A/KD-Tree.cpp")
