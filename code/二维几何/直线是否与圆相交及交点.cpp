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


const int Knum = 4; // 保留小数位数，按题目改
int read(int k = Knum) {
    string s;
    cin >> s;

    int num = 0;
    int it = s.find('.');
    if (it != -1) { // 存在小数点
        num = s.size() - it - 1; // 计算小数位数
        s.erase(s.begin() + it); // 删除小数点
    }
    for (int i = 1; i <= k - num; i++) {  // 补全小数位数
        s += '0';
    }
    return stoi(s);
}
using ld = long double;
const ld PI = acos(-1);
const ld EPS = 1e-7;  // 按坐标范围改；SMU_inch 板是 1e-9
const ld INF = numeric_limits<ld>::max();
#define cc(x) cout << fixed << setprecision(x);

ld fgcd(ld x, ld y) {  // 实数域gcd
    return abs(y) < EPS ? abs(x) : fgcd(y, fmod(x, y));
}
template<typename T, typename S>
bool equal(T x, S y) {
    return -EPS < x - y && x - y < EPS;
}
template<typename T>
int sign(T x) {
    if (-EPS < x && x < EPS) return 0;
    return x < 0 ? -1 : 1;
}
template<typename T>
struct Point {  // 在C++17下使用emplace_back绑定可能会导致CE！
    T x, y;
    Point(T x_ = 0, T y_ = 0) : x(x_), y(y_) {}

    template<typename U>
    operator Point<U>() {  // 自动类型匹配
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
        return equal(x, b.x) ? y < b.y - EPS : x < b.x - EPS;
    }
    bool operator>(const Point &b) const { return b < *this; }
    bool operator==(const Point &b) const { return !(b < *this) && !(*this < b); }
    bool operator!=(const Point &b) const { return *this < b || b < *this; }

    friend istream &operator>>(istream &is, Point &p) {
        return is >> p.x >> p.y;
    }
    friend ostream &operator<<(ostream &os, const Point &p) {
        return os << format("({},{})", p.x, p.y);     // C++20；没有 format 删本行，留下面
        return os << '(' << p.x << ',' << p.y << ')'; // C++17
    }
};

template<typename T>
struct Line {
    Point<T> a, b;
    Line(Point<T> a_ = Point<T>(), Point<T> b_ = Point<T>()) : a(a_), b(b_) {}
    template<typename U>
    operator Line<U>() {  // 自动类型匹配
        return Line<U>(Point<U>(a), Point<U>(b));
    }
    friend ostream &operator<<(ostream &os, const Line &l) {
        return os << '<' << l.a << ',' << l.b << '>';
    }
};
using Pd = Point<ld>;
using Ld = Line<ld>;
using Pi = Point<int>;
// 模板里的 Pt/Lt 约定为 Point<T>/Line<T>，用前 using Pt = Point<T>; using Lt = Line<T>;
template<typename T>
T disEx(Point<T> a, Point<T> b) {  // 平方距离，先不要开方
    return (a.x - b.x) * (a.x - b.x) + (a.y - b.y) * (a.y - b.y);
}
template<typename T>
ld dis(Point<T> a, Point<T> b) {
    return sqrt(disEx(a, b));
}
ld toDeg(ld x) { // 弧度转角度
    return x * 180 / PI;
}
ld toArc(ld x) { // 角度转弧度
    return PI / 180 * x;
}
Point<ld> rotate(Point<ld> a, Point<ld> b, ld rad) {
    // 原来 x 用了 +sin、y 用了 (b.x-a.x)*sin，是顺时针，与“逆时针”及 rotate(p,rad) 不一致
    ld x = (a.x - b.x) * cos(rad) - (a.y - b.y) * sin(rad) + b.x;
    ld y = (a.x - b.x) * sin(rad) + (a.y - b.y) * cos(rad) + b.y;
    return {x, y};
}
template<typename T> bool onLine(Point<T> a, Point<T> b, Point<T> c) {
    return sign(cross(b, a, c)) == 0;
}
template<typename T> bool onLine(Point<T> p, Line<T> l) {
    return onLine(p, l.a, l.b);
}
pair<Pd, ld> pointToCircle(Pd p, Pd o, ld r) {
    Pd U = o, V = o;
    ld d = dis(p, o);
    if (sign(d) == 0) {  // p 为圆心时返回圆心本身
        return {o, 0};
    }
    ld val1 = r * abs(o.x - p.x) / d;
    ld val2 = r * abs(o.y - p.y) / d * ((o.x - p.x) * (o.y - p.y) < 0 ? -1 : 1);
    U.x += val1, U.y += val2;
    V.x -= val1, V.y -= val2;
    if (dis(U, p) < dis(V, p)) {
        return {U, dis(U, p)};
    } else {
        return {V, dis(V, p)};
    }
}

template<class... A> int project(A&&...);
template<class... A> int standardize(A&&...);

// @book-begin
tuple<int, Pd, Pd> lineCircleCross(Ld l, Pd o, ld r) {
    Pd P = project(o, l);
    ld d = dis(P, o), tmp = r * r - d * d;
    if (sign(tmp) == -1) {
        return {0, {}, {}};
    } else if (sign(tmp) == 0) {
        return {1, P, {}};
    }
    Pd vec = standardize(l.b - l.a) * sqrt(tmp);
    return {2, P + vec, P - vec};
}
// @book-end

int main() { return 0; }
