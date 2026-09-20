#include "../contest.hpp"

// @book-begin
bool hasNegativeCycle(const vector<vector<pair<int, i64>>> &adj) {
    // 0-index；全点入队，等价于从额外超级源连零权边。要求 n * max|w| < 2^60。
    int n = adj.size();
    vector<i64> d(n);
    vector<int> length(n);
    vector<bool> queued(n, true);
    queue<int> q;
    for (int v = 0; v < n; ++v) q.push(v);
    while (!q.empty()) {
        int u = q.front();
        q.pop();
        queued[u] = false;
        for (auto [v, w] : adj[u]) {
            if (d[v] <= d[u] + w) continue;
            d[v] = d[u] + w;
            length[v] = length[u] + 1;
            if (length[v] >= n) return true;
            if (!queued[v]) {
                q.push(v);
                queued[v] = true;
            }
        }
    }
    return false;
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
    cout << (hasNegativeCycle(adj) ? "Yes\n" : "No\n");
}
// @example-end
