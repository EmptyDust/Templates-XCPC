#include "../contest.hpp"

// @book-begin
mt19937 rnd(chrono::steady_clock::now().time_since_epoch().count());
int r(int a, int b) {
    assert(a <= b);
    return uniform_int_distribution<int>(a, b)(rnd);
}

vector<pair<int, int>> graph(int n, int root = -1, int m = -1) {
    assert(n >= 1 && (root == -1 || (0 <= root && root < n)));
    if (m == -1) m = n - 1;
    i64 maximum = i64(n) * (n - 1) / 2;
    assert(n - 1 <= m && m <= maximum);
    if (root == -1) root = r(0, n - 1);
    vector<pair<int, int>> edges;
    set<pair<int, int>> used;
    for (int i = 1; i < n; ++i) {
        int x = (i + i64(root)) % n + 1;
        int y = (r(0, i - 1) + i64(root)) % n + 1;
        auto edge = pair(min(x, y), max(x, y));
        edges.push_back(edge);
        used.insert(edge);
    }
    if (m > maximum / 2) {  // 稠密图枚举补边，避免拒绝采样接近满图时退化
        vector<pair<int, int>> remaining;
        for (int x = 1; x <= n; ++x) for (int y = x + 1; y <= n; ++y) {
            if (!used.count({x, y})) remaining.emplace_back(x, y);
        }
        shuffle(remaining.begin(), remaining.end(), rnd);
        edges.insert(edges.end(), remaining.begin(), remaining.begin() + (m - edges.size()));
    } else {
        while (edges.size() < m) {
            int x = r(1, n), y = r(1, n);
            if (x == y) continue;
            auto edge = pair(min(x, y), max(x, y));
            if (used.insert(edge).second) edges.push_back(edge);
        }
    }
    shuffle(edges.begin(), edges.end(), rnd);
    return edges;
}
// @book-end
