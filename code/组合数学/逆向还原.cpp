#include <bits/stdc++.h>
using namespace std;
typedef long long i64;
typedef long long ll;
typedef long long LL;
typedef long double ld;
typedef unsigned long long u64;
const int MOD = 998244353;
const int mod = 1000000007;
const int N = 1000005;
const int M = 2000005;
const double eps = 1e-8;
const double PI = acos(-1.0);

int f[M];

// @book-begin
string inv_kangtuo(int ans, int n) { // 原来本节误粘了正向展开
    vector<int> used(n + 1, 0);  // 1..n 是否已用
    string s;
    ans--;  // 转 0-indexed
    for (int i = 0; i < n; i++) {
        int rk = ans / f[n - i - 1]; // 剩余数字中第 rk 小（0-indexed）
        ans %= f[n - i - 1];
        int cnt = 0;
        for (int j = 1; j <= n; j++) {
            if (used[j]) continue;
            if (cnt == rk) {
                used[j] = 1;
                s += char('0' + j);  // n>9 时改成 vector<int>
                break;
            }
            cnt++;
        }
    }
    return s;
}
// @book-end

int main() { return 0; }
