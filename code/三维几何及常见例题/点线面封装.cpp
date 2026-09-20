#include "../contest.hpp"

// @book-begin
struct Point3 {
    ld x, y, z;
    Point3(ld x_ = 0, ld y_ = 0, ld z_ = 0) : x(x_), y(y_), z(z_) {}
    Point3 &operator+=(const Point3 &p) & {
        x += p.x;
        y += p.y;
        z += p.z;
        return *this;
    }
    Point3 &operator-=(const Point3 &p) & {
        x -= p.x;
        y -= p.y;
        z -= p.z;
        return *this;
    }
    Point3 &operator*=(const Point3 &p) & {  // 按分量乘，不是叉积
        x *= p.x;
        y *= p.y;
        z *= p.z;
        return *this;
    }
    Point3 &operator*=(ld t) & {
        x *= t;
        y *= t;
        z *= t;
        return *this;
    }
    Point3 &operator/=(ld t) & {
        x /= t;
        y /= t;
        z /= t;
        return *this;
    }
    // 左操作数作为结果副本，右操作数只读。
    friend Point3 operator+(Point3 a, const Point3 &b) { return a += b; }
    friend Point3 operator-(Point3 a, const Point3 &b) { return a -= b; }
    friend Point3 operator*(Point3 a, const Point3 &b) { return a *= b; }
    friend Point3 operator*(Point3 a, ld b) { return a *= b; }
    friend Point3 operator*(ld a, Point3 b) { return b *= a; }
    friend Point3 operator/(Point3 a, ld b) { return a /= b; }
    friend auto &operator>>(istream &is, Point3 &p) {
        return is >> p.x >> p.y >> p.z;
    }
    friend auto &operator<<(ostream &os, const Point3 &p) {
        return os << "(" << p.x << ", " << p.y << ", " << p.z << ")";
    }
};
struct Line3 {
    Point3 a, b;
};
struct Plane {
    Point3 u, v, w;  // 三点定面；共线时 getVec 为零向量
};
using P3 = Point3;
using L3 = Line3;
// @book-end
