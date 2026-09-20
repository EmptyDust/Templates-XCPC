#include "../contest.hpp"

// @book-begin
struct DAG {
    static constexpr i64 inf = 1LL << 60;
    int n;
    vector<vector<pair<int, i64>>> ver;
    vector<int> deg;
    DAG(int n) : n(n), ver(n + 1), deg(n + 1) {}
    void add(int x, int y, i64 w) {
        ver[x].push_back({y, w});
        ++deg[y];
    }
    i64 topsort(int s, int t) const {  // 不可达返回 -inf；要求 n * max|w| < inf
        vector<int> remaining = deg;
        vector<i64> distance(n + 1, -inf);
        queue<int> q;
        for (int i = 1; i <= n; ++i) if (remaining[i] == 0) q.push(i);
        distance[s] = 0;
        int processed = 0;
        while (!q.empty()) {
            int x = q.front();
            q.pop();
            ++processed;
            for (auto [y, w] : ver[x]) {
                if (distance[x] != -inf) distance[y] = max(distance[y], distance[x] + w);
                if (--remaining[y] == 0) q.push(y);
            }
        }
        assert(processed == n);  // 本接口只接收 DAG
        return distance[t];
    }
};

// @book-end

// @example-begin
int main() {
    int n, m;
    cin >> n >> m;
    DAG dag(n);
    for (int i = 0; i < m; ++i) {
        int x, y;
        i64 w;
        cin >> x >> y >> w;
        dag.add(x, y, w);
    }
    int s, t;
    cin >> s >> t;
    auto answer = dag.topsort(s, t);
    if (answer != -DAG::inf) cout << answer << '\n';
    else cout << "N\n";
}
// @example-end
