#include "../contest.hpp"

// @book-begin
vector<i64> dijkstra(const vector<vector<pair<int, i64>>> &adj, int s) {
    // 0-index，边权非负；有限最短距离须小于 LLONG_MAX，用它表示不可达。
    int n = adj.size();
    const i64 inf = LLONG_MAX;
    vector<i64> distance(n, inf);
    using Entry = pair<i64, int>;
    priority_queue<Entry, vector<Entry>, greater<Entry>> q;
    distance[s] = 0;
    q.push({0, s});
    while (!q.empty()) {
        auto [d, u] = q.top();
        q.pop();
        if (d != distance[u]) continue;
        for (auto [v, w] : adj[u]) {
            assert(w >= 0);
            if (w >= inf - d) continue;
            i64 next = d + w;
            if (next < distance[v]) {
                distance[v] = next;
                q.push({distance[v], v});
            }
        }
    }
    return distance;
}

// @book-end

// @example-begin
int main() {
    int n, m, s;
    cin >> n >> m >> s;
    vector<vector<pair<int, i64>>> adj(n);
    for (int i = 0; i < m; ++i) {
        int u, v;
        i64 w;
        cin >> u >> v >> w;
        adj[u - 1].push_back({v - 1, w});
    }
    for (i64 distance : dijkstra(adj, s - 1)) {
        if (distance != LLONG_MAX) cout << distance << '\n';
        else cout << "N\n";
    }
}
// @example-end
