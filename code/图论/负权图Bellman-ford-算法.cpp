#include "../contest.hpp"

// @book-begin
vector<i64> bellmanFord(int n, const vector<tuple<int, int, i64>> &edges, int s, int k) {
    // 1-index，至多 k 条边；inf 表示不可达，要求 k * max|w| < inf。
    assert(k >= 0);
    const i64 inf = 1LL << 60;
    vector<i64> d(n + 1, inf);
    d[s] = 0;
    for (int step = 0; step < k; ++step) {
        auto previous = d;
        for (auto [u, v, w] : edges) {
            if (previous[u] != inf) d[v] = min(d[v], previous[u] + w);
        }
    }
    return d;
}

// @book-end

// @example-begin
int main() {
    int n, m, k;
    cin >> n >> m >> k;
    vector<tuple<int, int, i64>> edges(m);
    for (auto &[u, v, w] : edges) cin >> u >> v >> w;
    auto d = bellmanFord(n, edges, 1, k);
    for (int v = 1; v <= n; ++v) {
        if (d[v] != (1LL << 60)) cout << d[v] << '\n';
        else cout << "N\n";
    }
}
// @example-end
