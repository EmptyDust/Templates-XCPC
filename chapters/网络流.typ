#import "../prelude.typ": *

= 网络流
<网络流>
流量分配类问题的总章：题面问「最多运多少」「最小代价怎么断」「选了 $A$ 就必须选 $B$」时翻这里。所有模型最终汇成同一套代码——建好图跑最大流/费用流，难点全在建图，套路单列在「建图」一节。

== 最大流
<最大流>
源到汇能同时挤过的最大流量。每条边容量、反向边退流。最大流 $=$ 最小割。Dinic 分层后多路增广；HLPP 推预流。建图：`add(u,v,c)` 会自动加反向边。

=== Dinic 解
<dinic-解>
#specline([最坏 #O($N^2 M$)], [例题 $N = 1200 , med m = 5 times 10^3$])
BFS 分层，当前弧 DFS 一次找完该层所有增广。`Flow_<T>` 的 `T` 为容量类型；容量非负，源汇不同，最大流须能由 `T` 表示。`work(s,t)` 返回本次追加的流量并保留残量网络。

#include-code("code/网络流/Dinic-解.cpp")

=== 预流推进 HLPP
<预流推进-hlpp>
#specline([最坏 #O($N^2 sqrt(M)$)], [例题 $N = 1200 , med m = 1.2 times 10^5$])
预流推进（HLPP，最高标号预流推进）是实际运行速度最快的最大流实现之一，适合大数据量、边较多的场合。用法与 Dinic 相同：`PushRelabel<i64> pr(n);`（模板参数为有符号整数，容量和超额流均用该类型；所有容量之和须能表示）→ 反复 `addedge(u, v, w)` → `pr.work(s, t)`。每个对象完成一次最大流求解；换图或换源汇时重新构造。

实现要点：`init` 从汇点反向 BFS 赋高度标签（`f` 控制是否入 gap 桶），`PushPoint` 对虚流做推流/重贴标签，`gobalcnt` 累计入桶次数、超过 $10 n$ 时重新 `init` 防退化；`work` 开头 `ex[s] = INF` 只是哨兵，结尾 `ex[s] -= INF` 扣回，`maxflow` 由此而来。

#pitfall[#strong[同一对象不能重复 `work`]——残留的虚流会污染结果，多组询问每次新建对象。]

#include-code("code/网络流/预流推进-HLPP.cpp")

== 最小割
<最小割>
基础模型：构筑二分图，左半部 $n$ 个点代表盈利项目，右半部 $m$ 个点代表材料成本，收益为盈利之和减去成本之和，求最大收益。

建图：建立源点 $S$ 向左半部连边，建立汇点 $T$ 向右半部连边，如果某个项目需要某个材料，则新增一条容量 $+ oo$ 的跨部边。

割边：放弃某个项目则断开 $S$ 至该项目的边，购买某个原料则断开该原料至 $T$ 的边，最终的图一定不存在从 $S$ 到 $T$ 的路径，此时我们得到二分图的一个 $S - T$ 割；容量 $1 E 18$ 的跨部边不可能被割断，用来强制“项目存在 ⇒ 所需原料已购买”的依赖。此时最小割即为求解最大流，边权之和减去最大流即为最大收益。

#include-code("code/网络流/最小割.cpp")

== 建图
<建图>
模型套路，代码仍是上面的最大流/费用流。上面「最小割」一节的项目-材料模型即最大权闭合子图：正权连 $S$、负权连 $T$、依赖边容量 $+ oo$，答案 $=$ 正权之和 $-$ 最小割。

最小割方案与必须边：最大流后在残留网络从 $S$ 沿有残量的边 BFS，可达点即 $S$ 侧割集；$S$ 直连的点必在 $S$ 侧、直连 $T$ 的点必在 $T$ 侧，两侧并成全集则割唯一。满流边 $(u, v)$ 是#strong[可行边];当且仅当缩点后 $u, v$ 属于不同 SCC；是#strong[必须边];当且仅当 $"scc"_u = "scc"_S$ 且 $"scc"_v = "scc"_T$。

上下界：边 $(u, v)$ 带下界 $l$、上界 $r$ 时改成自由容量 $r - l$，下界差额记 `du[v] += l`、`du[u] -= l`；$"du"_i > 0$ 连 $(SS, i, "du"_i)$，$"du"_i < 0$ 连 $(i, TT, -"du"_i)$，附加边全部满流才有可行解。有源汇 $(S, T)$ 时加一条 $T arrow.r S$ 容量 $oo$ 的边即化成无源汇；最大流在判可行后记下这条边的流量，删去超级源汇与它再跑一遍 $(S, T)$，答案为两次之和；最小流则先不带 $T arrow.r S$ 跑一遍 $SS arrow.r TT$，补上这条边再跑一遍，满流时边上的流量即最小流。费用流同构：原边带费用，附加边费用 $0$。

== 最小割树 Gomory-Hu Tree
<最小割树-gomory-hu-tree>
#specline([$n-1$ 次最大流], [点对预处理 #O($N^2$)])
无向非负容量图的最小割树；原图可以不连通。任意两个不同顶点的最小割等于树上路径的最小边权。依赖 Dinic 的 `Flow_<T>`，顶点为 $1 dots.c n$，容量及割值须能由 `T` 表示。

每轮从原始容量复制一个流对象；残量网络的可达集用于调整父节点和割值。返回普通邻接表，查询可以接树上路径最小值。

```cpp
template<class T>
vector<vector<pair<int, T>>> gomoryHu(int n, const vector<tuple<int, int, T>> &edges) {
    assert(n >= 1);
    Flow_<T> original(n);
    for (auto [u, v, capacity] : edges) {
        original.add(u, v, capacity);
        original.add(v, u, capacity);
    }
    vector<int> parent(n + 1, 1);
    vector<T> cut(n + 1);
    parent[1] = 0;
    for (int s = 2; s <= n; ++s) {
        int t = parent[s];
        auto flow = original;  // 每轮复制原始容量，不改 Dinic 内部接口
        T value = flow.work(s, t);
        // work 结束时最后一次 BFS 的 d 标记源点在残量网络中的可达集。
        for (int v = s + 1; v <= n; ++v) {
            if (parent[v] == t && flow.d[v] != -1) parent[v] = s;
        }
        if (t != 1 && flow.d[parent[t]] != -1) {
            parent[s] = parent[t];
            parent[t] = s;
            cut[s] = cut[t];
            cut[t] = value;
        } else {
            cut[s] = value;
        }
    }
    vector<vector<pair<int, T>>> tree(n + 1);
    for (int v = 2; v <= n; ++v) {
        tree[v].push_back({parent[v], cut[v]});
        tree[parent[v]].push_back({v, cut[v]});
    }
    return tree;
}
```

完整用法：输入无向边后读询问，预处理全部不同点对的答案。

```cpp
int main() {
    int n, m;
    cin >> n >> m;
    vector<tuple<int, int, i64>> edges;
    for (int i = 0; i < m; ++i) {
        int u, v;
        i64 capacity;
        cin >> u >> v >> capacity;
        edges.emplace_back(u, v, capacity);
    }
    auto tree = gomoryHu(n, edges);
    vector answer(n + 1, vector<i64>(n + 1));
    for (int s = 1; s <= n; ++s) {
        auto dfs = [&](auto &&self, int u, int parent, i64 value) -> void {
            answer[s][u] = value;
            for (auto [v, capacity] : tree[u]) {
                if (v != parent) self(self, v, u, min(value, capacity));
            }
        };
        dfs(dfs, s, 0, LLONG_MAX);
    }
    int q;
    cin >> q;
    while (q--) {
        int u, v;
        cin >> u >> v;
        assert(u != v);
        cout << answer[u][v] << '\n';
    }
}
```

== 费用流
<费用流>
#specline([总计 #O($N M + f dot M "log" N$)（$f$ 为追加流量）], [单次增广 #O($M "log" N$)])
给定一个带费用的网络，规定 $(u , v)$ 间的费用为 $f (u , v) times w (u , v)$ ，求解该网络中总花费最小的最大流称之为#strong[最小费用最大流];。用法：`MinCostFlow mcf(n);` → 反复 `mcf.add(u, v, 流量, 费用)`（容量非负，可直接加入负费用边）→ `mcf.flow(s, t)` 返回 `{最大流, 最小费用}`。顶点为 $0 dots.c n-1$，源汇不同；初始网络不得含负费用环，不处理独立的费用环流。先用 SPFA 初始化势能，再用 Dijkstra 增广。重复调用返回本次追加的流量和费用。边费用、距离及势能用 `i64`；设 $W$ 为最大边费用绝对值，要求 $n W < 2^58$，给约化费用留余量。容量、总流量和最终费用须在 `i64` 内；流量乘路径费用及其累加局部使用 `i128`，允许最终相消前超过 `i64`。

#include-code("code/网络流/费用流.cpp")
