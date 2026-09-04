#import "../prelude.typ": *

= 多项式
<多项式>
默认模数 $998244353$（NTT 模，原根 $3$）。`Poly` / `dft` 依赖 mint（`MInt` / `Z`，见杂项取模类）。`i64` 为 `long long`。

== 线性凸包
<线性凸包>
斜率优化 / 下凸壳维护直线 $y = a x + b$，查询 $"min"_i a x + b$。构造时按斜率排序并弹出不优直线；`min(x)` 二分交点。`i64`，除法向 $- oo$ 取整。不是几何凸包。

#include-code("code/多项式/线性凸包.cpp")

== 多项式封装
<多项式封装>
依赖本节后面的 `dft` / `idft` 与 mint `MInt<P>`。默认模 $998244353$。乘法长度够大时走 NTT，否则 $O (n^2)$。`inv/log/exp/sqrt` 的 `m` 是要的前 $m$ 项。`eval` 是多点求值。

```cpp
template<int P = 998244353> struct Poly : public vector<MInt<P>> {
    using Value = MInt<P>;

    Poly() : vector<Value>() {}
    explicit constexpr Poly(int n) : vector<Value>(n) {}

    explicit constexpr Poly(const vector<Value> &a) : vector<Value>(a) {}
    constexpr Poly(const initializer_list<Value> &a) : vector<Value>(a) {}

    template<typename InputIt, typename = _RequireInputIter<InputIt>>
    explicit constexpr Poly(InputIt first, InputIt last) : vector<Value>(first, last) {}

    template<typename F>
    explicit constexpr Poly(int n, F f) : vector<Value>(n) {  // 原来写成 F>plicit，无法编译
        for (int i = 0; i < n; i++) {
            (*this)[i] = f(i);
        }
    }

    constexpr Poly shift(int k) const {
        if (k >= 0) {
            auto b = *this;
            b.insert(b.begin(), k, 0);
            return b;
        } else if (this->size() <= -k) {
            return Poly();
        } else {
            return Poly(this->begin() + (-k), this->end());
        }
    }
    constexpr Poly trunc(int k) const {
        Poly f = *this;
        f.resize(k);
        return f;
    }
    constexpr friend Poly operator+(const Poly &a, const Poly &b) {
        Poly res(max(a.size(), b.size()));
        for (int i = 0; i < a.size(); i++) {
            res[i] += a[i];
        }
        for (int i = 0; i < b.size(); i++) {
            res[i] += b[i];
        }
        return res;
    }
    constexpr friend Poly operator-(const Poly &a, const Poly &b) {
        Poly res(max(a.size(), b.size()));
        for (int i = 0; i < a.size(); i++) {
            res[i] += a[i];
        }
        for (int i = 0; i < b.size(); i++) {
            res[i] -= b[i];
        }
        return res;
    }
    constexpr friend Poly operator-(const Poly &a) {
        vector<Value> res(a.size());
        for (int i = 0; i < int(res.size()); i++) {
            res[i] = -a[i];
        }
        return Poly(res);
    }
    constexpr friend Poly operator*(Poly a, Poly b) {
        if (a.size() == 0 || b.size() == 0) {
            return Poly();
        }
        if (a.size() < b.size()) {
            swap(a, b);
        }
        int n = 1, tot = a.size() + b.size() - 1;
        while (n < tot) {
            n *= 2;
        }
        if (((P - 1) & (n - 1)) != 0 || b.size() < 128) {
            Poly c(a.size() + b.size() - 1);
            for (int i = 0; i < a.size(); i++) {
                for (int j = 0; j < b.size(); j++) {
                    c[i + j] += a[i] * b[j];
                }
            }
            return c;
        }
        a.resize(n);
        b.resize(n);
        dft(a);
        dft(b);
        for (int i = 0; i < n; ++i) {
            a[i] *= b[i];
        }
        idft(a);
        a.resize(tot);
        return a;
    }
    constexpr friend Poly operator*(Value a, Poly b) {
        for (int i = 0; i < int(b.size()); i++) {
            b[i] *= a;
        }
        return b;
    }
    constexpr friend Poly operator*(Poly a, Value b) {
        for (int i = 0; i < int(a.size()); i++) {
            a[i] *= b;
        }
        return a;
    }
    constexpr friend Poly operator/(Poly a, Value b) {
        for (int i = 0; i < int(a.size()); i++) {
            a[i] /= b;
        }
        return a;
    }
    constexpr Poly &operator+=(Poly b) {
        return (*this) = (*this) + b;
    }
    constexpr Poly &operator-=(Poly b) {
        return (*this) = (*this) - b;
    }
    constexpr Poly &operator*=(Poly b) {
        return (*this) = (*this) * b;
    }
    constexpr Poly &operator*=(Value b) {
        return (*this) = (*this) * b;
    }
    constexpr Poly &operator/=(Value b) {
        return (*this) = (*this) / b;
    }
    constexpr Poly deriv() const {
        if (this->empty()) {
            return Poly();
        }
        Poly res(this->size() - 1);
        for (int i = 0; i < this->size() - 1; ++i) {
            res[i] = (i + 1) * (*this)[i + 1];
        }
        return res;
    }
    constexpr Poly integr() const {
        Poly res(this->size() + 1);
        for (int i = 0; i < this->size(); ++i) {
            res[i + 1] = (*this)[i] / (i + 1);
        }
        return res;
    }
    constexpr Poly inv(int m) const {
        Poly x{(*this)[0].inv()};
        int k = 1;
        while (k < m) {
            k *= 2;
            x = (x * (Poly{2} - trunc(k) * x)).trunc(k);
        }
        return x.trunc(m);
    }
    constexpr Poly log(int m) const {
        return (deriv() * inv(m)).integr().trunc(m);
    }
    constexpr Poly exp(int m) const {
        Poly x{1};
        int k = 1;
        while (k < m) {
            k *= 2;
            x = (x * (Poly{1} - x.log(k) + trunc(k))).trunc(k);
        }
        return x.trunc(m);
    }
    constexpr Poly pow(int k, int m) const {
        int i = 0;
        while (i < this->size() && (*this)[i] == 0) {
            i++;
        }
        if (i == this->size() || 1LL * i * k >= m) {
            return Poly(m);
        }
        Value v = (*this)[i];
        auto f = shift(-i) * v.inv();
        return (f.log(m - i * k) * k).exp(m - i * k).shift(i * k) * power(v, k);
    }
    constexpr Poly sqrt(int m) const {
        Poly x{1};
        int k = 1;
        while (k < m) {
            k *= 2;
            x = (x + (trunc(k) * x.inv(k)).trunc(k)) * CInv<2, P>;
        }
        return x.trunc(m);
    }
    constexpr Poly mulT(Poly b) const {
        if (b.size() == 0) {
            return Poly();
        }
        int n = b.size();
        reverse(b.begin(), b.end());
        return ((*this) * b).shift(-(n - 1));
    }
    constexpr vector<Value> eval(vector<Value> x) const {
        if (this->size() == 0) {
            return vector<Value>(x.size(), 0);
        }
        const int n = max(x.size(), this->size());
        vector<Poly> q(4 * n);
        vector<Value> ans(x.size());
        x.resize(n);
        function<void(int, int, int)> build = [&](int p, int l, int r) {
            if (r - l == 1) {
                q[p] = Poly{1, -x[l]};
            } else {
                int m = (l + r) / 2;
                build(2 * p, l, m);
                build(2 * p + 1, m, r);
                q[p] = q[2 * p] * q[2 * p + 1];
            }
        };
        build(1, 0, n);
        function<void(int, int, int, const Poly &)> work = [&](int p, int l, int r,
                                                                    const Poly &num) {
            if (r - l == 1) {
                if (l < int(ans.size())) {
                    ans[l] = num[0];
                }
            } else {
                int m = (l + r) / 2;
                work(2 * p, l, m, num.mulT(q[2 * p + 1]).resize(m - l));
                work(2 * p + 1, m, r, num.mulT(q[2 * p]).resize(r - m));
            }
        };
        work(1, 0, n, mulT(q[1].inv(n)));
        return ans;
    }
};
```

== 离散傅里叶变换 dft 与其逆变换 idft
<离散傅里叶变换-dft-与其逆变换-idft>
点值与系数互换：单位根上求值。卷积变成点值相乘再变回。长度必须是 $2$ 的幂。`idft` 里 `(1-P)/n` 在模 $P$ 下等于 $n^(- 1)$。`rev` / `roots` 是全局表，多模数同时用会串。

```cpp
vector<int> rev;
template<int P> vector<MInt<P>> roots{0, 1};

template<int P> constexpr MInt<P> findPrimitiveRoot() {
    MInt<P> i = 2;
    int k = __builtin_ctz(P - 1);
    while (true) {
        if (power(i, (P - 1) / 2) != 1) {
            break;
        }
        i += 1;
    }
    return power(i, (P - 1) >> k);
}

template<int P> constexpr MInt<P> primitiveRoot = findPrimitiveRoot<P>();
template<> constexpr MInt<998244353> primitiveRoot<998244353>{31};

template<int P> constexpr void dft(vector<MInt<P>> &a) {  // 离散傅里叶变换
    int n = a.size();

    if (int(rev.size()) != n) {
        int k = __builtin_ctz(n) - 1;
        rev.resize(n);
        for (int i = 0; i < n; i++) {
            rev[i] = rev[i >> 1] >> 1 | (i & 1) << k;
        }
    }

    for (int i = 0; i < n; i++) {
        if (rev[i] < i) {
            swap(a[i], a[rev[i]]);
        }
    }
    if (roots<P>.size() < n) {
        int k = __builtin_ctz(roots<P>.size());
        roots<P>.resize(n);
        while ((1 << k) < n) {
            auto e = power(primitiveRoot<P>, 1 << (__builtin_ctz(P - 1) - k - 1));
            for (int i = 1 << (k - 1); i < (1 << k); i++) {
                roots<P>[2 * i] = roots<P>[i];
                roots<P>[2 * i + 1] = roots<P>[i] * e;
            }
            k++;
        }
    }
    for (int k = 1; k < n; k *= 2) {
        for (int i = 0; i < n; i += 2 * k) {
            for (int j = 0; j < k; j++) {
                MInt<P> u = a[i + j];
                MInt<P> v = a[i + j + k] * roots<P>[k + j];
                a[i + j] = u + v;
                a[i + j + k] = u - v;
            }
        }
    }
}
template<int P> constexpr void idft(vector<MInt<P>> &a) {  // 逆变换
    int n = a.size();
    reverse(a.begin() + 1, a.end());
    dft(a);
    MInt<P> inv = (1 - P) / n;
    for (int i = 0; i < n; i++) {
        a[i] *= inv;
    }
}
```

== Berlekamp-Massey 算法
<berlekamp-massey-算法>
求解数列的最短线性递推式（#strong[不是];杜教筛）。返回多项式 $c$，满足递推；最坏 $cal(O)(N M)$，$N$ 为数列长度，$M$ 为最短递推阶数。

```cpp
template<int P = 998244353> Poly<P> berlekampMassey(const Poly<P> &s) {
    Poly<P> c;
    Poly<P> oldC;
    int f = -1;
    for (int i = 0; i < s.size(); i++) {
        auto delta = s[i];
        for (int j = 1; j <= c.size(); j++) {
            delta -= c[j - 1] * s[i - j];
        }
        if (delta == 0) {
            continue;
        }
        if (f == -1) {
            c.resize(i + 1);
            f = i;
        } else {
            auto d = oldC;
            d *= -1;
            d.insert(d.begin(), 1);
            MInt<P> df1 = 0;
            for (int j = 1; j <= d.size(); j++) {
                df1 += d[j - 1] * s[f + 1 - j];
            }
            assert(df1 != 0);
            auto coef = delta / df1;
            d *= coef;
            Poly<P> zeros(i - f - 1);
            zeros.insert(zeros.end(), d.begin(), d.end());
            d = zeros;
            auto temp = c;
            c += d;
            if (i - temp.size() > f - oldC.size()) {
                oldC = temp;
                f = i;
            }
        }
    }
    c *= -1;
    c.insert(c.begin(), 1);
    return c;
}
```

== Linear-Recurrence 算法
<linear-recurrence-算法>
已知线性递推，求第 $n$ 项（$0$-index）。`q` 为特征多项式，$p$ 由初值决定。Bostan-Mori，$cal(O)(M^2 "log" n)$ 或配 NTT 更快。$n$ 用 `i64`。

```cpp
template<int P = 998244353> MInt<P> linearRecurrence(Poly<P> p, Poly<P> q, i64 n) {
    int m = q.size() - 1;
    while (n > 0) {
        auto newq = q;
        for (int i = 1; i <= m; i += 2) {
            newq[i] *= -1;
        }
        auto newp = p * newq;
        newq = q * newq;
        for (int i = 0; i < m; i++) {
            p[i] = newp[i * 2 + n % 2];
        }
        for (int i = 0; i <= m; i++) {
            q[i] = newq[i * 2];
        }
        n /= 2;
    }
    return p[0] / q[0];
}
```

== 快速傅里叶变换 FFT
<快速傅里叶变换-fft>
使用说明： 1.创建一个实例 `FFT_mul solver`

2.准备输入数据

将两个多项式 $A (x)$ 和 $B (x)$ 的系数（必须是实数）按升幂顺序转化为 `std::complex<double>` 类型，并推入 `solver.A` 和 `solver.B`。

3.调用 `count(x, y)` 函数执行卷积操作

4.系数序列存储在 `solver.ret` 向量中

$cal(O)(N "log" N)$ 。

#include-code("code/多项式/快速傅里叶变换-FFT.cpp")

#strong[系数顺序:] 输入系数必须严格按照#strong[升幂顺序];（从 $x^0$ 到 $x^(upright("max_deg"))$）。

#strong[输入参数:] `count(x, y)` 传入的参数是多项式的#strong[最高次数];，而不是系数的数量。

#strong[精度与范围:]

- `i64` 用于存储最终结果，请确保中间结果（系数乘积之和）不超过 `i64` 的表示范围，否则仍可能溢出。
- 由于浮点误差，结果在 IFFT 后通过 `llround(fa[i].real())` 四舍五入到最近的整数。如果系数非常大，可能存在累积误差。

#strong[零填充 \(Padding):] 模板内部会自动处理零填充，将长度扩展到大于 $x + y$ 的最小二次幂 $N$。

== 快速数论变换 NTT
<快速数论变换-ntt>
模意义卷积，$cal(O)(N "log" N)$。模数须为 NTT 模（$998244353$ 原根 $3$）。长度补到 $2$ 的幂。下面第一段构造时就做了 DFT，只是变换器；第二段 `mul` 才是完整乘法。

$cal(O)(N "log" N)$ 。

```cpp
struct Polynomial {
    vector<Z> z;
    vector<int> r;
    Polynomial(vector<int> &a) {
        int n = a.size();
        z.resize(n);
        r.resize(n);
        for (int i = 0; i < n; i++) {
            z[i] = a[i];
            r[i] = (i & 1) * (n / 2) + r[i / 2] / 2;
        }
        ntt(z, n, 1);
    }
    LL power(LL a, int b) {
        LL res = 1;
        for (; b; b /= 2, a = a * a % mod) {
            if (b % 2) {
                res = res * a % mod;
            }
        }
        return res;
    }
    void ntt(vector<Z> &a, int n, int opt) {
        for (int i = 0; i < n; i++) {
            if (r[i] < i) {
                swap(a[i], a[r[i]]);
            }
        }
        for (int k = 2; k <= n; k *= 2) {
            Z gn = power(3, (mod - 1) / k);
            for (int i = 0; i < n; i += k) {
                Z g = 1;
                for (int j = 0; j < k / 2; j++, g *= gn) {
                    Z t = a[i + j + k / 2] * g;
                    a[i + j + k / 2] = a[i + j] - t;
                    a[i + j] = a[i + j] + t;
                }
            }
        }
        if (opt == -1) {
            reverse(a.begin() + 1, a.end());
            Z inv = power(n, mod - 2);
            for (int i = 0; i < n; i++) {
                a[i] *= inv;
            }
        }
    }
};
```

需要注意的是，最后答案要除以做 DFT/IDFT 的长度，而且做 DFT/IDFT 的长度要一样且是 2 的整数次幂。还有就是做高精度乘法的时候要记得把数组反向。如果 TLE 了可以考虑一些常数优化。

#include-code("code/多项式/快速数论变换-NTT-2.cpp")

== 拉格朗日插值
<拉格朗日插值>
$n + 1$ 个点唯一确定最高 $n$ 次多项式。普通情况：$f (k) = sum_(i = 1)^(n + 1) y_i product_(i eq.not j) frac(k - x [j], x [i] - x [j])$ 。下面这块是连续点 $1 dots.c n + 2$ 上对 $i^n$ 前缀和插值（自然数方幂和），不是任意点；依赖 `Z`。

$n + 1$ 个点可以唯一确定一个最高为 $n$ 次的多项式。普通情况：$f (k) = sum_(i = 1)^(n + 1) y_i product_(i eq.not j) frac(k - x [j], x [i] - x [j])$ 。

```cpp
struct Lagrange {
    int n;
    vector<Z> x, y, fac, invfac;
    Lagrange(int n) {
        this->n = n;
        x.resize(n + 3);
        y.resize(n + 3);
        fac.resize(n + 3);
        invfac.resize(n + 3);
        init(n);
    }
    void init(int n) {
        iota(x.begin(), x.end(), 0);
        for (int i = 1; i <= n + 2; i++) {
            y[i] = y[i - 1] + mypow(Z(i), n);  // 原来 Z t 未赋值再 t.power(i,n)
        }
        fac[0] = 1;
        for (int i = 1; i <= n + 2; i++) {
            fac[i] = fac[i - 1] * i;
        }
        invfac[n + 2] = fac[n + 2].inv();
        for (int i = n + 1; i >= 0; i--) {
            invfac[i] = invfac[i + 1] * (i + 1);
        }
    }
    Z solve(LL k) {
        if (k <= n + 2) {
            return y[k];
        }
        vector<Z> sub(n + 3);
        for (int i = 1; i <= n + 2; i++) {
            sub[i] = k - x[i];
        }
        vector<Z> mul(n + 3);
        mul[0] = 1;
        for (int i = 1; i <= n + 2; i++) {
            mul[i] = mul[i - 1] * sub[i];
        }
        Z ans = 0;
        for (int i = 1; i <= n + 2; i++) {
            ans = ans + y[i] * mul[n + 2] * sub[i].inv() * pow(-1, n + 2 - i) * invfac[i - 1] *
                            invfac[n + 2 - i];
        }
        return ans;
    }
};
```

== 结论 from LuanXR
<结论-from-luanxr>
生成函数速查。泰勒与广义二项式用来展开、对拍系数。

+ 序列 $a$ 的#strong[普通生成函数];: $F (x) = sum a_n x^n$
+ 序列 $a$ 的#strong[指数生成函数];: $F (x) = sum a_n frac(x^n, n !)$

泰勒展开式

+ $frac(1, 1 - x) = 1 + x + x^2 + x^3 + dots.h = sum_(n = 0)^oo x^n$
+ $frac(1, 1 - x^2) = 1 + x^2 + x^4 + dots.h.c$
+ $frac(1, 1 - x^3) = 1 + x^3 + x^6 + dots.h.c$
+ $1 / (1 - x)^2 = 1 + 2 x + 3 x^2 + dots.h.c$
+ $e^x = 1 + frac(x^1, 1 !) + frac(x^2, 2 !) + frac(x^3, 3 !) + dots.h.c = sum_(n = 0)^oo frac(x^n, n !)$
+ $e^(- x) = 1 - frac(x^1, 1 !) + frac(x^2, 2 !) - frac(x^3, 3 !) + dots.h.c$
+ $frac(e^x + e^(- x), 2) = 1 + frac(x^2, 2 !) + frac(x^4, 4 !) + dots.h.c$
+ $frac(e^x - e^(- x), 2) = x + frac(x^3, 3 !) + frac(x^5, 5 !) + dots.h.c$

有穷序列的生成函数

+ $1 + x + x^2 = frac(1 - x^3, 1 - x)$
+ $1 + x + x^2 + x^3 = frac(1 - x^4, 1 - x)$

广义二项式定理 $ 1 / (1 - x)^n = sum_(i = 0)^oo binom(n + i - 1, i) x^i $

证明

+ 扩展域 $(1 + x)^n = sum_(i = 0)^n binom(n, i) x^i$，因 $i > n , binom(n, i) = 0$。

+ 扩展指数为负数 $binom(- n, i) = frac((- n) (- n - 1) dots.h.c (- n - i + 1), i !) = (- 1)^i times frac(n (n + 1) dots.h.c (n + i - 1), i !) = (- 1)^i binom(n + i - 1, i)$

+ 括号内的加号变减号 $(1 - x)^(- n) = sum_(i = 0)^oo (- 1)^i binom(n + i - 1, i) (- x)^i = sum_(i = 0)^oo binom(n + i - 1, i) x^i$

== 常用结论
<常用结论>
生成函数与单位根的速查。OGF 管组合计数，EGF 管有标号；卷积对应乘法。用前对一下下标从 $0$ 还是 $1$。

=== 杂
<杂>
- 求 $B_i = sum_(k = i)^n C_k^i A_k$，即 $B_i = frac(1, i !) sum_(k = i)^n frac(1, (k - i) !) dot.op k ! A_k$，反转后卷积。
- NTT 中，$omega_n =$ `qpow(G,(mod-1)/n))`。
- 遇到 $sum_(i = 0)^n [i % k = 0] f (i)$ 可以转换为 $sum_(i = 0)^n 1 / k sum_(j = 0)^(k - 1) (omega_k^i)^j f (i)$ 。（单位根卷积）
- 广义二项式定理 $(1 + x)^alpha = sum_(i = 0)^oo binom(alpha, i) x^i$ 。

=== 普通生成函数 / OGF
<普通生成函数-ogf>
- 普通生成函数：$A (x) = a_0 + a_1 x + a_2 x^2 + dots.c = chevron.l a_0 , a_1 , a_2 , dots.c chevron.r$ ；
- $1 + x^k + x^(2 k) + dots.c = frac(1, 1 - x^k)$ ；
- 取对数后 $= - "ln" (1 - x^k) = sum_(i = 1)^oo 1 / i x^(k i)$ 即 $sum_(i = 1)^oo 1 / i x^i ⊙ x^k$（polymul\_special）；
- $x + x^2 / 2 + x^3 / 3 + dots.c = - "ln" (1 - x)$ ；
- $1 + x + x^2 + dots.c + x^(m - 1) = frac(1 - x^m, 1 - x)$ ；
- $1 + 2 x + 3 x^2 + dots.c = 1 / (1 - x)^2$（借用导数，$n x^(n - 1) = (x^n) prime$）；
- $C_m^0 + C_m^1 x + C_m^2 x^2 + dots.c + C_m^m x^m = (1 + x)^m$（二项式定理）；
- $C_m^0 + C_(m + 1)^1 x^1 + C_(m + 2)^2 x^2 + dots.c = 1 / (1 - x)^(m + 1)$（归纳法证明）；
- $sum_(n = 0)^oo F_n x^n = frac((F_1 - F_0) x + F_0, 1 - x - x^2)$（F 为斐波那契数列，列方程 $G (x) = x G (x) + x^2 G (x) + (F_1 - F_0) x + F_0$）；
- $sum_(n = 0)^oo H_n x^n = frac(1 - sqrt(1 - 4 x), 2 x)$（H 为卡特兰数；原来写成 $sqrt(n - 4 x)$）；
- 前缀和 $sum_(n = 0)^oo s_n x^n = frac(1, 1 - x) f (x)$ ；
- 五边形数定理：$product_(i = 1)^oo (1 - x^i) = sum_(k = 0)^oo (- 1)^k x^(1 / 2 k (3 k plus.minus 1))$ 。

=== 指数生成函数 / EGF
<指数生成函数-egf>
- 指数生成函数：$A (x) = a_0 + a_1 x + a_2 frac(x^2, 2 !) + a_3 frac(x^3, 3 !) + dots.c = chevron.l a_0 , a_1 , a_2 , a_3 , dots.c chevron.r$ ；
- 普通生成函数转换为指数生成函数：系数乘以 $n !$ ；
- $1 + x + frac(x^2, 2 !) + frac(x^3, 3 !) + dots.c = "exp" x$ ；
- 长度为 $n$ 的循环置换数为 $P (x) = - "ln" (1 - x)$，长度为 n 的置换数为 $"exp" P (x) = frac(1, 1 - x)$（注意是#strong[指数];生成函数）
  - $n$ 个点的生成树个数是 $P (x) = sum_(n = 1)^oo n^(n - 2) frac(x^n, n !)$，n 个点的生成森林个数是 $"exp" P (x)$ ；
  - $n$ 个点的无向连通图个数是 $P (x)$，n 个点的无向图个数是 $"exp" P (x) = sum_(n = 0)^oo 2^(1 / 2 n (n - 1)) frac(x^n, n !)$ ；
  - 长度为 $n (n gt.eq 2)$ 的循环置换数是 $P (x) = - "ln" (1 - x) - x$，长度为 n 的错排数是 $"exp" P (x)$ 。
