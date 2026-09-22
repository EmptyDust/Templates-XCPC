#import "../prelude.typ": *

= 树上问题
<树上问题>
树上结构的主场：直径、中心、重心、LCA 三解、虚树、DSU on tree、Prüfer、树链剖分。选型信号：路径两端点共性信息 → LCA；每次询问只涉及少数关键点 → 虚树；多组询问的子树统计离线做 → DSU on tree；链上修改/查询 → 剖分拆区间再接荷载。

== 树的直径
<树的直径>
#specline([#O($N$)（两次 DFS）])
从任意点出发找最远点 `st`，再从 `st` 出发找最远点 `ed`，二者距离即直径。`getlen(root)` 返回以 `root` 为起点的连通块直径，`map` 存深度系森林时避免多次初始化。

#pitfall[两次 DFS 法要求边权非负；有负权边需换树形 DP。]

#include-code("code/树上问题/树的直径.cpp")

== 树的中心
<树的中心>
#specline([两遍 DFS #O($N$)])
到最远点距离最小的点。`d1` / `d2` 向下最长、次长，`up` 向上最长。`work` 之后取 `center`、`radius = max(d1, up)`；`diam` 为所有点 `d1+d2` 的最大（边权和）。重心见下一节点分治。

#include-code("code/树上问题/树的中心.cpp")

== 点分治 / 树的重心
<点分治-树的重心>
重心的定义：删除树上的某一个点，会得到若干棵子树；删除某点后，得到的最大子树最小，这个点称为重心。我们假设某个点是重心，记录此时最大子树的最小值，遍历完所有点后取最小值对应的点即可。

#quote(block: true)[
重心的性质：重心最多可能会有两个，且此时两个重心相邻。
]

点分治的一般过程是：取重心为新树的根，随后使用 `dfs` 处理当前这棵树，灵活运用 `child` 和 `pre` 两个数组分别计算通过根节点、不通过根节点的路径信息，根据需要进行答案的更新；再对子树分治，寻找子树的重心，……。每层分治规模至少减半，故总时间复杂度 $cal(O)(N "log" N)$ 。

```cpp
int root = 0, MaxTree = 1e18;  //分别代表重心下标、最大子树大小
vector<int> vis(n + 1), siz(n + 1);
auto get = [&](auto self, int x, int fa, int n) -> void {  // 获取树的重心
    siz[x] = 1;
    int val = 0;
    for (auto [y, w] : ver[x]) {
        if (y == fa || vis[y]) continue;
        self(self, y, x, n);
        siz[x] += siz[y];
        val = max(val, siz[y]);
    }
    val = max(val, n - siz[x]);
    if (val < MaxTree) {
        MaxTree = val;
        root = x;
    }
};

auto clac = [&](int x) -> void {  // 以 x 为新的根，维护询问
    set<int> pre = {0};  // 记录到根节点 x 距离为 i 的路径是否存在
    vector<int> dis(n + 1);
    for (auto [y, w] : ver[x]) {
        if (vis[y]) continue;
        vector<int> child;  // 记录 x 的子树节点的深度信息
        auto dfs = [&](auto self, int x, int fa) -> void {
            child.push_back(dis[x]);
            for (auto [y, w] : ver[x]) {
                if (y == fa || vis[y]) continue;
                dis[y] = dis[x] + w;
                self(self, y, x);
            }
        };
        dis[y] = w;
        dfs(dfs, y, x);

        for (auto it : child) {
            for (int i = 1; i <= m; i++) {  // 根据询问更新值
                if (q[i] < it || !pre.count(q[i] - it)) continue;
                ans[i] = 1;
            }
        }
        pre.insert(child.begin(), child.end());
    }
};

auto dfz = [&](auto self, int x, int fa) -> void {  // 点分治
    vis[x] = 1;  // 标记已经被更新过的旧重心，确保只对子树分治
    clac(x);
    for (auto [y, w] : ver[x]) {
        if (y == fa || vis[y]) continue;
        MaxTree = 1e18;
        get(get, y, x, siz[y]);
        self(self, root, x);
    }
};

get(get, 1, 0, n);
dfz(dfz, root, 0);
```

== 最近公共祖先 LCA
<最近公共祖先-lca>
树上两点路径的最高点。任意路径 $u arrow.r v$ 拆成 $u arrow.r "lca"$ 与 $v arrow.r "lca"$。剖分 $cal(O)("log" N)$、倍增 $cal(O)("log" N)$、欧拉序+ST $cal(O)(1)$。先 `work(root)` 再查。

=== 树链剖分解法
<树链剖分解法>
#specline([预处理 #O($N$)], [单次 #O($"log" N$)（常数小）])
沿重链跳 `top`，深度大的那条先跳，直到两点顶在同一条链上再比深度。`lca` / `dist` / `path` 同一份 `HLD`。`work(root)` 用迭代遍历预处理，临时空间为 $cal(O)(N)$，长链不依赖递归栈；可换根重复调用。

#include-code("code/树上问题/HLD.cpp")

=== 树上倍增解法
<树上倍增解法>
#specline([预处理 #O($N "log" N$)], [单次 #O($"log" N$)（常数比树链剖分大）])

#strong[封装一：基础封装，针对无权图。]

```cpp
struct Tree {
    int n;
    vector<vector<int>> ver, val;
    vector<int> lg, dep;
    Tree(int n) {
        this->n = n;
        ver.resize(n + 1);
        val.resize(n + 1, vector<int>(30));
        lg.resize(n + 1);
        dep.resize(n + 1);
        for (int i = 1; i <= n; i++) {  //预处理 log
            lg[i] = lg[i - 1] + (1 << lg[i - 1] == i);
        }
    }
    void add(int x, int y) { // 建立双向边
        ver[x].push_back(y);
        ver[y].push_back(x);
    }
    void dfs(int x, int fa) {
        val[x][0] = fa;  // 储存 x 的父节点
        dep[x] = dep[fa] + 1;
        for (int i = 1; i <= lg[dep[x]]; i++) {
            val[x][i] = val[val[x][i - 1]][i - 1];
        }
        for (auto y : ver[x]) {
            if (y == fa) continue;
            dfs(y, x);
        }
    }
    int lca(int x, int y) {
        if (dep[x] < dep[y]) swap(x, y);
        while (dep[x] > dep[y]) {
            x = val[x][lg[dep[x] - dep[y]] - 1];
        }
        if (x == y) return x;
        for (int k = lg[dep[x]] - 1; k >= 0; k--) {
            if (val[x][k] == val[y][k]) continue;
            x = val[x][k];
            y = val[y][k];
        }
        return val[x][0];
    }
    int clac(int x, int y) { // 倍增查询两点间距离
        return dep[x] + dep[y] - 2 * dep[lca(x, y)];
    }
    void work(int root = 1) {  // 在此初始化
        dfs(root, 0);
    }
};
```

#strong[封装二：扩展封装，针对有权图，支持“倍增查询两点路径上的最大边权”功能];。

```cpp
struct Tree {
    int n;
    vector<vector<int>> val, Max;
    vector<vector<pair<int, int>>> ver;
    vector<int> lg, dep;
    Tree(int n) {
        this->n = n;
        ver.resize(n + 1);
        val.resize(n + 1, vector<int>(30));
        Max.resize(n + 1, vector<int>(30));
        lg.resize(n + 1);
        dep.resize(n + 1);
        for (int i = 1; i <= n; i++) {  //预处理 log
            lg[i] = lg[i - 1] + (1 << lg[i - 1] == i);
        }
    }
    void add(int x, int y, int w) {  // 建立双向边
        ver[x].push_back({y, w});
        ver[y].push_back({x, w});
    }
    void dfs(int x, int fa) {
        val[x][0] = fa;
        dep[x] = dep[fa] + 1;
        for (int i = 1; i <= lg[dep[x]]; i++) {
            val[x][i] = val[val[x][i - 1]][i - 1];
            Max[x][i] = max(Max[x][i - 1], Max[val[x][i - 1]][i - 1]);
        }
        for (auto [y, w] : ver[x]) {
            if (y == fa) continue;
            Max[y][0] = w;
            dfs(y, x);
        }
    }
    int lca(int x, int y) {
        if (dep[x] < dep[y]) swap(x, y);
        while (dep[x] > dep[y]) {
            x = val[x][lg[dep[x] - dep[y]] - 1];
        }
        if (x == y) return x;
        for (int k = lg[dep[x]] - 1; k >= 0; k--) {
            if (val[x][k] == val[y][k]) continue;
            x = val[x][k];
            y = val[y][k];
        }
        return val[x][0];
    }
    int clac(int x, int y) {  // 倍增查询两点间距离
        return dep[x] + dep[y] - 2 * dep[lca(x, y)];
    }
    int query(int x, int y) { // 倍增查询两点路径上的最大边权（带权图）
        auto get = [&](int x, int y) -> int {
            int ans = 0;
            if (x == y) return ans;
            for (int i = lg[dep[x]]; i >= 0; i--) {
                if (dep[val[x][i]] > dep[y]) {
                    ans = max(ans, Max[x][i]);
                    x = val[x][i];
                }
            }
            ans = max(ans, Max[x][0]);
            return ans;
        };
        int fa = lca(x, y);
        return max(get(x, fa), get(y, fa));
    }
    void work(int root = 1) { // 在此初始化
        dfs(root, 0);
    }
};
```

=== st表预处理解法
<st表预处理解法>
#specline([预处理 #O($N "log" N$)], [查询 #O($1$)（不维护其他信息时最快，且静态）])
欧拉序 + ST 表。`id` 为欧拉序，`l[u]/r[u]` 为子树区间（可顺带做子树操作）。

#include-code("code/树上问题/st表预处理解法.cpp")

== 虚树
<虚树>
#specline([单次构造 #O($k "log" k$)（$k$ 为关键点数）])
每次询问只涉及 $k$ 个关键点时，把关键点和它们两两的 LCA（至多新增 $k$ 个点）缩成一棵 $cal(O)(k)$ 的虚树再 dp，$sum k$ 与 $N$ 同阶时总量线性。构造：关键点按 dfn 排序，单调栈维护根到栈顶的链，新点与栈顶 LCA 的深度低于栈内链时弹栈连边。依赖上面的 `HLD`：原树 `hld.add` / `hld.work` 之后，`build(关键点, hld)` 返回虚树上出现过的全部点（根固定 1 号，不在关键点里会自动补入），无向边留在 `h`，dp 完按返回列表清空 `h` 复用。

#include-code("code/树上问题/虚树.cpp")

== 树上路径交
<树上路径交>
四个跨路径端点对求 LCA，按深度排序后判断。返回交点个数，可退化成一个点。传入深度数组和 LCA 回调，例如 `intersection(u,v,x,y,hld.dep,[&](int a,int b){ return hld.lca(a,b); })`；不依赖某个特定树类。

#include-code("code/树上问题/树上路径交.cpp")

== 树上启发式合并 \(DSU on tree)
<树上启发式合并-dsu-on-tree>
#specline([#O($N "log" N$)])
思路：先轻儿子、再重儿子（重儿子贡献保留，`hson` 标记跳过），`calc` 暴力统计轻儿子子树；`add(c)/del(c)` 为待填钩子，`res` 为当前答案。`add()` 与顶部加边的 `add(u, v)` 靠参数个数区分。

```cpp
struct DsuOnTree {
    std::vector<std::vector<int>> e;
    std::vector<int> siz, son;
    std::vector<i64> ans;
    int hson;
    i64 res;
    DsuOnTree(int n) {
        e.resize(n + 1);
        siz.resize(n + 1);
        son.resize(n + 1);
        ans.resize(n + 1);
        hson = 0;
        res = 0;
    }
    void add(int u, int v) {
        e[u].push_back(v);
        e[v].push_back(u);
    }
    void dfs1(int u, int fa) {
        siz[u] = 1;
        for (auto v : e[u]) {
            if (v == fa) continue;
            dfs1(v, u);
            siz[u] += siz[v];
            if (siz[v] > siz[son[u]]) son[u] = v;
        }
    }
    void add(int c) {
    }
    void del(int c) {
    }
    void calc(int u, int fa, int f) {
        if (f == 1) add(u);  // 对节点 u 的颜色操作（DSU on tree 钩子）
        else del(u);
        for (auto v : e[u]) {
            if (v == fa || v == hson) continue;
            calc(v, u, f);
        }
    }
    void dfs2(int u, int fa, int opt) {
        for (auto v : e[u]) {
            if (v == fa || v == son[u]) continue;
            dfs2(v, u, 0);
        }
        if (son[u]) {
            dfs2(son[u], u, 1);
            hson = son[u];
        }
        calc(u, fa, 1);
        hson = 0;
        ans[u] = res;
        if (!opt)   calc(u, fa, -1);
    }
    void work() {
        dfs1(1, 0);
        dfs2(1, 0, 0);
    }
};
```

== Prüfer 序列
<prüfer-序列>
$n$ 点带标号树 $arrow.l.r$ 长 $n - 2$、值域为点编号的序列，一一对应。度数 $d$ 的点在序列里出现 $d - 1$ 次。用来计数生成树，不常用来存树。

=== 对树建立 Prüfer 序列
<对树建立-prüfer-序列>
每次取编号最小的叶删掉，记下它连向的那个点。做 $n - 2$ 次后剩两点。用堆/set 取最小叶是 $cal(O)(n "log" n)$。结点从 $0$ 标号。

显然使用堆可以做到 $O (n "log" n)$ 的复杂度

#include-code("code/树上问题/对树建立-Prüfer-序列.cpp")

```python
# 结点从 0 标号；与上面 C++ 版等价（每次取编号最小的叶）
def pruefer_code(adj):
    n = len(adj)
    leafs = set()
    degree = [0] * n
    killed = [False] * n
    for i in range(n):
        degree[i] = len(adj[i])
        if degree[i] == 1:
            leafs.add(i)
    code = [0] * (n - 2)
    for i in range(n - 2):
        leaf = min(leafs)
        leafs.remove(leaf)
        killed[leaf] = True
        v = next(u for u in adj[leaf] if not killed[u])
        code[i] = v
        degree[v] -= 1
        if degree[v] == 1:
            leafs.add(v)
    return code
```

=== Cayley 公式 \(Cayley’s formula)
<cayley-公式-cayleys-formula>
完全图 $K_n$ 有 $n^(n - 2)$ 棵生成树。

怎么证明？方法很多，但是用 Prüfer 序列证是很简单的。任意一个长度为 $n - 2$ 的值域 $[1 , n]$ 的整数序列都可以通过 Prüfer 序列双射对应一个生成树，于是方案数就是 $n^(n - 2)$。

==== 图连通方案数
<图连通方案数>
Prüfer 序列可能比你想得还强大。它能创造比 #link(<cayley-公式-cayleys-formula>)[凯莱公式] 更通用的公式。比如以下问题：

#quote(block: true)[
一个 $n$ 个点 $m$ 条边的带标号无向图有 $k$ 个连通块。我们希望添加 $k - 1$ 条边使得整个图连通。求方案数。
]

设 $s_i$ 表示每个连通块的数量。我们对 $k$ 个连通块构造 Prüfer 序列，然后你发现这并不是普通的 Prüfer 序列。因为每个连通块的连接方法很多。不能直接淦就设啊。于是设 $d_i$ 为第 $i$ 个连通块的度数。由于度数之和是边数的两倍，于是 $sum_(i = 1)^k d_i = 2 k - 2$。则对于给定的 $d$ 序列构造 Prüfer 序列的方案数是

$ n^(k - 2) dot product_(i = 1)^k s_i $

== 轻重链剖分/树链剖分
<轻重链剖分树链剖分>
#specline([建树 #O($N$)], [路径拆段 #O($"log" N$)], [接区间荷载单次 #O($"log"^2 N$)])
`HLD` 板子就是上面 LCA 那一份，不重印：`hld.add` / `hld.work` 之后，`path(u, v)` / `subtree(u)` 把 dfn 闭区间交给外面。荷载接在外面，下面是区间加、区间和，用 `path` / `subtree` 接 `modify` / `ask`。

#pitfall[`path` 吐出的区间是#strong[跳链顺序];，不是从 $u$ 到 $v$ 的路径顺序：加法、最值这类可交换荷载直接用；路径哈希、按序染色这类不可交换的，要先把一侧的区间收下来反转再合并。]

```cpp
struct Segt {
    struct node {
        int l, r;
        i64 w, lazy;
    };
    vector<i64> w;
    vector<node> t;
    #define GL (k << 1)
    #define GR (k << 1 | 1)
    void init(const vector<i64> &in) {
        int n = in.size() - 1;
        w = in;
        t.resize(n * 4 + 1);
        auto build = [&](auto &&self, int l, int r, int k = 1) -> void {
            if (l == r) {
                t[k] = {l, r, w[l], 0};
                return;
            }
            t[k] = {l, r};
            int mid = (l + r) / 2;
            self(self, l, mid, GL);
            self(self, mid + 1, r, GR);
            pushup(k);
        };
        build(build, 1, n);
    }
    void pushdown(node &p, i64 lazy) {
        p.w += (p.r - p.l + 1) * lazy;
        p.lazy += lazy;
    }
    void pushdown(int k) {
        if (t[k].lazy == 0) return;
        pushdown(t[GL], t[k].lazy);
        pushdown(t[GR], t[k].lazy);
        t[k].lazy = 0;
    }
    void pushup(int k) {
        t[k].w = t[GL].w + t[GR].w;
    }
    void modify(int l, int r, i64 val, int k = 1) {
        if (l <= t[k].l && t[k].r <= r) {
            pushdown(t[k], val);
            return;
        }
        pushdown(k);
        int mid = (t[k].l + t[k].r) / 2;
        if (l <= mid) modify(l, r, val, GL);
        if (mid < r) modify(l, r, val, GR);
        pushup(k);
    }
    i64 ask(int l, int r, int k = 1) {
        if (l <= t[k].l && t[k].r <= r) {
            return t[k].w;
        }
        pushdown(k);
        int mid = (t[k].l + t[k].r) / 2;
        i64 ans = 0;
        if (l <= mid) ans += ask(l, r, GL);
        if (mid < r) ans += ask(l, r, GR);
        return ans;
    }
};
#undef GL
#undef GR
```

完整用法：输入 `n q root`、点权、$n-1$ 条无向边。操作 1 为路径加，2 为路径和，3 为子树加，4 为子树和。点权必须按 `hld.in` 重排后初始化线段树；各次区间和及懒标记累加须在 `i64` 内。

```cpp
int main() {
    int n, q, root;
    cin >> n >> q >> root;
    vector<i64> weight(n + 1), ordered(n + 1);
    for (int i = 1; i <= n; ++i) cin >> weight[i];
    HLD hld(n);
    for (int i = 1; i < n; ++i) {
        int u, v;
        cin >> u >> v;
        hld.add(u, v);
    }
    hld.work(root);
    for (int i = 1; i <= n; ++i) ordered[hld.in[i]] = weight[i];
    Segt segt;
    segt.init(ordered);
    while (q--) {
        int op, u, v;
        i64 value;
        cin >> op >> u;
        if (op == 1) {
            cin >> v >> value;
            hld.path(u, v, [&](int l, int r) { segt.modify(l, r, value); });
        } else if (op == 2) {
            cin >> v;
            i64 answer = 0;
            hld.path(u, v, [&](int l, int r) { answer += segt.ask(l, r); });
            cout << answer << '\n';
        } else if (op == 3) {
            cin >> value;
            hld.subtree(u, [&](int l, int r) { segt.modify(l, r, value); });
        } else {
            hld.subtree(u, [&](int l, int r) { cout << segt.ask(l, r) << '\n'; });
        }
    }
}
```

