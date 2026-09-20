#include "../contest.hpp"

// @book-begin
array<int, 3> tournamentTriangle(const vector<vector<int>> &a) {
    // 0-index 竞赛图；返回依次相连的三个顶点，无环返回 {-1, -1, -1}。
    int n = a.size();
    vector<bool> vis(n);
    array<int, 3> answer{-1, -1, -1};
    auto dfs = [&](auto &&self, int x, int parent) -> bool {
        vis[x] = true;
        for (int y = 0; y < n; ++y) {
            if (!a[x][y]) continue;
            if (parent != -1 && a[y][parent]) {
                answer = {parent, x, y};
                return true;
            }
            if (!vis[y] && self(self, y, x)) return true;
        }
        return false;
    };
    for (int x = 0; x < n; ++x) {
        if (!vis[x] && dfs(dfs, x, -1)) break;
    }
    return answer;
}
// @book-end

// @example-begin
int main() {
    int n;
    cin >> n;
    vector a(n, vector<int>(n));
    for (int x = 0; x < n; ++x) {
        for (int y = 0; y < n; ++y) {
            char bit;
            cin >> bit;
            a[x][y] = bit - '0';
        }
    }
    auto [x, y, z] = tournamentTriangle(a);
    if (x == -1) cout << -1 << '\n';
    else cout << x + 1 << ' ' << y + 1 << ' ' << z + 1 << '\n';
}
// @example-end
