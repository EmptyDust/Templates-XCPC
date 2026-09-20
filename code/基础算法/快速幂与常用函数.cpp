#include "../contest.hpp"

// @book-begin
using i64 = long long;

int mypow(i64 n, i64 k, int p) {  // k >= 0，p > 0；先归约底数
    assert(k >= 0 && p > 0);
    n %= p;
    if (n < 0) n += p;
    i64 r = 1 % p;
    for (; k; k >>= 1, n = n * n % p) {
        if (k & 1) r = r * n % p;
    }
    return r;
}
i64 mysqrt(i64 n) {  // floor(sqrt(n))，0 <= n <= LLONG_MAX
    assert(n >= 0);
    i64 ans = sqrtl(n);
    while (ans + 1 <= n / (ans + 1)) ++ans;
    while (ans > 0 && ans > n / ans) --ans;
    return ans;
}
i64 mylcm(int x, int y) {  // int 输入的非负最小公倍数，返回 i64
    if (x == 0 || y == 0) return 0;
    i64 a = abs(i64(x)), b = abs(i64(y));
    return a / gcd(a, b) * b;
}
// @book-end
