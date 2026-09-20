#include "../contest.hpp"

// @book-begin
struct MinCostFlow {
    struct Edge {
        int v;
        i64 c, f;
    };
    int n;
    const i64 INF = 1LL << 60;  // 要求 n * max|cost| < INF / 4
    vector<Edge> e;
    vector<vector<int>> g;
    vector<i64> h, dis;
    vector<int> pre;
    MinCostFlow(int n) : n(n), g(n) {}
    void add(int u, int v, i64 capacity, i64 cost) {
        assert(capacity >= 0);
        g[u].push_back(e.size());
        e.push_back({v, capacity, cost});
        g[v].push_back(e.size());
        e.push_back({u, 0, -cost});
    }
    void initPotential(int s) {  // 初始残量网络不得有从 s 可达的负费用环
        h.assign(n, INF);
        vector<int> length(n);
        vector<bool> queued(n);
        queue<int> q;
        h[s] = 0;
        q.push(s);
        queued[s] = true;
        while (!q.empty()) {
            int u = q.front();
            q.pop();
            queued[u] = false;
            for (int index : g[u]) {
                auto [v, c, f] = e[index];
                if (c == 0 || h[v] <= h[u] + f) continue;
                h[v] = h[u] + f;
                length[v] = length[u] + 1;
                assert(length[v] < n);
                if (!queued[v]) {
                    queued[v] = true;
                    q.push(v);
                }
            }
        }
        for (auto &value : h) if (value == INF) value = 0;
    }
    bool dijkstra(int s, int t) {
        dis.assign(n, INF);
        pre.assign(n, -1);
        using Entry = pair<i64, int>;
        priority_queue<Entry, vector<Entry>, greater<Entry>> q;
        dis[s] = 0;
        q.push({0, s});
        while (!q.empty()) {
            auto [d, u] = q.top();
            q.pop();
            if (d != dis[u]) continue;
            for (int index : g[u]) {
                auto [v, c, f] = e[index];
                i64 next = d + h[u] - h[v] + f;
                if (c > 0 && next < dis[v]) {
                    dis[v] = next;
                    pre[v] = index;
                    q.push({next, v});
                }
            }
        }
        return dis[t] != INF;
    }
    pair<i64, i64> flow(int s, int t) {  // 返回本次追加的流量和费用，保留残量网络
        assert(s != t);
        initPotential(s);
        i64 total = 0;
        i128 cost = 0;
        while (dijkstra(s, t)) {
            for (int v = 0; v < n; ++v) if (dis[v] != INF) h[v] += dis[v];
            i64 aug = LLONG_MAX;
            for (int v = t; v != s; v = e[pre[v] ^ 1].v) aug = min(aug, e[pre[v]].c);
            for (int v = t; v != s; v = e[pre[v] ^ 1].v) {
                e[pre[v]].c -= aug;
                e[pre[v] ^ 1].c += aug;
            }
            assert(total <= LLONG_MAX - aug);
            total += aug;
            cost += i128(aug) * (h[t] - h[s]);
        }
        assert(LLONG_MIN <= cost && cost <= LLONG_MAX);
        return {total, i64(cost)};
    }
};
// @book-end
