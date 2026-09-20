#include "../contest.hpp"

// @book-begin
struct MaxCostMatch {
    int n;
    bool ok = false;
    vector<vector<i64>> ver;
    vector<vector<bool>> present;
    vector<int> ansl, ansr;
    MaxCostMatch(int n) : n(n), ver(n + 1, vector<i64>(n + 1)),
        present(n + 1, vector<bool>(n + 1)), ansl(n + 1), ansr(n + 1) {}
    void add(int x, int y, i64 w) {
        if (!present[x][y] || w > ver[x][y]) ver[x][y] = w;
        present[x][y] = true;
    }
    i64 work() {  // n 对 n 的最大权完美匹配；无解时 ok = false，返回值不用
        const i64 inf = 1LL << 60;  // 要求 n * max|w| < inf / 4
        vector<i64> left(n + 1), right(n + 1);
        vector<int> match(n + 1), previous(n + 1);
        ok = false;
        fill(ansl.begin(), ansl.end(), 0);
        fill(ansr.begin(), ansr.end(), 0);
        for (int row = 1; row <= n; ++row) {
            match[0] = row;
            int column = 0;
            vector<i64> slack(n + 1, inf);
            vector<bool> used(n + 1);
            do {
                used[column] = true;
                int x = match[column], next = -1;
                i64 delta = inf;
                for (int y = 1; y <= n; ++y) {
                    if (used[y]) continue;
                    if (present[x][y]) {
                        i64 reduced = -ver[x][y] - left[x] - right[y];
                        if (reduced < slack[y]) {
                            slack[y] = reduced;
                            previous[y] = column;
                        }
                    }
                    if (slack[y] < delta) {
                        delta = slack[y];
                        next = y;
                    }
                }
                if (next == -1) return 0;
                for (int y = 0; y <= n; ++y) {
                    if (used[y]) {
                        left[match[y]] += delta;
                        right[y] -= delta;
                    } else if (slack[y] != inf) {
                        slack[y] -= delta;
                    }
                }
                column = next;
            } while (match[column] != 0);
            do {
                int next = previous[column];
                match[column] = match[next];
                column = next;
            } while (column != 0);
        }
        i64 answer = 0;
        for (int y = 1; y <= n; ++y) {
            ansr[y] = match[y];
            ansl[match[y]] = y;
            answer += ver[match[y]][y];
        }
        ok = true;
        return answer;
    }
};

// @book-end

// @example-begin
int main() {  // 覆盖全部左侧点；右侧可多于左侧，用零权虚点补齐
    int n1, n2, m;
    cin >> n1 >> n2 >> m;
    MaxCostMatch match(max(n1, n2));
    for (int i = 0; i < m; ++i) {
        int x, y;
        i64 w;
        cin >> x >> y >> w;
        match.add(x, y, w);
    }
    for (int x = n1 + 1; x <= n2; ++x) {
        for (int y = 1; y <= n2; ++y) match.add(x, y, 0);
    }
    auto answer = match.work();
    if (!match.ok) cout << "No Solution\n";
    else {
        cout << answer << '\n';
        for (int x = 1; x <= n1; ++x) cout << match.ansl[x] << ' ';
        cout << '\n';
        for (int y = 1; y <= n2; ++y) {
            cout << (match.ansr[y] <= n1 ? match.ansr[y] : 0) << ' ';
        }
        cout << '\n';
    }
}
// @example-end
