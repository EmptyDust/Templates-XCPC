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
i64 euclidean(i64 a, i64 b, i64 c, i64 n) {
    // sum{0, n}(floor((a * i + b) / c))
    i64 n2 = n * (n + 1) / 2;
    if (a >= c || b >= c)
        return euclidean(a % c, b % c, c, n) + (a / c) * n2 + (b / c) * (n + 1);
    i64 m = (a * n + b) / c;
    if (!m) return 0;
    return m * n - euclidean(c, c - b - 1, a, m - 1);
}

int IOS;

// @book-begin
namespace BSGS {
    i64 a, b, p;
    map<i64, i64> f;
    inline i64 gcd(i64 a, i64 b) { return b > 0 ? gcd(b, a % b) : a; }
    inline i64 ps(i64 n, i64 k, int p) {
        i64 r = 1;
        for (; k; k >>= 1) {
            if (k & 1) r = r * n % p;
            n = n * n % p;
        }
        return r;
    }
    void exgcd(i64 a, i64 b, i64 &x, i64 &y) {
        if (!b) {
            x = 1, y = 0;
        } else {
            exgcd(b, a % b, x, y);
            i64 t = x;
            x = y;
            y = t - a / b * y;
        }
    }
    i64 inv(i64 a, i64 b) {
        i64 x, y;
        exgcd(a, b, x, y);
        return (x % b + b) % b;
    }
    i64 bsgs(i64 a, i64 b, i64 p) {
        f.clear();
        int m = ceil(sqrt(p));
        b %= p;
        for (int i = 1; i <= m; i++) {
            b = b * a % p;
            f[b] = i;
        }
        i64 tmp = ps(a, m, p);
        b = 1;
        for (int i = 1; i <= m; i++) {
            b = b * tmp % p;
            if (f.count(b) > 0) return (i * m - f[b] + p) % p;
        }
        return -1;
    }
    i64 exbsgs(i64 a, i64 b, i64 p) {
        if (b == 1 || p == 1) return 0;
        i64 g = gcd(a, p), k = 0, na = 1;
        while (g > 1) {
            if (b % g != 0) return -1;
            k++;
            b /= g;
            p /= g;
            na = na * (a / g) % p;
            if (na == b) return k;
            g = gcd(a, p);
        }
        i64 f = bsgs(a, b * inv(na, p) % p, p);
        if (f == -1) return -1;
        return f + k;
    }
}  // namespace BSGS

using namespace BSGS;

int main() {
    IOS;
    cin >> p >> a >> b;
    a %= p, b %= p;
    i64 ans = exbsgs(a, b, p);
    if (ans == -1) cout << "no solution\n";
    else cout << ans << "\n";
    return 0;
}
// @book-end
