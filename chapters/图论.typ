#import "../prelude.typ": *

= 图论
<图论>
点与边的主战场：最短路、生成树、连通性（Tarjan 家族）、匹配、欧拉路、2-SAT 与杂项结论。选型信号：距离类 → 最短路家族（正权 Dijkstra、负权 BF/SPFA）；"互相可达"分组 → 缩点；删边分组的最小代价 → 割/对偶图；布尔变量带约束地取值 → 2-SAT。

== 常见概念
<常见概念>
#quote(block: true)[
oriented graph：有向图

bidirectional edges：双向边
]

平面图：若能将无向图 $G = (V , E)$ 画在平面上使得任意两条无重合顶点的边不相交，则称 $G$ 是平面图。

无向正权图上某一点的偏心距：记为 $e c c (u) = "max" #scale(x: 120%, y: 120%)[{] d i s t (u , v) #scale(x: 120%, y: 120%)[}]$ ，即以这个点为源，到其他点的#strong[所有最短路的最大值];。如下图 $A$ 点，$e c c (A)$ 即为 $12$ 。

图的直径：定义为 $d = "max" #scale(x: 120%, y: 120%)[{] e c c (u) #scale(x: 120%, y: 120%)[}]$ ，即#strong[最大的偏心距];，亦可以简化为图中最远的一对点的距离。

图的中心：定义为 $a r g = "min" #scale(x: 120%, y: 120%)[{] e c c (u) #scale(x: 120%, y: 120%)[}]$ ，即#strong[偏心距最小的点];。如下图，图的中心即为 $B$ 点。

图的绝对中心：可以定义在边上的图的中心。

图的半径：图的半径不同于圆的半径，其不等于直径的一半（但对于绝对中心定义上的直径而言是一半）。定义为 $r = "min" #scale(x: 120%, y: 120%)[{] e c c (u) #scale(x: 120%, y: 120%)[}]$ ，即#strong[中心的偏心距];。计算方式：使用全源最短路，计算出所有点的偏心距，再加以计算。

#image("/images/img-07.png")

== 平面图性质
<平面图性质>
#strong[一、定义] $G = (V , E)$ 是一个无向图。

+ #strong[图 G 可嵌入平面：] 如果可以把图 G 的所有结点和边都画在平面上，同时除断点外连线之间没有交点，就称图 G 可嵌入平面。画出的无边相交的 G’称 G 的平面嵌入。
+ #strong[可平面化：] 如果图 G 可以嵌入平面，就称图 G 可平面化。
+ #strong[面：] G 中边所包含的区域称作一个面。有界区域称为内部面，无界区域称为外部面，常记作$R_0$，包围面的长度最短的闭链称为该面的边界，面$R$的边界的长度称为该面的度数，记作 $upright("deg") (R)$。
+ #strong[面的度数计算：] 含有割边和桥的度数为 2，其余为 1。

#strong[二、性质]

+ 性质 1. $K_1 , K_2 , K_3 , K_4 , K_5 - e$ 均为极大可平面图.
+ 性质 2. 极大平面图必是连通图.
+ 性质 3. 当图阶数 $n gt.eq 3$ 时, 有割点或者桥的平面图不是极大平面图.

#strong[三、定理]

+ #strong[定理 1：] 图$G$可嵌入球面当且仅当图$G$可嵌入平面。
+ #strong[定理 2：] $G$中各面的度数之和等于图$G$边数的两倍。 #strong[证明：] 设$e$为图$G$的两个面的公共边，再计算两个面的度数时候边数各提供 1，当$e$不是公共边时候，也就是$e$为桥或者割边时候提供度数为 2。因此，面的度数之和为边的两倍。
+ #strong[定理 3：] 设$R$是图$G$的某个平面嵌入的一个内部面，则存在图$G$的一个平面嵌入使$R$为外部面。
+ #strong[定理 4：] 设图$G$是简单的可平面图，如果$G$中任意两个不相邻的结点加边后所得到的为非可平面图。则称$G$是极大可平面图，极大可平面图的任何平面嵌入都称为极大平面图。极大平面图必是连通图。
+ #strong[定理 5：] 图$G$为$n$阶简单的连通的平面图，$G$为极大平面图当且仅当$G$的每一个面的度数为 3。 #emph[定理说明：] 结点数大于等于 3 的极大平面图的任何面都是由三角形组成。
+ #strong[定理 6：欧拉公式：] 设图$G$是有$n$个结点、$m$条边和$r$个面的连通平面图，则它们满足： $ n - m + r = 2 $

#strong[四、结论]

+ #strong[结论 1：] $K_1 , K_2 , K_3 , K_4 , K_5 - e$ \($K_5$任意删去一条边)均为极大可平面图，它们的任何平面嵌入都是极大平面图；当阶数等于 3 时候，有割边或桥的平面图不可能是极大平面图。
+ #strong[结论 2：] 无向完全图$K_5$和无向完全二部图$K_(3 , 3)$都是极小非可平面图（去掉一条边就成为可平面图）。
+ #strong[结论 3：] 一个图是可平面图，那么它的子图也是可平面图；一个图的子图是非可平面图，那么图本身也是非可平面图。
+ #strong[结论 4：] 同一个图的平面嵌入中，外部面和内部面的度数可以不同。

#strong[五、推论]

+ #strong[推论 1：] 设图$G$是有$n$个结点、$m$条边的连通平面简单图，其中$n gt.eq 3$，则有： $ m lt.eq 3 n - 6 $ #strong[证明：] 由图$G$的面度数之和为边数的二倍，即$2 m$。又因为$G$是平面简单图每一个面的度数至少为 3，则$2 m gt.eq 3 r$，由欧拉公式有：$m lt.eq 3 n - 6$
+ #strong[推论 2：] 设图$G$是有$n$个结点、$m$条边的连通平面简单图，其中$n gt.eq 3$且没有长度为 3 的圈，则有： $ m lt.eq 2 n - 4 $ #strong[证明：] $G$没有长度为 3 的圈也就没有度为 3 的面，$G$的每一个面的度数至少为 4。所以$2 m gt.eq 4 r$，由欧拉公式有：$m lt.eq 2 n - 4$ #emph[提示：] 对于推论 1 和推论 2 我们可以用定理进行判定它不是平面图。 #strong[例 1：] 证明$K_5$和$K_(3 , 3)$是非平面图。 #strong[证明：]
  - 在$K_5$中，$m$应该小于等于$3 n - 6$，即$m lt.eq 9$。而完全图$K_5$具有 10 条边。所以是非平面图。
  - 在$K_(3 , 3)$中，没有长度大于 3 的圈，根据推论 2 可知，$m lt.eq 2 n - 4$，也就是$m lt.eq 8$，而$K_(3 , 3)$含有 9 条边，所以是非平面图。
+ #strong[推论 3：] 设 $G$ 是连通的平面图, 且每个面的度数至少为 $l (l gt.eq 3)$, 则 $ m lt.eq frac(l, l - 2) (n - 2) . $ #strong[证明：] 同理，有$2 m gt.eq r times l$，根据欧拉公式化简得： $ 2 m gt.eq l (m - n + 2) $
+ #strong[推论 4：] 设 $G$ 是平面图, 有 $omega$ 个连通分支, $n$ 个结点, $m$ 条边, $r$ 个面, 则公式$ n - m + r = omega + 1 $成立。
+ #strong[推论 5：] 设 $G$ 是有 $n$ 个结点、$m$ 条边和 $r$ 个面、$omega$ 个连通分支的平面图, 且 $G$ 的各个面的度数至少为 $l$, \($l gt.eq 4$), 则$ m lt.eq frac((n - omega - 1) l, l - 2) . $ #strong[证明：] 证明过程与推论 3 类似，用到推论 4 的结论。
+ #strong[推论 6：] 设 $G$ 是任意平面简单图, 则 $ delta (G) lt.eq 5 . $ #strong[证明：] 设 $G$ 有 $n$ 个顶点 $m$ 条边. 若 $m lt.eq 6$, 结论显然成立; 若 $m > 6$, 假设 $G$ 的每个顶点的度数 $> 6$, 则由推论 1, 有$ 6 n lt.eq sum d (v) = 2 m lt.eq 2 (3 n - 6) = 6 n - 12 $与定理矛盾, 故 $delta (G) lt.eq 5$.

#strong[六、判别定理]

+ #strong[极大平面图的判别定理：] $n (n gt.eq 3)$ 阶连通的简单平面图 $G$. 则以下四个条件等价:
  + $G$ 是极大平面图;
  + $G$ 中每个面的度数都是 3;
  + $G$ 中有 $m$ 条边 $r$ 个面, 则 $ 3 r = 2 m ; $
  + 设 $G$ 带有 $n$ 个顶点, $m$ 条边, $r$ 个面则 $ m = 3 n - 6 ; $

== 单源最短路径 \(SSSP 问题)
<单源最短路径-sssp-问题>
固定源点到其余点的最短路。边权非负用 Dijkstra；有负权无负环用 Bellman-Ford / SPFA；路上有负环则该点无最短路。全源用 Floyd。

=== （正权稀疏图）动态数组存图+Dijkstra 算法
<正权稀疏图动态数组存图dijkstra-算法>
#specline([堆优化 #O($M "log" N$)])
每次弹出当前距离最小的未确定点，用它松弛邻边；正权保证弹出即为最终答案。`d` 初值 INF。

=== （负权图）Bellman ford 算法
<负权图bellman-ford-算法>
#specline([#O($N M$)])
使用结构体存边（该算法无需存图）。当所求点的路径上存在负环时，所求点的答案无法得到，但是会比 INF 小（因为负环之后到所求点之间的边权会将 `d[end]` 的值更新），该性质可以用于判断路径上是否存在负环：在 $N - 1$ 轮后仍无法得到答案（一般与 `INF / 2` 进行比较）的点，到达其的路径上存在负环。

下方代码例题：求解从 $1$ 到 $n$ 号节点的、最多经过 $k$ 条边的最短距离。

#include-code("code/图论/负权图Bellman-ford-算法.cpp")

=== （负权图）SPFA 算法
<负权图spfa-算法>
#specline([平时 #O($K M$)], [最坏 #O($N M$)])

#pitfall[可被特殊构造卡掉；无负权时优先用堆优化 Dijkstra。]

#include-code("code/图论/负权图SPFA-算法.cpp")

== 多源汇最短路 \(Floyd)
<多源汇最短路-floyd>
#specline([#O($N^3$)])
枚举中转点 $k$，用 $i arrow.r k arrow.r j$ 松弛。可负权，有负环则对角线会被更新成负。邻接矩阵、下标 $1 dots.c n$，无边先赋无穷。这里加的是单向边，双向要加两次。

#pitfall[$k$ 必须在最外层循环——放里面会漏松弛。]

```cpp
void floyd() {
    for (int k = 1; k <= n; k ++)
        for (int i = 1; i <= n; i ++)
            for (int j = 1; j <= n; j ++)
                d[i][j] = min(d[i][j], d[i][k] + d[k][j]);
}
```

== 平面图最短路 \(对偶图)
<平面图最短路-对偶图>
平面图最小割可以转化为对偶图上的最短路：把原图的每个面当作对偶图的点，跨越某条边的两个面之间连一条权值为该边容量的边，原图 $s arrow.r t$ 的最小割即对偶图的最短路（典型题：狼抓兔子）。下方代码把格点通过 `Hash` 映射成对偶图节点编号。

对于矩阵图，建立对偶图的过程如下（注释部分为建立原图），其中数据的给出顺序依次为：各 $n (n + 1)$ 个数字分别代表从左向右、从上向下、从右向左、从下向上的边。

#include-code("code/图论/平面图最短路-对偶图.cpp")

== 最小生成树 \(MST 问题)
<最小生成树-mst-问题>
连通无向图上边权和最小的生成树。割性质：跨越当前割的最小边一定在某棵 MST 里。Kruskal 按边权排序再并查集合并；Prim 不断吸收离树最近的点。

=== （稠密图）Prim 算法
<稠密图prim-算法>
#specline([邻接矩阵 #O($N^2 + M$)])
思想同 Dijkstra：`d` 维护每个点到「已在树内点集」的最短边。不连通返回 INF。

#include-code("code/图论/稠密图Prim-算法.cpp")

=== （稀疏图）Kruskal 算法
<稀疏图kruskal-算法>
#specline([#O($M "log" M$)（瓶颈在排序）])
边按权排序后依次加入，并查集判是否成环，加入 $n - 1$ 条即成树。不连通则边数不够。

#include-code("code/图论/稀疏图Kruskal-算法.cpp")

== 缩点 \(Tarjan 算法)
<缩点-tarjan-算法>
把「互相可达」的点缩成一个点。有向图得 DAG（SCC），无向图得桥/边双。`dfn/low`：`low` 能回到自己或祖先则还在同一个分量里。

=== （有向图）强连通分量缩点
<有向图强连通分量缩点>
强连通分量缩点后的图称为 SCC。$cal(O)(N + M)$。

#quote(block: true)[
性质：缩点后的图拥有拓扑序 $"color"_("cnt") , "color"_("cnt" - 1) , dots.h , 1$ ，可以不需再另跑一遍 `topsort`；缩点后的图是一张有向无环图（DAG、拓扑图）。
]

```cpp
struct SCC {
    int n, now, cnt;
    vector<vector<int>> ver;
    vector<int> dfn, low, col, S;

    SCC(int n) : n(n), ver(n + 1), low(n + 1) {
        dfn.resize(n + 1, -1);
        col.resize(n + 1, -1);
        now = cnt = 0;
    }
    void add(int x, int y) {
        ver[x].push_back(y);
    }
    void tarjan(int x) {
        dfn[x] = low[x] = now++;
        S.push_back(x);
        for (auto y : ver[x]) {
            if (dfn[y] == -1) {
                tarjan(y);
                low[x] = min(low[x], low[y]);
            } else if (col[y] == -1) {
                low[x] = min(low[x], dfn[y]);
            }
        }
        if (dfn[x] == low[x]) {
            int pre;
            cnt++;
            do {
                pre = S.back();
                col[pre] = cnt;
                S.pop_back();
            } while (pre != x);
        }
    }
    auto work() {  // [cnt 新图的顶点数量]
        for (int i = 1; i <= n; i++) {  // 避免图不连通
            if (dfn[i] == -1) {
                tarjan(i);
            }
        }

        vector<int> siz(cnt + 1);  // siz 每个 scc 中点的数量
        vector<vector<int>> adj(cnt + 1);
        for (int i = 1; i <= n; i++) {
            siz[col[i]]++;
            for (auto j : ver[i]) {
                int x = col[i], y = col[j];
                if (x != y) {
                    adj[x].push_back(y);
                }
            }
        }
        return {cnt, adj, col, siz};
    }
};
```

=== （无向图）割边缩点
<无向图割边缩点>
割边缩点后的图称为边双连通图 \(E-DCC)，该模板可以在 $cal(O)(N + M)$ 复杂度内求解图中全部割边、划分边双（颜色相同的点位于同一个边双连通分量中）。

#quote(block: true)[
割边（桥）：将某边 $e$ 删去后，原图分成两个以上不相连的子图，称 $e$ 为图的割边。

边双连通：在一张连通的无向图中，对于两个点 $u$ 和 $v$，删去任何一条边（只能删去一条）它们依旧连通，则称 $u$ 和 $v$ 边双连通。一个图如果不存在割边，则它是一个边双连通图。

性质补充：对于一个边双，删去任意边后依旧联通；对于边双中的任意两点，一定存在两条不相交的路径连接这两个点（路径上可以有公共点，但是没有公共边）。
]

#include-code("code/图论/无向图割边缩点.cpp")

=== （无向图）割点缩点
<无向图割点缩点>
割点缩点后的图称为点双连通图 \(V-DCC)，该模板可以在 $cal(O)(N + M)$ 复杂度内求解图中全部割点、划分点双（颜色相同的点位于同一个点双连通分量中）。

#quote(block: true)[
割点（割顶）：将与某点 $i$ 连接的所有边删去后，原图分成两个以上不相连的子图，称 $i$ 为图的割点。

点双连通：在一张连通的无向图中，对于两个点 $u$ 和 $v$，删去任何一个点（只能删去一个，且不能删 $u$ 和 $v$自己）它们依旧连通，则称 $u$ 和 $v$ 边双连通。如果一个图不存在割点，那么它是一个点双连通图。

性质补充：每一个割点至少属于两个点双。
]

#include-code("code/图论/无向图割点缩点.cpp")

== 链式前向星建图与搜索
<链式前向星建图与搜索>
数组模拟邻接表（链式前向星）：比 `vector` 邻接表常数更小、代码稍长，需要大量加边或卡常时常用。`dfs`：标准复杂度为 $cal(O)(N + M)$。节点子节点的数量包含它自己（至少为 $1$），深度从 $0$ 开始（根节点深度为 $0$）。`bfs`：深度从 $1$ 开始（根节点深度为 $1$）。`topsort`：有向无环图（包括非联通）才拥有完整的拓扑序列（故该算法也可用于判断图中是否存在环）。每次找到入度为 $0$ 的点并将其放入待查找队列。

```cpp
namespace Graph {
    const int N = 1e5 + 7;
    const int M = 1e6 + 7;
    int tot, h[N], ver[M], ne[M];
    int deg[N], vis[M];

    void clear(int n) {
        tot = 0;  //多组样例清空
        for (int i = 1; i <= n; ++i) {
            h[i] = 0;
            deg[i] = vis[i] = 0;
        }
    }
    void add(int x, int y) {
        ver[++tot] = y, ne[tot] = h[x], h[x] = tot;
        ++deg[y];
    }
    void dfs(int x) {
        a.push_back(x);  // DFS序
        siz[x] = vis[x] = 1;
        for (int i = h[x]; i; i = ne[i]) {
            int y = ver[i];
            if (vis[y]) continue;
            dis[y] = dis[x] + 1;
            dfs(y);
            siz[x] += siz[y];
        }
        a.push_back(x);
    }
    void bfs(int s) {
        queue<int> q;
        q.push(s);
        dis[s] = 1;
        while (!q.empty()) {
            int x = q.front();
            q.pop();
            for (int i = h[x]; i; i = ne[i]) {
                int y = ver[i];
                if (dis[y]) continue;
                dis[y] = dis[x] + 1;
                q.push(y);
            }
        }
    }
    bool topsort() {
        queue<int> q;
        vector<int> ans;
        for (int i = 1; i <= n; ++i)
            if (deg[i] == 0) q.push(i);
        while (!q.empty()) {
            int x = q.front();
            q.pop();
            ans.push_back(x);
            for (int i = h[x]; i; i = ne[i]) {
                int y = ver[i];
                --deg[y];
                if (deg[y] == 0) q.push(y);
            }
        }
        return ans.size() == n;  //判断是否存在拓扑排序
    }
}  // namespace Graph
```

== 一般图最大匹配 \(带花树算法)
<一般图最大匹配-带花树算法>
#specline([#O($N^3$)（与点数相关、与边数无关）])
与二分图匹配的差别在于图中可能存在奇环：算法在找增广路时把奇环缩成“花”（blossom）统一处理。下方模板编号从 $0$ 开始，`work()` 返回 `{最大匹配数, match 数组}`，其中 `match[i]` 为 $i$ 的匹配点，$- 1$ 表示未匹配；例题为 #link("https://uoj.ac/problem/79")[UOJ \#79. 一般图最大匹配] 。

#include-code("code/图论/一般图最大匹配-带花树算法.cpp")

== 一般图最大权匹配 \(带权带花树算法)
<一般图最大权匹配-带权带花树算法>
#specline([#O($N^3$)])
下方模板编号从 $1$ 开始。调用 `work(n, edges)` 返回最大总权（`edges` 元素为 `{u, v, w}`，重边自动取权值最大者）；`match()` 返回其中一种方案的配对表（每点 $i$ 配 `lk[i]`，一个匹配边可能出现两次）。权值类型由 `typedef int T` 决定，需要时改为 `long long`。

#include-code("code/图论/一般图最大权匹配-带权带花树算法.cpp")

== 二分图最大匹配
<二分图最大匹配>
#quote(block: true)[
二分图：一个图能被分为左右两部分，任何一条边的两个端点都不在同一部分中。

匹配（独立边集）：一个边的集合，这些边没有公共顶点。

二分图最大匹配即找到边的数量最多的那个匹配。

一般我们规定，左半部包含 $n_1$ 个点（编号 $1 - n_1$），右半部包含 $n_2$ 个点（编号 $1 - n_2$ ），保证任意一条边的两个端点都不可能在同一部分中。
]

=== 匈牙利算法解
<匈牙利算法解>
#specline([最坏 #O($N M$)])
#quote(block: true)[
匈牙利算法用于无权二分图最大匹配；KM 算法用于带权二分图最大权匹配（见下文相应小节），两者常被混称，实为不同算法。
]

从每个左点找增广路：未匹配边前进、已匹配边后退，找到未匹配右点则整条路反转。失败则匹配数无法再加。`match[右点]=左点`。下标 $1 dots.c n_1$、$1 dots.c n_2$。

#include-code("code/图论/匈牙利算法解.cpp")

=== HopcroftKarp 算法（基于最大流）解
<hopcroftkarp-算法基于最大流解>
#specline([最坏 #O($sqrt(N) M$)], [实测 $N, M = 2 times 10^5$ 跑 60ms])
该算法基于最大流，常数极小，且引入随机化，几乎卡不掉（#link("https://judge.yosupo.jp/problem/bipartitematching")[测试];）。

#include-code("code/图论/HopcroftKarp-算法基于最大流解.cpp")

== 二分图最大权匹配 \(二分图完美匹配)
<二分图最大权匹配-二分图完美匹配>
#quote(block: true)[
定义：找到边权和最大的那个匹配。

一般我们规定，左半部包含 $n_1$ 个点（编号 $1 - n_1$），右半部包含 $n_2$ 个点（编号 $1 - n_2$ ）。
]

使用 KM（Kuhn–Munkres）算法解（与上一节的匈牙利算法常被混称），要求存在完美匹配。

#specline([#O($N^3$)])下方模板用于求解最大权值、且可以输出其中一种可行方案：`work()` 返回最大权，`getMatch(n1, n2)` 输出方案；例题为 #link("https://uoj.ac/problem/80")[UOJ \#80. 二分图最大权匹配] 。

#include-code("code/图论/二分图最大权匹配-二分图完美匹配.cpp")

== 二分图最大独立点集 \(König 定理)
<二分图最大独立点集-könig-定理>
选取尽量多的、两两之间没有边直接相连的点。由 König 定理：最小点覆盖（覆盖所有边的点集）大小 \= 最大匹配数，且最大独立点集大小 \= 总点数 − 最小点覆盖，故答案为 $n$ 减去最大流（即最大匹配）的值。

```cpp
cout << n - flow.work(s, t) << endl;
```

== 最长路 \(topsort+DP 算法)
<最长路-topsortdp-算法>
#specline([#O($N + M$)])
DAG 上按拓扑序松弛：入度 $0$ 入队，`dis[y]=\max(\mathrm{dis}[y],\mathrm{dis}[x]+w)`。有环先 Tarjan 缩点。`topsort(s,t)` 返回 $s$ 到 $t$，不可达为 $- 10^18$。

#include-code("code/图论/最长路-topsort+DP-算法.cpp")

== 最短路径树 \(SPT 问题)
<最短路径树-spt-问题>
#quote(block: true)[
定义：在一张无向带权联通图中，有这样一棵#strong[生成树];：满足从根节点到任意点的路径都为原图中根到任意点的最短路径。

性质：记根节点 $R o o t$ 到某一结点 $x$ 的最短距离 $d i s_(R o o t , x)$ ，在 $S P T$ 上这两点之间的距离为 $l e n_(R o o t , x)$ ——则两者长度相等。
]

该算法与最小生成树无关，基于最短路 `Djikstra` 算法完成（但多了个等于号）。下方代码实现的功能为：读入图后，输出以 $1$ 为根的 SPT 所使用的各条边的编号、边权和。

```cpp
map<pair<int, int>, int> id;
namespace G {
    vector<pair<int, int> > ver[N];
    map<pair<int, int>, int> edge;
    int v[N], d[N], pre[N], vis[N];
    int ans = 0;

    void add(int x, int y, int w) {
        ver[x].push_back({y, w});
        edge[{x, y}] = edge[{y, x}] = w;
    }
    void djikstra(int s) {  // ！注意，该 djikstra 并非原版，多加了一个等于号
        priority_queue<PII, vector<PII>, greater<PII> > q; q.push({0, s});
        memset(d, 0x3f, sizeof d); d[s] = 0;
        while (!q.empty()) {
            int x = q.top().second; q.pop();
            if (v[x]) continue; v[x] = 1;
            for (auto [y, w] : ver[x]) {
                if (d[y] >= d[x] + w) {  // ！注意，SPT 这里修改为>=号
                    d[y] = d[x] + w;
                    pre[y] = x;  // 记录前驱结点
                    q.push({d[y], y});
                }
            }
        }
    }
    void dfs(int x) {
        vis[x] = 1;
        for (auto [y, w] : ver[x]) {
            if (vis[y]) continue;
            if (pre[y] == x) {
                cout << id[{x, y}] << " ";  // 输出SPT所使用的边编号
                ans += edge[{x, y}];
                dfs(y);
            }
        }
    }
    void solve(int n) {
        djikstra(1);  // 以 1 为根
        dfs(1);  // 以 1 为根
        cout << endl << ans;  // 输出SPT的边权和
    }
}
bool Solve() {
    int n, m; cin >> n >> m;
    for (int i = 1; i <= m; ++ i) {
        int x, y, w; cin >> x >> y >> w;
        G::add(x, y, w), G::add(y, x, w);
        id[{x, y}] = id[{y, x}] = i;
    }
    G::solve(n);
    return 0;
}
```

== 无源汇点的最小割问题 Stoer–Wagner
<无源汇点的最小割问题-stoerwagner>
#quote(block: true)[
也称为全局最小割。定义补充（与《网络流》中的定义不同）：

#strong[割];：是一个边集，去掉其中所有边能使一张网络流图不再连通（即分成两个子图）。
]

#specline([#O($V E + V^2 "log" V$)（常近似看作 #O($V^3$)）])
通过#strong[递归];的方式来解决#strong[无向正权图];上的全局最小割问题。

```cpp
signed main() {
    int n, m;
    cin >> n >> m;

    DSU dsu(n);  // 这里引入DSU判断图是否联通，如题目有保证，则不需要此步骤
    vector<vector<int>> edge(n + 1, vector<int>(n + 1));
    for (int i = 1; i <= m; i++) {
        int x, y, w;
        cin >> x >> y >> w;
        dsu.merge(x, y);
        edge[x][y] += w;
        edge[y][x] += w;
    }

    // 图不联通：Poi(x) 应为 x 所在连通块大小，本库 DSU 无此接口，需自行补充，或题目保证连通时整段删除
    if (dsu.Poi(1) != n || m < n - 1) {
        cout << 0 << endl;
        return 0;
    }

    int MinCut = INF, S = 1, T = 1;  // 虚拟源汇点
    vector<int> bin(n + 1);
    auto contract = [&]() -> int {  // 求解S到T的最小割，定义为 cut of phase
        vector<int> dis(n + 1), vis(n + 1);
        int Min = 0;
        for (int i = 1; i <= n; i++) {
            int k = -1, maxc = -1;
            for (int j = 1; j <= n; j++) {
                if (!bin[j] && !vis[j] && dis[j] > maxc) {
                    k = j;
                    maxc = dis[j];
                }
            }
            if (k == -1) return Min;
            S = T, T = k, Min = maxc;
            vis[k] = 1;
            for (int j = 1; j <= n; j++) {
                if (!bin[j] && !vis[j]) {
                    dis[j] += edge[k][j];
                }
            }
        }
        return Min;
    };
    for (int i = 1; i < n; i++) {  // 这里取不到等号
        int val = contract();
        bin[T] = 1;
        MinCut = min(MinCut, val);
        if (!MinCut) {
            cout << 0 << endl;
            return 0;
        }
        for (int j = 1; j <= n; j++) {
            if (!bin[j]) {
                edge[S][j] += edge[j][T];
                edge[j][S] += edge[j][T];
            }
        }
    }
    cout << MinCut << endl;
}
```

== 欧拉路径/欧拉回路 Hierholzers
<欧拉路径欧拉回路-hierholzers>
#specline([#O($N + M)$)])
一笔画完所有边。存在性看度数；求路径用 Hierholzer：DFS 把边删掉，回溯再写入答案（得到反序，最后 reverse）。必须连通（忽略孤立点）。

#quote(block: true)[
欧拉路径：一笔画完图中全部边，画的顺序就是一个可行解；当起点终点相同时称欧拉回路。
]

=== 有向图欧拉路径存在判定
<有向图欧拉路径存在判定>
有向图欧拉路径存在：① 恰有一个点出度比入度多 $1$（为起点）；② 恰有一个点入度比出度多 $1$（为终点）；③ 恰有 $N - 2$ 个点入度均等于出度。如果是欧拉回路，则上方起点与终点的条件不存在，全部点均要满足最后一个条件。

```cpp
signed main() {
    int n, m;
    cin >> n >> m;

    DSU dsu(n + 1);  // 如果保证连通，则不需要 DSU
    vector<unordered_multiset<int>> ver(n + 1);  // 如果对于字典序有要求，则不能使用 unordered
    vector<int> degI(n + 1), degO(n + 1);
    for (int i = 1; i <= m; i++) {
        int x, y;
        cin >> x >> y;
        ver[x].insert(y);
        degI[y]++;
        degO[x]++;
        dsu.merge(x, y);  // 直接当无向图
    }
    int s = 1, t = 1, cnt = 0;
    for (int i = 1; i <= n; i++) {
        if (degI[i] == degO[i]) {
            cnt++;
        } else if (degI[i] + 1 == degO[i]) {
            s = i;
        } else if (degI[i] == degO[i] + 1) {
            t = i;
        }
    }
    if (dsu.size(1) != n || (cnt != n - 2 && cnt != n)) {
        cout << "No\n";
    } else {
        cout << "Yes\n";
    }
}
```

=== 无向图欧拉路径存在判定
<无向图欧拉路径存在判定>
无向图欧拉路径存在：① 恰有两个点度数为奇数（为起点与终点）；② 恰有 $N - 2$ 个点度数为偶数。前提是有边的点连通（孤立点不计）；欧拉回路则要求 $0$ 个奇度点。

```cpp
signed main() {
    int n, m;
    cin >> n >> m;

    DSU dsu(n + 1);  // 如果保证连通，则不需要 DSU
    vector<unordered_multiset<int>> ver(n + 1);  // 如果对于字典序有要求，则不能使用 unordered
    vector<int> deg(n + 1);
    for (int i = 1; i <= m; i++) {
        int x, y;
        cin >> x >> y;
        ver[x].insert(y);
        ver[y].insert(x);
        deg[y]++;
        deg[x]++;
        dsu.merge(x, y);  // 直接当无向图
    }
    int s = -1, t = -1, cnt = 0;
    for (int i = 1; i <= n; i++) {
        if (deg[i] % 2 == 0) {
            cnt++;
        } else if (s == -1) {
            s = i;
        } else {
            t = i;
        }
    }
    if (dsu.size(1) != n || (cnt != n - 2 && cnt != n)) {
        cout << "No\n";
    } else {
        cout << "Yes\n";
    }
}
```

=== 有向图欧拉路径求解（字典序最小）
<有向图欧拉路径求解字典序最小>
要求每个节点的出边按目标编号#strong[升序];排列（读入后排序，或直接存进 `multiset`），每次取最小出边即保证字典序最小；起点 `s` 按上文判定选取（欧拉回路可任取非孤立点）。

#pitfall[下方用 `vector::erase(begin())` 每次开头删除是 $cal(O)(deg)$，总复杂度退化为 $cal(O)(M^2)$——边多时改用 `multiset` 或指针法。]

```cpp
vector<int> ans;
auto dfs = [&](auto self, int x) -> void {
    while (ver[x].size()) {
        int net = *ver[x].begin();
        ver[x].erase(ver[x].begin());
        self(self, net);
    }
    ans.push_back(x);
};
dfs(dfs, s);
reverse(ans.begin(), ans.end());
for (auto it : ans) {
    cout << it << " ";
}
```

=== 无向图欧拉路径求解
<无向图欧拉路径求解>
无向图存双向边，走过一条边时要同时从两个端点删除两个方向；起点 `s` 选奇度点（欧拉回路任取非孤立点），先按上文完成奇度点计数判定。若也要求字典序最小，同样需要邻接表按编号升序。

```cpp
auto dfs = [&](auto self, int x) -> void {
    while (ver[x].size()) {
        int net = *ver[x].begin();
        ver[x].erase(ver[x].find(net));
        ver[net].erase(ver[net].find(x));
        cout << x << " " << net << endl;
        self(self, net);
    }
};
dfs(dfs, s);
```

== 差分约束
<差分约束>
给出一组包含 $m$ 个不等式、$n$ 个未知数的系统：

$ x_(u_i) - x_(v_i) lt.eq w_i quad (i = 1 , 2 , dots.h , m) $

求任意一组解。做法：把 $x_u - x_v lt.eq w$ 写成 $x_u lt.eq x_v + w$，从 $v$ 向 $u$ 连一条权值为 $w$ 的边跑最短路，最短路数组本身即为一组解；存在负环则无解。下方代码实际是 Bellman–Ford（每轮松弛全部 $m$ 条边、共 $n - 1$ 轮，复杂度 $cal(O)(n m)$，原文标注 SPFA 系误称），存边时 `e[i] = {v, u, w}` 正好实现 $v arrow.r u$ 这条边。#link("https://www.luogu.com.cn/problem/P5960")[参考]

#specline([Bellman-Ford 形态 #O($n m$)])

#pitfall[下方以 `d[1] = 0` 作单源；图不连通或存在从 1 不可达的点时需改为超级源点——向所有点连权 0 的边（即初始化全部 `d[i] = 0`）。]

#include-code("code/图论/差分约束.cpp")

== 2-Sat
<sat>
每个布尔变量拆成 $x$ 与 $not x$ 两个点。条款 $(a or b)$ 连边 $not a arrow.r b$、$not b arrow.r a$。同一 SCC 里同时出现 $x$ 与 $not x$ 则无解；否则拓扑序靠后的那个取值。

=== 基础封装
<基础封装>
#specline([基于 tarjan 缩点 #O($N + M$)])
下标从 $0$ 开始。`work()` 返回是否有解，`answer()` 给#strong[一组];可行解：`id[2i] > id[2i+1]` 时 `ans[i] = true`。#strong[不一定字典序最小];（最小需按变量顺序逐一 DFS）。`add(u, f, v, g)` 表示 $\( u$ 取 $f \) arrow.r.double \( v$ 取 $g \)$（`true` 编号 `2u+1`，`false` 编号 `2u`）。

#include-code("code/图论/基础封装.cpp")

=== 答案不唯一时不输出
<答案不唯一时不输出>
在运行后针对每一个点进行一次 dfs，时间复杂度为 $cal(O)(N^2)$​ ，当且仅当答案唯一时才输出，否则输出 `?` 替代。

2-Sat 方案计数为 NPC 问题。

```cpp
// 结构体中增加
int check(int x, int y) {
    vector<int> vis(2 * n);
    auto dfs = [&](auto self, int x) -> void {
        vis[x] = 1;
        for (auto y : e[x]) {
            if (vis[y]) continue;
            self(self, y);
        }
    };
    dfs(dfs, x);
    return vis[y];
}
// 主函数中增加
for (int i = 0; i < n; i++) {
    if (sat.check(2 * i, 2 * i + 1)) {
        cout << 1 << " ";
    } else if (sat.check(2 * i + 1, 2 * i)) {
        cout << 0 << " ";
    } else {
        cout << "?" << " ";
    }
}
```

== 图论常见结论及例题
<图论常见结论及例题>
建模对照，不是证明。对上题意再套。

=== 常见结论
<常见结论>
+ 要在有向图上求一个最大点集，使得任意两个点 $(i , j)$ 之间至少存在一条路径（可以是从 $i$ 到 $j$ ，也可以反过来，这两种有一个就行），#strong[即求解最长路];；

+ 要求出连通图上的任意一棵生成树，只需要跑一遍 #strong[bfs] ；

+ 给出一棵树，要求添加尽可能多的边，使得其是二分图：对树进行二分染色，显然，相同颜色的点之间连边不会破坏二分图的性质，故可添加的最多的边数即为 $"cnt"_("Black") dot "cnt"_("White") - (n - 1)$ ；

+ 当一棵树可以被黑白染色时，所有染黑节点的度之和等于所有染白节点的度之和；

+ 在竞赛图中，入度小的点，必定能到达出度小（入度大）的点 #link("https://codeforces.com/contest/1498/problem/E")[See] 。

+ 在竞赛图中，将所有点按入度从小到大排序，随后依次遍历，若对于某一点 $i$ 满足前 $i$ 个点的入度之和恰好等于 $⌊frac(n dot (n + 1), 2)⌋$ ，那么对于上一次满足这一条件的点 $p$ ，$p + 1$ 到 $i$ 点构成一个新的强连通分量 #link("https://codeforces.com/contest/1498/problem/E")[See] 。

  #quote(block: true)[
  举例说明，设满足上方条件的点为 $p_1 , p_2 med (p_1 + 1 < p_2)$ ，那么点 $1$ 到 $p_1$ 构成一个强连通分量、点 $p_1 + 1$ 到 $p_2$ 构成一个强连通分量。
  ]

+ 选择图中最少数量的边删除，使得图不连通，即求最小割；如果是删除点，那么拆点后求最小割 #link("https://www.luogu.com.cn/problem/P1345")[See];。

+ 如果一张图是#strong[平面图];，那么其边数一定小于等于 $3 n - 6$ #link("P3209")[See] 。

+ 若一张有向完全图存在环，则一定存在三元环。

+ 竞赛图三元环计数：#link("https://ac.nowcoder.com/acm/contest/84244/F")[See] 。

+ 有向图判是否存在环直接用 topsort；无向图判是否存在环直接用 dsu，也可以使用 topsort，条件变为 `deg[i] <= 1` 时入队。

=== 常见例题
<常见例题>
==== 杂
<杂>
题意：给出一棵节点数为 $2 n$ 的树，要求将点分割为 $n$ 个点对，使得点对的点之间的距离和最大。

可以转化为边上问题：对于每一条边，其被利用的次数即为 $"min" { upright("其左边的点的数量") , upright("其右边的点的数量") }$ ，使用树形 `dp` 计算一遍即可。如下图样例，答案为 $10$ 。

#image("/images/img-08.png")

```cpp
vector<int> val(n + 1, 1);
int ans = 0;
function<void(int, int)> dfs = [&](int x, int fa) {
    for (auto y : ver[x]) {
        if (y == fa) continue;
        dfs(y, x);
        val[x] += val[y];
        ans += min(val[y], k - val[y]);
    }
};
dfs(1, 0);
cout << ans << endl;
```

#line(length: 100%)

题意：以哪些点为起点可以无限的在有向图上绕

概括一下这些点可以发现，一类是环上的点，另一类是可以到达环的点。建反图跑一遍 topsort 板子，根据容斥，未被移除的点都是答案 #link("https://atcoder.jp/contests/abc245/tasks/abc245_f")[See] 。

#line(length: 100%)

题意：添加最少的边，使得有向图变成一个 SCC

将原图的 SCC 缩点，统计缩点后的新图上入度为 $0$ 和出度为 $0$ 的点的数量 $"cnt"_("in")$、$"cnt"_("out")$，答案即为 $"max" ("cnt"_("in") , "cnt"_("out"))$ 。过程大致是先将一个出度为 $0$ 的点和一个入度为 $0$ 的点相连，剩下的点随便连 #link("https://www.acwing.com/problem/content/369/")[See] 。

#line(length: 100%)

题意：添加最少的边，使得无向图变成一个 E-DCC

将原图的 E-DCC 缩点，统计缩点后的新图上度为 $1$ 的点（叶子结点）的数量 $"cnt"$ ，答案即为 $⌈frac("cnt", 2)⌉$ 。过程大致是每次找两个叶子结点（但是还有一些条件限制）相连，若最后余下一个点随便连 #link("https://www.acwing.com/problem/content/397/")[See] 。

#line(length: 100%)

题意：在树上找到一个最大的连通块，使得这个联通内点权和边权之和最大，输出这个值，数据中存在负数的情况。

使用 dfs 即可解决。

```cpp
LL n, point[N];
LL ver[N], head[N], nex[N], tot; bool v[N];
map<pair<LL, LL>, LL> edge;
// void add(LL x, LL y) {}
void dfs(LL x) {
    for (LL i = head[x]; i; i = nex[i]) {
        LL y = ver[i];
        if (v[y]) continue;
        v[y] = true; dfs(y); v[y] = false;
    }
    for (LL i = head[x]; i; i = nex[i]) {
        LL y = ver[i];
        if (v[y]) continue;
        point[x] += max(point[y] + edge[{x, y}], 0LL);
    }
}
void Solve() {
    cin >> n;
    FOR(i, 1, n) cin >> point[i];
    FOR(i, 2, n) {
        LL x, y, w; cin >> x >> y >> w;
        edge[{x, y}] = edge[{y, x}] = w;
        add(x, y), add(y, x);
    }
    v[1] = true; dfs(1); LL ans = -MAX18;
    FOR(i, 1, n) ans = max(ans, point[i]);
    cout << ans << endl;
}
```

#line(length: 100%)

=== Prüfer 序列：凯莱公式
<prüfer-序列凯莱公式>
题意：给定 $n$ 个顶点，可以构建出多少棵标记树？

#image("/images/img-09.png")

$n lt.eq 4$ 时的样例如上，通项公式为 $n^(n - 2)$ 。

==== Prüfer 序列扩展
<prüfer-序列扩展>
一个 $n$ 个点 $m$ 条边的带标号无向图有 $k$ 个连通块。我们希望添加 $k - 1$ 条边使得整个图连通，求方案数量 #link("https://codeforces.com/contest/156/problem/D")[See] 。

设 $s_i$ 表示每个连通块的数量，通项公式为 $n^(k - 2) dot product_(i = 1)^k s_i$ ，当 $k < 2$ 时答案为 $1$ 。

=== 单源最短/次短路计数
<单源最短次短路计数>
依赖链式前向星段的 `h / tot / ver / ne / edge / add`；`Z` 为取模类（见杂项章），`INF` 需自行定义。下方 `Solve` 把边权固定为 $1$（`w = 1`），统计起点到每个点的#strong[最短路条数，以及长度恰好为最短路 $+ 1$ 的次短路条数];，按题目修改边权读入即可。

```cpp
const int N = 2e5 + 7, M = 1e6 + 7;
int n, m, s, e; int d[N][2], v[N][2];  // 0 代表最短路， 1 代表次短路
Z num[N][2];

void Clear() {
    for (int i = 1; i <= n; ++ i) h[i] = edge[i] = 0;
    tot = 0;
    for (int i = 1; i <= n; ++ i) num[i][0] = num[i][1] = v[i][0] = v[i][1] = 0;
    for (int i = 1; i <= n; ++ i) d[i][0] = d[i][1] = INF;
}

int ver[M], ne[M], h[N], edge[M], tot;
void add(int x, int y, int w) {
    ver[++ tot] = y, ne[tot] = h[x], h[x] = tot;
    edge[tot] = w;
}

void dji() {
    priority_queue<PIII, vector<PIII>, greater<PIII> > q; q.push({0, s, 0});
    num[s][0] = 1; d[s][0] = 0;
    while (!q.empty()) {
        auto [dis, x, type] = q.top(); q.pop();
        if (v[x][type]) continue; v[x][type] = 1;
        for (int i = h[x]; i; i = ne[i]) {
            int y = ver[i], w = dis + edge[i];
            if (d[y][0] > w) {
                d[y][1] = d[y][0], num[y][1] = num[y][0];
                    // 如果找到新的最短路，将原有的最短路数据转化为次短路
                q.push({d[y][1], y, 1});
                d[y][0] = w, num[y][0] = num[x][type];
                q.push({d[y][0], y, 0});
            }
            else if (d[y][0] == w) num[y][0] += num[x][type];
            else if (d[y][1] > w) {
                d[y][1] = w, num[y][1] = num[x][type];
                q.push({d[y][1], y, 1});
            }
            else if (d[y][1] == w) num[y][1] += num[x][type];
        }
    }
}
void Solve() {
    cin >> n >> m >> s >> e;
    Clear();  //多组样例务必完全清空
    for (int i = 1; i <= m; ++ i) {
        int x, y, w; cin >> x >> y; w = 1;
        add(x, y, w), add(y, x, w);
    }
    dji();
    Z ans = num[e][0];
    if (d[e][1] == d[e][0] + 1) {
        ans += num[e][1];  // 只有在次短路满足条件时才计算（距离恰好比最短路大1）
    }
    cout << ans.val() << endl;
}
```

=== 判定图中是否存在负环
<判定图中是否存在负环>
SPFA：某点入队超过 $n$ 次（或某点松弛次数 $gt.eq n$）则存在负环。$cal(O)(K M)$，常数比裸最短路更高，可被卡。

#include-code("code/图论/判定图中是否存在负环.cpp")

=== 输出任意一个三元环
<输出任意一个三元环>
原题：给出一张有向完全图，输出任意一个三元环上的全部元素 #link("https://codeforces.com/problemset/problem/117/C")[See] 。使用 dfs，复杂度 $cal(O)(N + M)$，可以扩展到非完全图和无向图。

#include-code("code/图论/输出任意一个三元环.cpp")

=== 带权最小环大小与计数
<带权最小环大小与计数>
原题：给出一张有向带权图，求解图上最小环的长度、有多少个这样的最小环 #link("https://acm.hdu.edu.cn/contest/problem?cid=1097&pid=1011")[See] 。使用 floyd，复杂度为 $cal(O)(N^3)$ ，可以扩展到无向图。

```cpp
LL Min = 1e18, ans = 0;
for (int k = 1; k <= n; k++) {
    for (int i = 1; i <= n; i++) {
        for (int j = 1; j <= n; j++) {
            if (dis[i][j] > dis[i][k] + dis[k][j]) {
                dis[i][j] = dis[i][k] + dis[k][j];
                cnt[i][j] = cnt[i][k] * cnt[k][j] % mod;
            } else if (dis[i][j] == dis[i][k] + dis[k][j]) {
                cnt[i][j] = (cnt[i][j] + cnt[i][k] * cnt[k][j] % mod) % mod;
            }
        }
    }
    for (int i = 1; i < k; i++) {
        if (a[k][i]) {
            if (a[k][i] + dis[i][k] < Min) {
                Min = a[k][i] + dis[i][k];
                ans = cnt[i][k];
            } else if (a[k][i] + dis[i][k] == Min) {
                ans = (ans + cnt[i][k]) % mod;
            }
        }
    }
}
```

=== 最小环大小
<最小环大小>
原题：给出一张无向图，求解图上最小环的长度、有多少个这样的最小环 #link("https://codeforces.com/contest/1205/problem/B")[See] 。使用 floyd，可以扩展到有向图。

```cpp
int floyd(int n) {
    for (int i = 1; i <= n; ++ i) {
        for (int j = 1; j <= n; ++ j) {
            val[i][j] = dis[i][j];  // 记录最初的边权值
        }
    }
    int ans = 0x3f3f3f3f;
    for (int k = 1; k <= n; ++ k) {
        for (int i = 1; i < k; ++ i) {  // 注意这里是没有等于号的
            for (int j = 1; j < i; ++ j) {
                ans = min(ans, dis[i][j] + val[i][k] + val[k][j]);
            }
        }
    for (int i = 1; i <= n; ++ i) {  // 往下是标准的floyd
        for (int j = 1; j <= n; ++ j) {
                dis[i][j] = min(dis[i][j], dis[i][k] + dis[k][j]);
            }
        }
    }
    return ans;
}
```

使用 bfs，复杂度为 $cal(O)(N^2)$ 。

```cpp
auto bfs = [&] (int s) {
    queue<int> q; q.push(s);
    dis[s] = 0;
    fa[s] = -1;
    while (q.size()) {
        auto x = q.front(); q.pop();
        for (auto y : ver[x]) {
            if (y == fa[x]) continue;
            if (dis[y] == -1) {
                dis[y] = dis[x] + 1;
                fa[y] = x;
                q.push(y);
            }
            else ans = min(ans, dis[x] + dis[y] + 1);
        }
    }
};
for (int i = 1; i <= n; ++ i) {
    fill(dis + 1, dis + 1 + n, -1);
    bfs(i);
}
cout << ans;
```

=== 本质不同简单环计数
<本质不同简单环计数>
原题：给出一张无向图，输出简单环的数量 #link("https://codeforces.com/contest/11/problem/D")[See] 。注意这里环套环需要分别多次统计，下图答案应当为 $7$。使用状压 dp，复杂度为 $cal(O)(M dot 2^N)$，可以扩展到有向图。

#figure([#image("/images/img-11.png");],
  caption: [
    image.png
  ]
)

#include-code("code/图论/本质不同简单环计数.cpp")

=== 输出任意一个非二元简单环
<输出任意一个非二元简单环>
原题：给出一张无向图，不含自环与重边，输出任意一个简单环的大小以及其上面的全部元素 #link("https://codeforces.com/problemset/problem/1364/D")[See] 。注意输出的环的大小是随机的，#strong[不等价于最小环];。

由于不含重边与自环，所以环的大小至少为 $3$ ，使用 dfs 处理出 dfs 序，复杂度为 $cal(O)(N + M)$，可以扩展到有向图；如果有向图中二元环也允许计入答案，则需要删除下方标注行。

```cpp
vector<int> dis(n + 1, -1), fa(n + 1);
auto dfs = [&](auto self, int x) -> void {
    for (auto y : ver[x]) {
        if (y == fa[x]) continue;  // 二元环需删去该行
        if (dis[y] == -1) {
            dis[y] = dis[x] + 1;
            fa[y] = x;
            self(self, y);
        } else if (dis[y] < dis[x]) {
            cout << dis[x] - dis[y] + 1 << endl;
            int pre = x;
            cout << pre << " ";
            while (pre != y) {
                pre = fa[pre];
                cout << pre << " ";
            }
            cout << endl;
            exit(0);
        }
    }
};
for (int i = 1; i <= n; i++) {
    if (dis[i] == -1) {
        dis[i] = 0;
        dfs(dfs, i);  // 从每个未访问的连通块入口开始，原来是写死的 1
    }
}
```

=== 有向图环计数
<有向图环计数>
原题：给出一张有向图，输出环的数量。注意这里环套环仅需要计算一次，数据包括二元环和自环，下图例应当输出 $3$ 个环。使用 dfs 染色法，复杂度为 $cal(O)(N + M)$。

#image("/images/img-10.png")

```cpp
int ans = 0;
vector<int> vis(n + 1);
auto dfs = [&](auto self, int x) -> void {
    vis[x] = 1;
    for (auto y : ver[x]) {
        if (vis[y] == 0) {
            self(self, y);
        } else if (vis[y] == 1) {
            ans++;
        }
    }
    vis[x] = 2;
};
for (int i = 1; i <= n; i++) {
    if (!vis[i]) {
        dfs(dfs, i);
    }
}
cout << ans << endl;
```

=== 输出有向图任意一个环
<输出有向图任意一个环>
DFS 三色：访问中的后向边指向栈上祖先，即找到环。含二元环和自环。任意一个即可。

```cpp
vector<int> dis(n + 1), vis(n + 1), fa(n + 1);
auto dfs = [&](auto self, int x) -> void {
    vis[x] = 1;
    for (auto y : ver[x]) {
        if (vis[y] == 0) {
            dis[y] = dis[x] + 1;
            fa[y] = x;
            self(self, y);
        } else if (vis[y] == 1) {
            cout << dis[x] - dis[y] + 1 << endl;
            int pre = x;
            cout << pre << " ";
            while (pre != y) {
                pre = fa[pre];
                cout << pre << " ";
            }
            cout << endl;
            exit(0);
        }
    }
    vis[x] = 2;
};
for (int i = 1; i <= n; i++) {
    if (!vis[i]) {
        dfs(dfs, i);
    }
}
```

=== 判定带环图是否是平面图
<判定带环图是否是平面图>
原题：给定一个环以一些额外边，对于每一条额外边判定其位于环外还是环内，使得任意两条无重合顶点的额外边都不相交（即这张图构成平面图）#link("https://codeforces.com/contest/27/problem/D")[See1];, #link("https://www.luogu.com.cn/problem/P3209")[See2] 。

使用 2-sat。考虑全部边都位于环内，那么“一条边完全包含另一条边”、“两条边完全没有交集”这两种情况都不会相交，可以直接跳过这两种情况的讨论。

#include-code("code/图论/判定带环图是否是平面图.cpp")
