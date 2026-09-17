#include "../contest.hpp"
// @book-begin
// 头部即 STL 章首的 contest.hpp（i64 / a2 系 / mod / N 都从那里来），以下只补增量：
#define ranges std::ranges
#define views std::views

using u32 = unsigned;
using pii = std::pair<int, int>;

const int MAXN = 1e6 + 10;  // 按题目改
const int inf = 1e9;

std::mt19937_64 rng(std::chrono::steady_clock::now().time_since_epoch().count());

void solve() {

}

signed main() {
    std::ios::sync_with_stdio(false);
    std::cin.tie(0), std::cout.tie(0);
    int t = 1;  //cin >> t;
    while (t--) {
        solve();
        std::cout << '\n';
    }
    return 0;
}
// @book-end
