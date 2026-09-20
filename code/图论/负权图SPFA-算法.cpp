#include "../contest.hpp"

// @book-begin
vector<i64> spfa(const vector<vector<pair<int, i64>>> &adj, int s) {
    // 0-index，s 为有效顶点；空向量表示源点可达负环。
    // inf 表示不可达，要求 n * max|w| < inf。
    int n = adj.size();
    const i64 inf = 1LL << 60;
    vector<i64> d(n, inf);
    vector<int> length(n);
    vector<bool> queued(n);
    queue<int> q;
    d[s] = 0;
    q.push(s);
    queued[s] = true;
    while (!q.empty()) {
        int u = q.front();
        q.pop();
        queued[u] = false;
        for (auto [v, w] : adj[u]) {
            if (d[v] <= d[u] + w) continue;
            d[v] = d[u] + w;
            length[v] = length[u] + 1;
            if (length[v] >= n) return {};
            if (!queued[v]) {
                q.push(v);
                queued[v] = true;
            }
        }
    }
    return d;
}

// @book-end

// @example-begin
int main() {
    int n, m;
    cin >> n >> m;
    vector<vector<pair<int, i64>>> adj(n);
    for (int i = 0; i < m; ++i) {
        int u, v;
        i64 w;
        cin >> u >> v >> w;
        adj[u - 1].push_back({v - 1, w});
    }
    auto distance = spfa(adj, 0);
    if (distance.empty()) cout << "Negative cycle\n";
    else {
        for (i64 d : distance) {
            if (d != (1LL << 60)) cout << d << '\n';
            else cout << "N\n";
        }
    }
}
// @example-end
