#include "../contest.hpp"
#include "预置函数.cpp"

// @book-begin
template<typename T>
struct Point {  // 在C++17下使用emplace_back绑定可能会导致CE！
    T x, y;
    Point(T x_ = 0, T y_ = 0) : x(x_), y(y_) {}

    template<typename U>
    operator Point<U>() const {  // 自动类型匹配
        return Point<U>(U(x), U(y));
    }

    Point operator-() const { return {-x, -y}; }
    Point operator+(const Point &b) const { return {x + b.x, y + b.y}; }
    Point operator-(const Point &b) const { return {x - b.x, y - b.y}; }

    Point operator+(const T &b) const { return {x + b, y + b}; }
    Point operator-(const T &b) const { return {x - b, y - b}; }
    Point operator*(const T &b) const { return {x * b, y * b}; }
    Point operator/(const T &b) const { return {x / b, y / b}; }

    T operator*(const Point &b) const { return x * b.x + y * b.y; }  // 点积
    T operator^(const Point &b) const { return x * b.y - y * b.x; }  // 叉积

    Point &operator+=(const Point &p) { x += p.x; y += p.y; return *this; }
    Point &operator-=(const Point &p) { x -= p.x; y -= p.y; return *this; }

    Point &operator+=(const T t) { x += t; y += t; return *this; }
    Point &operator-=(const T t) { x -= t; y -= t; return *this; }
    Point &operator*=(const T t) { x *= t; y *= t; return *this; }
    Point &operator/=(const T t) { x /= t; y /= t; return *this; }

    bool operator<(const Point &b) const {
        return x != b.x ? x < b.x : y < b.y;  // 排序必须满足严格弱序，不混入 EPS
    }
    bool operator>(const Point &b) const { return b < *this; }
    bool operator==(const Point &b) const { return equal(x, b.x) && equal(y, b.y); }
    bool operator!=(const Point &b) const { return !(*this == b); }

    friend istream &operator>>(istream &is, Point &p) {
        return is >> p.x >> p.y;
    }
    friend ostream &operator<<(ostream &os, const Point &p) {
        return os << '(' << p.x << ',' << p.y << ')';
    }
};

template<typename T>
struct Line {
    Point<T> a, b;
    Line(Point<T> a_ = Point<T>(), Point<T> b_ = Point<T>()) : a(a_), b(b_) {}
    template<typename U>
    operator Line<U>() const {  // 自动类型匹配
        return Line<U>(Point<U>(a), Point<U>(b));
    }
    friend ostream &operator<<(ostream &os, const Line &l) {
        return os << '<' << l.a << ',' << l.b << '>';
    }
};
template<typename T> using Pt = Point<T>;
template<typename T> using Lt = Line<T>;
using Pd = Point<ld>;
using Ld = Line<ld>;
using Pi = Point<int>;
// @book-end
