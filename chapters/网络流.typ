#import "../prelude.typ": *

= 网络流
<网络流>
== 最大流
<最大流>
源到汇能同时挤过的最大流量。每条边容量、反向边退流。最大流 $=$ 最小割。Dinic 分层后多路增广；HLPP 推预流。建图：`add(u,v,c)` 会自动加反向边。

=== Dinic 解
<dinic-解>
理论最坏 $cal(O)(N^2 M)$，例题范围 $N = 1200 , med m = 5 times 10^3$。BFS 分层，当前弧 DFS 一次找完该层所有增广。`work(s, t)` 返回最大流。

#include-code("code/网络流/Dinic-解.cpp")

=== 预流推进 HLPP
<预流推进-hlpp>
预流推进（HLPP，最高标号预流推进）是实际运行速度最快的最大流实现之一，适合大数据量、边较多的场合；理论最坏复杂度为 $cal(O)(N^2 sqrt(M))$ ，例题范围：$N = 1200 , med m = 1.2 times 10^5$ 。用法与 Dinic 相同：`PushRelabel<long long> pr(n);`（模板参数须能容纳 `INF = 0x3f3f3f3f3f3f3f3f3f`）→ 反复 `addedge(u, v, w)` → `pr.work(s, t)`。实现要点：`init` 从汇点反向 BFS 赋高度标签（`f` 控制是否入 gap 桶），`PushPoint` 对虚流做推流/重贴标签，`gobalcnt` 累计入桶次数、超过 $10 n$ 时重新 `init` 防退化。注意 `work` 开头 `ex[s] = INF` 只是哨兵，结尾 `ex[s] -= INF` 扣回，`maxflow` 也由此而来；#strong[同一对象不能重复 `work`];（残留的虚流会污染结果），多组询问请每次新建对象。

#include-code("code/网络流/预流推进-HLPP.cpp")

== 最小割
<最小割>
基础模型：构筑二分图，左半部 $n$ 个点代表盈利项目，右半部 $m$ 个点代表材料成本，收益为盈利之和减去成本之和，求最大收益。

建图：建立源点 $S$ 向左半部连边，建立汇点 $T$ 向右半部连边，如果某个项目需要某个材料，则新增一条容量 $+ oo$ 的跨部边。

割边：放弃某个项目则断开 $S$ 至该项目的边，购买某个原料则断开该原料至 $T$ 的边，最终的图一定不存在从 $S$ 到 $T$ 的路径，此时我们得到二分图的一个 $S - T$ 割；容量 $1 E 18$ 的跨部边不可能被割断，用来强制”项目存在 ⇒ 所需原料已购买”的依赖。此时最小割即为求解最大流，边权之和减去最大流即为最大收益。

#include-code("code/网络流/最小割.cpp")

== 建图
<建图>
模型套路，代码仍是上面的最大流/费用流。上面「最小割」一节的项目-材料模型即最大权闭合子图：正权连 $S$、负权连 $T$、依赖边容量 $+ oo$，答案 $=$ 正权之和 $-$ 最小割。

最小割方案与必须边：最大流后在残留网络从 $S$ 沿有残量的边 BFS，可达点即 $S$ 侧割集；$S$ 直连的点必在 $S$ 侧、直连 $T$ 的点必在 $T$ 侧，两侧并成全集则割唯一。满流边 $(u, v)$ 是#strong[可行边];当且仅当缩点后 $u, v$ 属于不同 SCC；是#strong[必须边];当且仅当 $"scc"_u = "scc"_S$ 且 $"scc"_v = "scc"_T$。

上下界：边 $(u, v)$ 带下界 $l$、上界 $r$ 时改成自由容量 $r - l$，下界差额记 `du[v] += l`、`du[u] -= l`；$"du"_i > 0$ 连 $(SS, i, "du"_i)$，$"du"_i < 0$ 连 $(i, TT, -"du"_i)$，附加边全部满流才有可行解。有源汇 $(S, T)$ 时加一条 $T arrow.r S$ 容量 $oo$ 的边即化成无源汇；最大流在判可行后记下这条边的流量，删去超级源汇与它再跑一遍 $(S, T)$，答案为两次之和；最小流则先不带 $T arrow.r S$ 跑一遍 $SS arrow.r TT$，补上这条边再跑一遍，满流时边上的流量即最小流。费用流同构：原边带费用，附加边费用 $0$。

== 最小割树 Gomory-Hu Tree
<最小割树-gomory-hu-tree>
无向连通图抽象出的一棵树，满足任意两点间的距离是他们的最小割。一共需要跑 $n$ 轮最小割，总复杂度 $cal(O)(N^3 M)$ ，预处理最小割树上任意两点的距离 $cal(O)(N^2)$ 。

过程：分治 $n$ 轮，每一轮在图上随机选点，跑一轮最小割后连接树边；这一网络的残留网络会将剩余的点分为两组，根据分组分治。实现上每个连通分量用 `fa[x] == x` 的点作代表（初始全部归属 0），每轮取第一个非代表的点与其代表跑最小割，再按残留网络可达性（点集 `vis`）把另一侧的点改挂到新代表；#strong[每轮 `work` 前必须先退流（`reset`）];，否则残留网络混着上一轮的流量、分组错误。

```cpp
void reset() {  // 原为独立函数，须移入 Flow 结构体作成员：把每条边的反向边流量退回正向边
    for (int i = 0; i < ver.size(); i += 2) {
        ver[i].w += ver[i ^ 1].w;
        ver[i ^ 1].w = 0;
    }
}

signed main() {  // Gomory-Hu Tree
    int n, m;
    cin >> n >> m;

    Flow<int> flow(n);
    for (int i = 1; i <= m; i++) {
        int u, v, w;
        cin >> u >> v >> w;
        flow.add(u, v, w);
        flow.add(v, u, w);
    }

    vector<int> vis(n + 1), fa(n + 1);
    vector ans(n + 1, vector<int>(n + 1, 1E9));  // N^2 枚举出全部答案
    vector<vector<pair<int, int>>> adj(n + 1);
    for (int i = 1; i <= n; i++) { // 分治 n 轮
        int s = 0;  // 本质是在树上随机选点、跑最小割后连边
        for (; s <= n; s++) {
            if (fa[s] != s) break;
        }
        int t = fa[s];

        flow.reset();  // 每轮最小割前退流，否则残留网络不干净、分组错误
        int cut = flow.work(s, t); // 残留网络将点集分为两组，分治
        adj[s].push_back({t, cut});
        adj[t].push_back({s, cut});

        vis.assign(n + 1, 0);
        auto dfs = [&](auto dfs, int u) -> void {
            vis[u] = 1;
            for (auto it : flow.h[u]) {
                auto [v, c] = flow.ver[it];
                if (c && !vis[v]) {
                    dfs(dfs, v);
                }
            }
        };
        dfs(dfs, s);
        for (int j = 0; j <= n; j++) {
            if (vis[j] && fa[j] == t) {
                fa[j] = s;
            }
        }
    }

    for (int i = 0; i <= n; i++) {
        auto dfs = [&](auto dfs, int u, int fa, int c) -> void {
            ans[i][u] = c;
            for (auto [v, w] : adj[u]) {
                if (v == fa) continue;
                dfs(dfs, v, u, min(c, w));
            }
        };
        dfs(dfs, i, -1, 1E9);
    }

    int q;
    cin >> q;
    while (q--) {
        int u, v;
        cin >> u >> v;
        cout << ans[u][v] << "\n"; // 预处理答数组
    }
}
```

== 费用流
<费用流>
给定一个带费用的网络，规定 $(u , v)$ 间的费用为 $f (u , v) times w (u , v)$ ，求解该网络中总花费最小的最大流称之为#strong[最小费用最大流];。用法：`MinCostFlow mcf(n);` → 反复 `mcf.add(u, v, 流量, 费用)`（负费用的处理见 `add` 的注释）→ `mcf.flow(s, t)` 返回 `{最大流, 最小费用}`。下方实现用 #strong[Dijkstra + 势能];（`h` 数组，Johnson 重赋权保证边权非负）代替 SPFA 找增广路，单次增广 $cal(O)(M "log" N)$，总复杂度 $cal(O)(f dot M "log" N)$（$f$ 为最大流的值）。

#include-code("code/网络流/费用流.cpp")
