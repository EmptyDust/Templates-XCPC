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
int main() {
    vector<int> prime;  // 这里储存筛出来的全部质数
    auto euler_Prime = [&](int n) -> void {
        vector<int> v(n + 1);
        for (int i = 2; i <= n; ++i) {
            if (!v[i]) {
                v[i] = i;
                prime.push_back(i);
            }
            for (int j = 0; j < prime.size(); ++j) {
                if (prime[j] > v[i] || prime[j] > n / i) break;
                v[i * prime[j]] = prime[j];
            }
        }
        // 筛完后 v[x] = x 的最小质因子（x 为质数时 v[x] = x）
    };
}
// @book-end
