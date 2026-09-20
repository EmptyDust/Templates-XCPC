#include "Miller---Rabin-素数测试.cpp"

// @book-begin
i64 PR(i64 n) {  // n 为合数；依赖上一节的 mul
    for (int p : {2, 3, 5, 7, 11, 13}) {
        if (n % p == 0) return p;
    }
    static mt19937_64 rng(chrono::steady_clock::now().time_since_epoch().count());
    for (;;) {
        i64 c = 1 + rng() % (n - 1);
        i64 y = 1 + rng() % (n - 1), x = 0, saved = 0, g = 1;
        auto step = [&](i64 v) -> i64 {
            return (i128(mul(v, v, n)) + c) % n;
        };
        for (i64 length = 1; g == 1; length *= 2) {
            x = y;
            for (i64 i = 0; i < length; ++i) y = step(y);
            for (i64 k = 0; k < length && g == 1; k += 128) {
                saved = y;
                i64 product = 1;
                for (i64 i = 0; i < min(128LL, length - k); ++i) {
                    y = step(y);
                    product = mul(product, abs(x - y), n);
                }
                g = gcd(product, n);
            }
        }
        if (g == n) {
            do {
                saved = step(saved);
                g = gcd(abs(x - saved), n);
            } while (g == 1);
        }
        if (g != n) return g;
    }
}
vector<i64> fac(i64 n) {  // n >= 1；质因子按非降序返回，保留重数
    assert(n >= 1);
    if (n == 1) return {};
    if (MR(n)) return {n};
    i64 d = PR(n);
    auto result = fac(d), other = fac(n / d);
    result.insert(result.end(), other.begin(), other.end());
    sort(result.begin(), result.end());
    return result;
}
// @book-end
