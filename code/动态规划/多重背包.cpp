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


// @book-begin
int n, W;  // 物品种数、容量
int s[M], w[M], v[M], dp[M];  // 数量、体积、价值；M 见 contest.hpp

int main() {
    for (int i = 1; i <= n; i++)
        for (int j = W; j >= 0; j--)
            for (int k = 0; k <= s[i]; k++){
                if (j - k * w[i] < 0) break;
                dp[j] = max(dp[j], dp[j - k * w[i]] + k * v[i]);
            }
}
// @book-end
