#include "../contest.hpp"

// @book-begin
using i128 = __int128;

i64 mul(i64 a, i64 b, i64 m) {  // 0 <= a,b < m <= LLONG_MAX
    return i128(a) * b % m;
}
i64 powMod(i64 a, i64 b, i64 m) {
    i64 result = 1 % m;
    for (a %= m; b; b >>= 1, a = mul(a, a, m)) {
        if (b & 1) result = mul(result, a, m);
    }
    return result;
}
bool MR(i64 n) {  // 确定性判素，支持整个非负 i64 值域
    if (n < 2) return false;
    for (int p : {2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37}) {
        if (n % p == 0) return n == p;
    }
    i64 d = n - 1;
    int s = 0;
    while (d % 2 == 0) {
        d /= 2;
        ++s;
    }
    for (i64 a : {2LL, 325LL, 9375LL, 28178LL, 450775LL, 9780504LL, 1795265022LL}) {
        if (a % n == 0) continue;
        i64 x = powMod(a, d, n);
        if (x == 1 || x == n - 1) continue;
        bool passed = false;
        for (int j = 1; j < s; ++j) {
            x = mul(x, x, n);
            if (x == n - 1) {
                passed = true;
                break;
            }
        }
        if (!passed) return false;
    }
    return true;
}
// @book-end
