#include "../contest.hpp"

// @book-begin
int main() {
    int n, W;
    cin >> n >> W;
    vector<i64> dp(W + 1);
    for (int i = 0; i < n; ++i) {
        int w, count;
        i64 value;
        cin >> w >> value >> count;
        assert(w > 0);
        assert(count >= -1);
        if (count == -1) count = 1;
        if (count == 0) {  // 完全背包
            for (int j = w; j <= W; ++j) dp[j] = max(dp[j], dp[j - w] + value);
            continue;
        }
        count = min(count, W / w);
        for (i64 chunk = 1; count > 0; chunk *= 2) {
            int take = min<i64>(chunk, count);
            count -= take;
            int volume = w * take;
            i64 gain = value * take;
            for (int j = W; j >= volume; --j) dp[j] = max(dp[j], dp[j - volume] + gain);
        }
    }
    cout << dp[W] << '\n';
}
// @book-end
