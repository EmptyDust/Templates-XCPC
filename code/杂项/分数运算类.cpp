#include "../contest.hpp"
int n, m;

// @book-begin
template<typename T> struct Frac {
    T x, y;
    Frac() : Frac(0, 1) {}
    Frac(T x_) : Frac(x_, 1) {}
    Frac(T x_, T y_) : x(x_), y(y_) {
        assert(y != 0);
        if (y < 0) {
            y = -y;
            x = -x;
        }
    }

    constexpr double val() const {
        return 1. * x / y;
    }
    constexpr Frac norm() const {  // 调整符号、转化为最简形式
        T p = gcd(x, y);
        return {x / p, y / p};
    }
    friend constexpr auto &operator<<(ostream &o, const Frac &j) {
        T p = gcd(j.x, j.y);
        if (j.y == p) {
            return o << j.x / p;
        } else {
            return o << j.x / p << "/" << j.y / p;
        }
    }
    constexpr Frac &operator/=(const Frac &i) {
        assert(i.x != 0);
        return *this = Frac(x * i.y, y * i.x);  // 先构造结果，允许自除
    }
    constexpr Frac &operator+=(const Frac &i) { return x = x * i.y + y * i.x, y *= i.y, *this; }
    constexpr Frac &operator-=(const Frac &i) { return x = x * i.y - y * i.x, y *= i.y, *this; }
    constexpr Frac &operator*=(const Frac &i) { return x *= i.x, y *= i.y, *this; }
    friend constexpr Frac operator+(Frac i, const Frac j) { return i += j; }
    friend constexpr Frac operator-(Frac i, const Frac j) { return i -= j; }
    friend constexpr Frac operator*(Frac i, const Frac j) { return i *= j; }
    friend constexpr Frac operator/(Frac i, const Frac j) { return i /= j; }
    friend constexpr Frac operator-(const Frac i) { return Frac(-i.x, i.y); }
    friend constexpr bool operator<(const Frac i, const Frac j) { return i.x * j.y < i.y * j.x; }
    friend constexpr bool operator>(const Frac i, const Frac j) { return i.x * j.y > i.y * j.x; }
    friend constexpr bool operator==(const Frac i, const Frac j) { return i.x * j.y == i.y * j.x; }
    friend constexpr bool operator!=(const Frac i, const Frac j) { return i.x * j.y != i.y * j.x; }
};
// @book-end

int main() { return 0; }
