#include "../contest.hpp"
int n, m;

// @book-begin
int mypow10(int n, const vector<int> &k, int p) {
    assert(p > 0);
    int r = 1 % p;
    for (int i = k.size() - 1; i >= 0; i--) {
        for (int j = 1; j <= k[i]; j++) {
            r = i64(r) * n % p;
        }
        int v = 1;
        for (int j = 0; j <= 9; j++) {
            v = i64(v) * n % p;
        }
        n = v;
    }
    return r;
}
signed main() {
    string n_, k_;
    int p;
    cin >> n_ >> k_ >> p;

    int n = 0;  // 转化并计算 n % p
    for (auto it : n_) {
        n = (i64(n) * 10 + it - '0') % p;
    }
    vector<int> k;  // 转化 k
    for (auto it : k_) {
        k.push_back(it - '0');
    }
    cout << mypow10(n, k, p) << endl;  // 暴力快速幂
}
// @book-end
