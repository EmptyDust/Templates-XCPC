## 数据结构 A

### 笛卡尔树

小根笛卡尔树：下标为键（中序遍历为原序列）、值为堆（小根）的二叉树，单调栈 $\mathcal O(N)$ 建树。常用于 RMQ 与 LCA 互转（区间最小值 = 两端点 LCA 处的值）。下方 `ls/rs` 为左右儿子，`-1` 表示空。

```cpp
cin >> n;
for (int i = 0;i < n;++i)cin >> nums[i];
for (int i = 0;i < n;++i)rs[i] = -1;
for (int i = 0;i < n;++i)ls[i] = -1;
top = 0;
for (int i = 0; i < n; i++) {
    int k = top;
    while (k > 0 && nums[stk[k - 1]] > nums[i]) k--;
    if (k) rs[stk[k - 1]] = i;  // rs代表笛卡尔树每个节点的右儿子
    if (k < top) ls[i] = stk[k];  // ls代表笛卡尔树每个节点的左儿子
    stk[k++] = i;
    top = k;
}
```

### dsu 并查集

维护不相交集合：同一块共用一个根。路径压缩把访问链直接接到根上，按秩/按大小合并压树高，均摊约 $\mathcal O(\alpha(N))$。判连通、Kruskal、维护块内点数/边数都用它。下标按各封装是 $0..n-1$ 或 $1..n$。

#### 路径优化(普遍)

只做路径压缩，合并不看大小。最短，均摊仍约 $\mathcal O(\alpha(N))$。下标 $1..n$。`merge` 成功返回 true。

```cpp
struct dsu {
    std::vector<int> d;
    dsu(int n) { d.resize(n + 1); iota(d.begin(), d.end(), 0); }
    int get_root(int x) { return d[x] = (x == d[x] ? x : get_root(d[x])); };
    bool merge(int u, int v) {
        if (get_root(u) != get_root(v)) {
            d[get_root(u)] = get_root(v);
            return true;
        }
        else return false;
    }
};
```

#### 根据集合的大小优化

数组版并查集：根为正数存集合大小的相反约定——这里根存**正整数大小**，非根存**负的父编号**（`unicnt[x] <= 0` 时 `-unicnt[x]` 为父）；`uni` 按大小合并。均摊约 $\mathcal O(\alpha(N))$。

```cpp
//左移位数根据节点个数定
#define UFLIMIT (2<<17)
int unicnt[UFLIMIT];
void ufinit(int n) {
    for (int i = 0;i < n;i++)unicnt[i] = 1;
}
int ufroot(int x) { return unicnt[x] <= 0 ? -(unicnt[x] = -ufroot(-unicnt[x])) : x; }
int ufsame(int x, int y) { return ufroot(x) == ufroot(y); }
void uni(int x, int y) {
    if ((x = ufroot(x)) == (y = ufroot(y)))return;
    if (unicnt[x] < unicnt[y])std::swap(x, y);
    unicnt[x] += unicnt[y];
    unicnt[y] = -x;
}
```

#### 按秩合并优化

按秩（树高下界）合并 + 路径压缩，均摊约 $\mathcal O(\alpha(N))$，且比朴素路径压缩有更严格的最坏界。

```cpp
class UnionFind {
private:
    std::vector<int> parent;
    std::vector<int> rank;
public:
    UnionFind(int n) {
        parent.resize(n, 0);
        rank.resize(n, 0);
        iota(parent.begin(), parent.end(), 0);
    }
    int find(int x) {
        if (parent[x] == x)
            return x;
        return parent[x] = find(parent[x]);
    }
    void merge(int x, int y) {
        int rootX = find(x);
        int rootY = find(y);
        if (rootX == rootY) return;
        if (rank[rootX] > rank[rootY])
            std::swap(rootX, rootY);
        parent[rootX] = rootY;
        if (rank[rootX] == rank[rootY]) {
            rank[rootY]++;
        }
    }
    bool isConnect(int x, int y) {
        return find(x) == find(y);
    }
};
```

#### 常用操作

路径压缩，并维护块内点数 `p`、边数 `e`、是否有自环 `f`。`merge` 把编号小的根挂到大的上。`same` / `size` / `E` / `F` 查询前都会先 `get` 到根。

```cpp
struct DSU {
    vector<int> fa, p, e, f;

    DSU(int n) {
        fa.resize(n + 1);
        iota(fa.begin(), fa.end(), 0);
        p.resize(n + 1, 1);
        e.resize(n + 1);
        f.resize(n + 1);
    }
    int get(int x) {
        while (x != fa[x]) {
            x = fa[x] = fa[fa[x]];
        }
        return x;
    }
    bool merge(int x, int y) { // 实际是"编号小的合并到大的上"（见下行 swap）
        if (x == y) f[get(x)] = 1;
        x = get(x), y = get(y);
        e[x]++;
        if (x == y) return false;
        if (x < y) swap(x, y); // 将编号小的合并到大的上
        fa[y] = x;
        f[x] |= f[y], p[x] += p[y], e[x] += e[y];
        return true;
    }
    bool same(int x, int y) {
        return get(x) == get(y);
    }
    bool F(int x) { // 判断连通块内是否存在自环
        return f[get(x)];
    }
    int size(int x) { // 输出连通块中点的数量
        return p[get(x)];
    }
    int E(int x) { // 输出连通块中边的数量
        return e[get(x)];
    }
};
```

### ST 表

用于解决区间可重复贡献问题，需要满足 $x \text{ 运算符 } x=x$ （如区间最大值：$\max(x,x)=x$ 、区间 $\gcd$：$\gcd(x,x)=x$ 等），但是不支持修改操作。$\mathcal O(N\log N)$ 预处理，$\mathcal O(1)$ 查询。下方 `vt` 的第二维硬编码为 `30`（支持 $n\le 2^{30}$），按 $n$ 改为 `__lg(n)+1` 即可；合并运算由 `Info::operator+` 表达。

```cpp
template<typename T>
struct sparse_table
{
    std::vector<std::vector<T>> vt;
    sparse_table(std::vector<T> a) {
        int n = a.size();
        vt.assign(n, std::vector<T>(30));
        for (int i = 0;i < n;++i)
            vt[i][0] = a[i];
        for (int s = 1;s < 30;++s) {
            for (int i = 0;i < n;++i) {
                int j = i + (1 << s - 1);
                if (j < n) {
                    vt[i][s] = vt[i][s - 1] + vt[i + (1 << s - 1)][s - 1];
                }
                else vt[i][s] = vt[i][s - 1];
            }
        }
    }
    T query(int l, int r) {//[l,r)
        if (l == r) return T(0);
        int len = r - l;
        int x = std::__lg(len);
        return vt[l][x] + vt[r - (1 << x)][x];
    }
};

struct Info
{
    i64 a;
    Info operator+(Info x) {
        return Info(std::max(a, x.a));
    }
};
```

### Fenwick Tree 树状数组

下标从 $1$ 开始。`x & -x` 取出最低位 $1$，沿这条链走到父区间；单点加往上走、前缀和往下走，是同一棵隐式树的对偶。`ask(l, r)` 为 $[l, r]$ 区间和。不能直接区间覆盖（改差分）。构造时从 `in`（下标 $1..n$）逐点加入。

```cpp
template<typename T> struct BIT {
    int n;
    vector<T> w;
    BIT(int n, auto &in) : n(n), w(n + 1) { // 预处理填值
        for (int i = 1; i <= n; i++) {
            add(i, in[i]);
        }
    }
    void add(int x, T v) {
        for (; x <= n; x += x & -x) {
            w[x] += v;
        }
    }
    T ask(int x) { // 前缀和查询
        T ans = 0;
        for (; x; x -= x & -x) {
            ans += w[x];
        }
        return ans;
    }
    T ask(int l, int r) { // 差分实现区间和查询
        return ask(r) - ask(l - 1);
    }
};
```

#### 逆序对扩展

把元素按值从小到大排序逐个插入树状数组（位置为 `idx`），`ask(idx + 1, n)` 统计**已插入且位置更靠后**的个数——即当前元素的逆序对贡献（等值元素按位置先小后大排序，不会被误计）。总复杂度 $\mathcal O(N\log N)$。

```cpp
struct BIT {
    int n;
    vector<int> w, chk; // chk 为传入的待处理数组
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

#### 前驱后继扩展（常规+第 k 小值查询+元素排名查询+元素前驱后继查询）

注意，被查询的值都应该小于等于 $N$ ，否则会越界；如果离散化不可使用，则需要使用平衡树替代。

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
const int N = 10000000; // 可以用于在线处理平衡二叉树的全部要求
signed main() {
    BIT bit(N + 1); // 在线处理不能够离散化，一定要开到比最大值更大
    int n;
    cin >> n;
    for (int i = 1; i <= n; i++) {
        int op, x;
        cin >> op >> x;
        if (op == 1) bit.add(x, 1); // 插入 x
        else if (op == 2) bit.add(x, -1); // 删除任意一个 x
        else if (op == 3) cout << bit.get(x) << "\n"; // 查询 x 的排名
        else if (op == 4) cout << bit.kth(x) << "\n"; // 查询排名为 x 的数
        else if (op == 5) cout << bit.pre(x) << "\n"; // 求小于 x 的最大值（前驱）
        else if (op == 6) cout << bit.suf(x) << "\n"; // 求大于 x 的最小值（后继）
    }
}
```

#### 最值查询扩展（常规+区间最值查询+单点赋值）

`update` 单点赋值、`getMax` 区间最值均为 $\mathcal O(\log N)$（原标注 $\log\log N$ 有误）。**注意 `update` 里 `base[x] = max(base[x], v)` 只能把值改大**，若需要改小（如删除/下调）请改用线段树。

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
    void update(int x, int v) { // 单点赋值
        base[x] = max(base[x], v);
        for (; x <= n; x += low(x)) {
            w[x] = max(w[x], v);
        }
    }
    T getMax(int l, int r) { // 最值查询
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

### 二维树状数组

**封装一：该版本不能同时进行区间修改+区间查询。**无离散化版本的空间占用为 $\mathcal O(NM)$ 、建树复杂度为 $\mathcal O(NM)$ 、单次查询复杂度为 $\mathcal O(\log N\cdot \log M)$ 。

```cpp
struct BIT_2D {
    int n, m;
    vector<vector<int>> w;

    BIT_2D(int n, int m) : n(n), m(m) {
        w.resize(n + 1, vector<int>(m + 1));
    }
    void add(int x, int y, int k) {
        for (int i = x; i <= n; i += i & -i) {
            for (int j = y; j <= m; j += j & -j) {
                w[i][j] += k;
            }
        }
    }
    void add(int x, int y, int X, int Y, int k) { // 区块修改：二维差分
        X++, Y++;
        add(x, y, k), add(X, y, -k);
        add(X, Y, k), add(x, Y, -k);
    }
    int ask(int x, int y) { // 单点查询
        int ans = 0;
        for (int i = x; i; i -= i & -i) {
            for (int j = y; j; j -= j & -j) {
                ans += w[i][j];
            }
        }
        return ans;
    }
    int ask(int x, int y, int X, int Y) { // 区块查询：二维前缀和
        x--, y--;
        return ask(X, Y) - ask(x, Y) - ask(X, y) + ask(x, y);
    }
};
```

**封装二：该版本支持全部操作。**但是时空复杂度均比上一个版本多 $4$ 倍。

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
    void add(auto &w, int x, int y, int k) { // 单点修改
        for (int i = x; i <= n; i += i & -i) {
            for (int j = y; j <= m; j += j & -j) {
                w[i][j] += k;
            }
        }
    }
    void add(int x, int y, int k) { // 多了一步计算
        add(b1, x, y, k);
        add(b2, x, y, k * (x - 1));
        add(b3, x, y, k * (y - 1));
        add(b4, x, y, k * (x - 1) * (y - 1));
    }
    void add(int x, int y, int X, int Y, int k) { // 区块修改：二维差分
        X++, Y++;
        add(x, y, k), add(X, y, -k);
        add(X, Y, k), add(x, Y, -k);
    }
    int ask(auto &w, int x, int y) { // 单点查询
        int ans = 0;
        for (int i = x; i; i -= i & -i) {
            for (int j = y; j; j -= j & -j) {
                ans += w[i][j];
            }
        }
        return ans;
    }
    int ask(int x, int y) { // 多了一步计算
        int ans = 0;
        ans += x * y * ask(b1, x, y);
        ans -= y * ask(b2, x, y);
        ans -= x * ask(b3, x, y);
        ans += ask(b4, x, y);
        return ans;
    }
    int ask(int x, int y, int X, int Y) { // 区块查询：二维前缀和
        x--, y--;
        return ask(X, Y) - ask(x, Y) - ask(X, y) + ask(x, y);
    }
};
```

### 线段树

把区间递归对半切开，每个节点管一段。区间修改打懒标记，下推时才传给儿子；查询把路过的节点合并起来。比树状数组慢，能做的运算更宽（最值、取模、可判谓词）。本板区间均为 $[l,r)$。

#### LazyInfoTag 线段树

用法约定：区间**左闭右开 $[l, r)$**；`Info` 需提供 `operator+`（合并）与 `apply(Tag)`（打懒标记），`Tag` 需提供复合自身的 `apply(Tag)`；`modify(p, v)` 单点赋值，`rangeQuery(l,r)` / `rangeApply(l,r,tag)` 区间查询/区间标记，`findFirst/findLast(l, r, pred)` 在区间内找第一个/最后一个使 `pred` 为真的位置（返回 `-1` 表示不存在，要求 `pred` 具有区间可判性）。下方 `Info/Tag` 为空白壳，按题目自行填写（如区间加：`Tag.x` 为增量，`Info::apply` 累加长度倍增量）。

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

#### 快速线段树（单点修改+区间最值）

zkw 式非递归线段树，单点修改/区间最值均为 $\mathcal O(\log N)$，常数极小；区间为**左闭右开 $[l, r)$**，初值 `-2E9` 按题目改成对应下界（最小时用 `2E9`）。

```cpp
struct Segt {
    vector<int> w;
    int n;
    Segt(int n) : w(2 * n, (int)-2E9), n(n) {}

    void modify(int pos, int val) {
        for (w[pos += n] = val; pos > 1; pos /= 2) {
            w[pos / 2] = max(w[pos], w[pos ^ 1]);
        }
    }

    int ask(int l, int r) {
        int res = -2E9;
        for (l += n, r += n; l < r; l /= 2, r /= 2) {
            if (l % 2) res = max(res, w[l++]);
            if (r % 2) res = max(res, w[--r]);
        }
        return res;
    }
};
```

#### 区间取模

原题需要进行“单点赋值+区间取模+区间求和” [See](https://codeforces.com/contest/438/problem/D) 。该操作不需要懒标记。

需要额外维护一个区间最大值，当模数大于区间最大值时剪枝，否则进行单点取模。由于单点 ${\tt MOD}<x$ 时 $x \bmod {\tt MOD}<\frac{x}{2}$ ，故单点取模至 $0$ 最劣只需要 $\log x$ 次 。

#### 拆位运算

原题同上。每一位一棵线段树（或 bitset），区间异或变成该位的区间翻转。位之间独立，答案再拼回去。

### 树套树

外层按位置分区间，内层按值排序。一次操作拆成 $\log N$ 个外节点，每个再 $\log N$，故 $\mathcal O(\log^2 N)$。用来做动态区间第 $k$ 小、排名、前驱后继。

#### 线段树套平衡树

线段树每个节点放一棵 pbds `tree`（存 `{值, 下标}` 去重键），单次 $\mathcal O(\log^2 N)$ 支持区间排名/前驱/后继：外区间拆成 $\log N$ 个节点，内层 `order_of_key` 等为 $\mathcal O(\log N)$。`build(a)` 按位置建树并启发式合并，`update(pos, old_val, new_val)` 单点修改，查询区间半开 $[x, y)$；前驱/后继不存在时返回 `±inf`。需要包含 pbds 头文件。

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

### 小波矩阵树：高效静态区间第 K 大查询

手写 `bitset` 压位，以 $\mathcal O(N \log N)$ 的时间复杂度和 $\mathcal O(N + \frac{N \log N}{64})$ 的空间建树后，实现单次 $\mathcal O(\log N)$ 复杂度的区间第 $k$ 大值询问。建议使用 $\texttt{0-idx}$ 计数法，但是经测试 $\texttt{1-idx}$ 也有效，但需要更多的检验。使用前定义 `using u64 = unsigned long long;`。

```cpp
#define __count(x) __builtin_popcountll(x)
struct Wavelet {
    vector<int> val, sum;
    vector<u64> bit;
    int t, n;

    int getSum(int i) {
        return sum[i >> 6] + __count(bit[i >> 6] & ((1ULL << (i & 63)) - 1));
    }

    Wavelet(vector<int> v) : val(v), n(v.size()) {
        sort(val.begin(), val.end());
        val.erase(unique(val.begin(), val.end()), val.end());

        int n_ = val.size();
        t = __lg(2 * n_ - 1);
        bit.resize((t * n + 64) >> 6);
        sum.resize(bit.size());
        vector<int> cnt(n_ + 1);

        for (int &x : v) {
            x = lower_bound(val.begin(), val.end(), x) - val.begin();
            cnt[x + 1]++;
        }
        for (int i = 1; i < n_; ++i) {
            cnt[i] += cnt[i - 1];
        }
        for (int j = 0; j < t; ++j) {
            for (int i : v) {
                int tmp = i >> (t - 1 - j);
                int pos = (tmp >> 1) << (t - j);
                auto setBit = [&](int i, u64 v) {
                    bit[i >> 6] |= (v << (i & 63));
                };
                setBit(j * n + cnt[pos], tmp & 1);
                cnt[pos]++;
            }
            for (int i : v) {
                cnt[(i >> (t - j)) << (t - j)]--;
            }
        }
        for (int i = 1; i < sum.size(); ++i) {
            sum[i] = sum[i - 1] + __count(bit[i - 1]);
        }
    }

    int small(int l, int r, int k) {
        r++;
        for (int j = 0, x = 0, y = n, res = 0;; ++j) {
            if (j == t) return val[res];
            int A = getSum(n * j + x), B = getSum(n * j + l);
            int C = getSum(n * j + r), D = getSum(n * j + y);
            int ab_zeros = r - l - C + B;
            if (ab_zeros > k) {
                res = res << 1;
                y -= D - A;
                l -= B - A;
                r -= C - A;
            } else {
                res = (res << 1) | 1;
                k -= ab_zeros;
                x += y - x - D + A;
                l += y - l - D + B;
                r += y - r - D + C;
            }
        }
    }
    int large(int l, int r, int k) {
        return small(l, r, r - l - k);
    }
};
```

### 主席树（可持久化线段树）

$\mathcal O(N\log N)$ 建树与单点修改（每步新建一条链），查询 $\mathcal O(\log N)$。用法：把值域离散化到 $[1, m]$，`modify(root[i] = root[i - 1], ..., 离散值)` 建版本；静态区间第 $k$ 小查询 `kth(root[r], root[l - 1], 1, m, k)`。数组开 `4 * N + 17 * N`（约 17 层/次修改），`N` 按题目改。

```cpp
struct PresidentTree {
    static constexpr int N = 2e5 + 10;
    int cntNodes, root[N];

    struct node {
        int l, r;
        int cnt;
    }tr[4 * N + 17 * N];

    //u 是新节点，v 是旧节点
    void modify(int& u, int v, int l, int r, int x) {
        u = ++cntNodes;
        tr[u] = tr[v];
        tr[u].cnt++;
        if (l == r) return;
        int mid = (l + r) / 2;
        if (x <= mid) modify(tr[u].l, tr[v].l, l, mid, x);
        else modify(tr[u].r, tr[v].r, mid + 1, r, x);
    }

    //u 是新节点，v 是旧节点
    int kth(int u, int v, int l, int r, int k) {
        if (l == r) return l;
        int res = tr[tr[u].l].cnt - tr[tr[v].l].cnt;
        int mid = (l + r) / 2;
        if (k <= res) return kth(tr[u].l, tr[v].l, l, mid, k);
        else return kth(tr[u].r, tr[v].r, mid + 1, r, k - res);
    }
};
```

### 普通莫队

离线区间询问：按左端点所在块排序，同一块内右端点来回扫（奇偶块反向），相邻询问的区间差均摊 $O(\sqrt N)$。先写 `add`/`del` 维护当前窗口答案 `val`，再扩缩 $[l,r]$。下标 $1..n$；块长可取 $n/\sqrt q$，也可 $\sqrt n$ 或 $317$（对应 $n=10^5$）。

```cpp
signed main() {
    int n;
    cin >> n;
    vector<int> w(n + 1);
    for (int i = 1; i <= n; i++) {
        cin >> w[i];
    }

    int q;
    cin >> q;
    vector<array<int, 3>> query(q + 1);
    for (int i = 1; i <= q; i++) {
        int l, r;
        cin >> l >> r;
        query[i] = {l, r, i};
    }

    int Knum = n / min<int>(n, sqrt(q)); // 计算块长
    vector<int> K(n + 1);
    for (int i = 1; i <= n; i++) { // 固定块长
        K[i] = (i - 1) / Knum + 1;
    }
    sort(query.begin() + 1, query.end(), [&](auto x, auto y) {
        if (K[x[0]] != K[y[0]]) return x[0] < y[0];
        if (K[x[0]] & 1) return x[1] < y[1];
        return x[1] > y[1];
    });

    int l = 1, r = 0, val = 0;
    vector<int> ans(q + 1);
    for (int i = 1; i <= q; i++) {
        auto [ql, qr, id] = query[i];
        auto add = [&](int x) -> void {};
        auto del = [&](int x) -> void {};
        while (l > ql) add(w[--l]);
        while (r < qr) add(w[++r]);
        while (l < ql) del(w[l++]);
        while (r > qr) del(w[r--]);
        ans[id] = val;
    }
    for (int i = 1; i <= q; i++) {
        cout << ans[i] << endl;
    }
}
```

 需要注意的是，在普通莫队中，`K` 数组的作用是根据左边界的值进行排序，当询问次数很少时（$q \ll n$），可以直接合并到 `query` 数组中。`add`/`del` 与 `val` 均为**待填钩子**：`add(x)` 加入一个元素并更新当前答案 `val`，`del(x)` 反之，最后 `ans[id] = val` 记答案。

### 带修改的莫队（带时间维度的莫队）

普通莫队再加时间维：询问记下「做到第几次修改」，$l,r,t$ 三个指针一起移动。块长取 $n^{2/3}$（$n=10^5$ 时约 $2154$，也可用 `pow(n, 2./3)`），三维移动均摊 $\mathcal O(n^{5/3})$。`time` 把修改点换进窗口或撤销；`a2`/`a4` 需自行定义，`add`/`del` 为钩子，答案记在 `val`。

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

    int block = max(1, (int)pow(n, 2.0 / 3));   // n ^ (2 / 3)，原写死 2610 须按 n 改
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

        ans[id] = val; // 原来写成 cnt（未定义变量）
    }
    for (int i = 1;i <= n;i++)    std::cout << ans[i] << '\n';
}
```

### 回滚莫队

用于**删除难实现**的问题（信息只有"加"容易撤销：如并查集、众数）：只比普通莫队多一个"右指针单调向右，左指针临时左移后回滚"的技巧。同一块内的询问直接暴力（三次遍历做"加入/统计/撤销"），跨块询问中右端点只增、左端点每次临时扩展后 `del` 撤销（**不真正删除**，而是退回临时指针）。复杂度 $\mathcal O(N\sqrt{Q}\cdot T_{add})$。`a3 = array<int, 3>` 需自行定义，`add(x, res)` 中 `res` 引用传递更新答案。

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

### 对顶堆

用两个 `multiset` 维护**动态中位数**（支持插入/删除），哨兵 `±kInf` 避免边界判断：`less` 保存较小的一半（含中位数），`greater` 保存较大的一半，`adjust()` 保持两者大小差 $\le 1$。插入按与 `*greater.begin()` 比较分流，删除在两个集合内查找；当前中位数为 `*less.rbegin()`（奇数个元素时正中间）。若改为严格对顶"堆"，把 `multiset` 换成 `priority_queue` 并在删除时惰性弹出（配合标记）可更快。

```cpp
namespace Set {
    const int kInf = 1e9 + 2077;
    std::multiset<int> less, greater;
    void init() {
        less.clear(), greater.clear();
        less.insert(-kInf), greater.insert(kInf);
    }
    void adjust() {
        while (less.size() > greater.size() + 1) {
            std::multiset<int>::iterator it = (--less.end());
            greater.insert(*it);
            less.erase(it);
        }
        while (greater.size() > less.size()) {
            std::multiset<int>::iterator it = greater.begin();
            less.insert(*it);
            greater.erase(it);
        }
    }
    void add(int val_) {
        if (val_ <= *greater.begin()) less.insert(val_);
        else greater.insert(val_);
        adjust();
    }
    void del(int val_) {
        std::multiset<int>::iterator it = less.lower_bound(val_);
        if (it != less.end()) {
            less.erase(it);
        }
        else {
            it = greater.lower_bound(val_);
            greater.erase(it);
        }
        adjust();
    }
    int get_middle() {
        return *less.rbegin();
    }
}
```

### KD Tree

第 $k$ 维上的单次查询复杂度最坏为 $\mathcal O(n^{1-k^{-1}})$。数组版（容量 `N = 1e5 + 10`，`K` 维），`insert` 平衡因子 $\alpha=0.725$ 触发拍平重建；`build` 按**方差最大的维**划分、`nth_element` 取中位数。下方 `query(a)` 统计**所有维都 ≤ a[i]** 的点数（`out` 剪枝整块在查询域之外，`all` 整块皆计入，`in` 单点判定）；常见扩展：最近点查询改成带界最值剪枝。

```cpp
struct KDT {
    constexpr static int N = 1e5 + 10, K = 2;
    double alpha = 0.725;
    struct node {
        int info[K];
        int mn[K], mx[K];
    } tr[N];
    int ls[N], rs[N], siz[N], id[N], d[N];
    int idx, rt, cur;
    int ans;
    KDT() {
        rt = 0;
        cur = 0;
        memset(ls, 0, sizeof ls);
        memset(rs, 0, sizeof rs);
        memset(d, 0, sizeof d);
    }
    void apply(int p, int son) {
        if (son) {
            for (int i = 0; i < K; i++) {
                tr[p].mn[i] = min(tr[p].mn[i], tr[son].mn[i]);
                tr[p].mx[i] = max(tr[p].mx[i], tr[son].mx[i]);
            }
            siz[p] += siz[son];
        }
    }
    void maintain(int p) {
        for (int i = 0; i < K; i++) {
            tr[p].mn[i] = tr[p].info[i];
            tr[p].mx[i] = tr[p].info[i];
        }
        siz[p] = 1;
        apply(p, ls[p]);
        apply(p, rs[p]);
    }
    int build(int l, int r) {
        if (l > r) return 0;
        vector<double> avg(K);
        for (int i = 0; i < K; i++) {
            for (int j = l; j <= r; j++) {
                avg[i] += tr[id[j]].info[i];
            }
            avg[i] /= (r - l + 1);
        }
        vector<double> var(K);
        for (int i = 0; i < K; i++) {
            for (int j = l; j <= r; j++) {
                var[i] += (tr[id[j]].info[i] - avg[i]) * (tr[id[j]].info[i] - avg[i]);
            }
        }
        int mid = (l + r) / 2;
        int x = max_element(var.begin(), var.end()) - var.begin();
        nth_element(id + l, id + mid, id + r + 1, [&](int a, int b) {
            return tr[a].info[x] < tr[b].info[x];
        });
        d[id[mid]] = x;
        ls[id[mid]] = build(l, mid - 1);
        rs[id[mid]] = build(mid + 1, r);
        maintain(id[mid]);
        return id[mid];
    }
    void print(int p) {
        if (!p) return;
        print(ls[p]);
        id[++idx] = p;
        print(rs[p]);
    }
    void rebuild(int &p) {
        idx = 0;
        print(p);
        p = build(1, idx);
    }
    bool bad(int p) {
        return alpha * siz[p] <= max(siz[ls[p]], siz[rs[p]]);
    }
    void insert(int &p, int cur) {
        if (!p) {
            p = cur;
            maintain(p);
            return;
        }
        if (tr[p].info[d[p]] > tr[cur].info[d[p]]) insert(ls[p], cur);
        else insert(rs[p], cur);
        maintain(p);
        if (bad(p)) rebuild(p);
    }
    void insert(vector<int> &a) {
        cur++;
        for (int i = 0; i < K; i++) {
            tr[cur].info[i] = a[i];
        }
        insert(rt, cur);
    }
    bool out(int p, vector<int> &a) {
        for (int i = 0; i < K; i++) {
            if (a[i] < tr[p].mn[i]) {
                return true;
            }
        }
        return false;
    }
    bool in(int p, vector<int> &a) {
        for (int i = 0; i < K; i++) {
            if (a[i] < tr[p].info[i]) {
                return false;
            }
        }
        return true;
    }
    bool all(int p, vector<int> &a) {
        for (int i = 0; i < K; i++) {
            if (a[i] < tr[p].mx[i]) {
                return false;
            }
        }
        return true;
    }
    void query(int p, vector<int> &a) {
        if (!p) return;
        if (out(p, a)) return;
        if (all(p, a)) {
            ans += siz[p];
            return;
        }
        if (in(p, a)) ans++;
        query(ls[p], a);
        query(rs[p], a);
    }
    int query(vector<int> &a) {
        ans = 0;
        query(rt, a);
        return ans;
    }
};
```
