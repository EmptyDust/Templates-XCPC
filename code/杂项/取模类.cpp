#include <bits/stdc++.h>
using namespace std;
typedef long long i64;
typedef long long ll;
typedef long long LL;
typedef long double ld;
typedef unsigned long long u64;
const int mod = 1000000007;
const int N = 1000005;
const int M = 2000005;
const double eps = 1e-8;
const double PI = acos(-1.0);

// @book-begin
using i64 = long long;

template<typename T> constexpr T mypow(T n, i64 k) {
    T r = 1;
    for (; k; k /= 2, n *= n) {
        if (k % 2) {
            r *= n;
        }
    }
    return r;
}

template<typename T> constexpr T power(int n) {
    return mypow(T(2), n);
}

template<const int &MOD> struct Zmod {
    int x;
    Zmod(signed x = 0) : x(norm(x % MOD)) {}
    Zmod(i64 x) : x(norm(x % MOD)) {}

    constexpr int norm(int x) const noexcept {
        if (x < 0) [[unlikely]] {
            x += MOD;
        }
        if (x >= MOD) [[unlikely]] {
            x -= MOD;
        }
        return x;
    }
    explicit operator int() const {
        return x;
    }
    constexpr int val() const {
        return x;
    }
    constexpr Zmod operator-() const {
        Zmod val = norm(MOD - x);
        return val;
    }
    constexpr Zmod inv() const {
        assert(x != 0);
        return mypow(*this, MOD - 2);
    }
    friend constexpr auto &operator>>(istream &in, Zmod &j) {
        int v;
        in >> v;
        j = Zmod(v);
        return in;
    }
    friend constexpr auto &operator<<(ostream &o, const Zmod &j) {
        return o << j.val();
    }
    constexpr Zmod &operator++() {
        x = norm(x + 1);
        return *this;
    }
    constexpr Zmod &operator--() {
        x = norm(x - 1);
        return *this;
    }
    constexpr Zmod operator++(signed) {
        Zmod res = *this;
        ++*this;
        return res;
    }
    constexpr Zmod operator--(signed) {
        Zmod res = *this;
        --*this;
        return res;
    }
    constexpr Zmod &operator+=(const Zmod &i) {
        x = norm(x + i.x);
        return *this;
    }
    constexpr Zmod &operator-=(const Zmod &i) {
        x = norm(x - i.x);
        return *this;
    }
    constexpr Zmod &operator*=(const Zmod &i) {
        x = i64(x) * i.x % MOD;
        return *this;
    }
    constexpr Zmod &operator/=(const Zmod &i) {
        return *this *= i.inv();
    }
    constexpr Zmod &operator%=(const int &i) {
        return x %= i, *this;
    }
    friend constexpr Zmod operator+(const Zmod i, const Zmod j) {
        return Zmod(i) += j;
    }
    friend constexpr Zmod operator-(const Zmod i, const Zmod j) {
        return Zmod(i) -= j;
    }
    friend constexpr Zmod operator*(const Zmod i, const Zmod j) {
        return Zmod(i) *= j;
    }
    friend constexpr Zmod operator/(const Zmod i, const Zmod j) {
        return Zmod(i) /= j;
    }
    friend constexpr Zmod operator%(const Zmod i, const int j) {
        return Zmod(i) %= j;
    }
    friend constexpr bool operator==(const Zmod i, const Zmod j) {
        return i.val() == j.val();
    }
    friend constexpr bool operator!=(const Zmod i, const Zmod j) {
        return i.val() != j.val();
    }
    friend constexpr bool operator<(const Zmod i, const Zmod j) {
        return i.val() < j.val();
    }
    friend constexpr bool operator>(const Zmod i, const Zmod j) {
        return i.val() > j.val();
    }
};

int MOD[] = {998244353, 1000000007};  // 模板参数要引用，所以用数组元素
using Z = Zmod<MOD[1]>;  // 现在是 1e9+7；要 998244353 改 MOD[0]
// @book-end

int main() { return 0; }
