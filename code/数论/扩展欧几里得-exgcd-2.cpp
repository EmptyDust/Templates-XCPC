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
int main() {
    auto calc = [&](int a, int b, int c) {
        // A*x + B*y = C，A、B 可为负
        int u = 1, v = 1;
        if (a < 0) {  // 负数先取绝对值，最后乘回符号
            a = -a;
            u = -1;
        }
        if (b < 0) {
            b = -b;
            v = -1;
        }

        int x, y, d = exgcd(a, b, x, y), ans;
        if (c % d != 0) {  // 无整数解
            cout << -1 << "\n";
            return;
        }
        a /= d, b /= d, c /= d;
        x *= c, y *= c;  // 得到一组可行解

        ans = (x % b + b - 1) % b + 1; // x 的最小正整数解
        auto [A, B] = pair{u * ans, v * (c - ans * a) / b};

        ans = (y % a + a - 1) % a + 1; // y 的最小正整数解
        auto [C, D] = pair{u * (c - ans * b) / a, v * ans};

        int num = (C - A) / b + 1;  // x、y 均为正整数的解组数
    };
}
// @book-end
