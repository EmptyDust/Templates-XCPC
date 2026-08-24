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

std::vector<int> minp, primes;

void sieve(int n) {
    minp.assign(n + 1, 0);
    primes.clear();

    for (int i = 2; i <= n; i++) {
        if (minp[i] == 0) {
            minp[i] = i;
            primes.push_back(i);
        }

        for (auto p : primes) {
            if (i * p > n) {
                break;
            }
            minp[i * p] = p;
            if (p == minp[i]) {
                break;
            }
        }
    }
}
int exgcd(int a, int b, int &x, int &y) {
    if (!b) {
        x = 1, y = 0;
        return a;
    }
    int d = exgcd(b, a % b, y, x);
    y -= a / b * x;
    return d;
}

// @book-begin
i64 euclidean(i64 a, i64 b, i64 c, i64 n) {
    // sum{0, n}(floor((a * i + b) / c))
    i64 n2 = n * (n + 1) / 2;
    if (a >= c || b >= c)
        return euclidean(a % c, b % c, c, n) + (a / c) * n2 + (b / c) * (n + 1);
    i64 m = (a * n + b) / c;
    if (!m) return 0;
    return m * n - euclidean(c, c - b - 1, a, m - 1);
}
// @book-end

int main() { return 0; }
