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
using i64 = long long;

int mypow(i64 n, i64 k, int p) {  // 快速幂，复杂度 O(log k)；参数与累乘器 i64，n*n 不溢出 int
    i64 r = 1;
    for (; k; k >>= 1, n = n * n % p) {
        if (k & 1) r = r * n % p;
    }
    return r;
}
i64 mysqrt(i64 n) {  // 针对 sqrt 无法精确计算 i64 型；n ≤ 1e18 时不溢出
    i64 ans = sqrt(n);
    while ((ans + 1) * (ans + 1) <= n) ans++;
    while (ans * ans > n) ans--;
    return ans;
}
int mylcm(int x, int y) {  // 先除后乘，防溢出
    return x / gcd(x, y) * y;
}
// @book-end

int main() { return 0; }
