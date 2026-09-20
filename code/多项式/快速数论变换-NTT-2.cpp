#include "../基础算法/快速幂与常用函数.cpp"

// @book-begin
constexpr i64 nttMod = 998244353, nttRoot = 3;
std::vector<i64> mul(std::vector<i64> a, std::vector<i64> b) {  // 复制后补零、原地变换
    if (a.empty() || b.empty()) return {};
    for (auto &x : a) x = (x % nttMod + nttMod) % nttMod;
    for (auto &x : b) x = (x % nttMod + nttMod) % nttMod;
    int M = a.size() + b.size() - 1, N = 1;
    while (N < M) N <<= 1;
    assert(N <= (1 << 23));
    std::vector<int> r(N);
    for (int i = 1; i < N; i++)  // 严格 < N：r[N] 越界
        r[i] = r[i / 2] / 2 | (i % 2 ? N / 2 : 0);

    auto ntt = [&](std::vector<i64> &a, bool inv) -> void {
        a.resize(N);
        for (int i = 0; i < N; i++) {
            if (i < r[i]) std::swap(a[i], a[r[i]]);
        }
        i64 root = inv ? nttRoot : mypow(nttRoot, nttMod - 2, nttMod);
        for (int sz = 1; sz < N; sz <<= 1) {
            i64 wm = mypow(root, (nttMod - 1) / sz / 2, nttMod);
            for (int i = 0; i < N; i += sz * 2) {
                for (int k = 0, w = 1; k < sz; ++k, w = w * wm % nttMod) {
                    i64 &x = a[i + k + sz], &y = a[i + k], t = w * x % nttMod;
                    std::tie(x, y) = pair((y + nttMod - t) % nttMod, (y + t) % nttMod);
                }
            }
        }
        if (inv) {
            i64 in = mypow(N, nttMod - 2, nttMod);
            for (int i = 0; i < N; i++) a[i] = a[i] * in % nttMod;
        }
    };

    ntt(a, 0);
    ntt(b, 0);
    for (int i = 0; i < N; i++) a[i] = a[i] * b[i] % nttMod;
    ntt(a, 1);
    a.resize(M);
    return a;
}
// @book-end
