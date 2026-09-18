#import "../prelude.typ": *

= 二维几何
<二维几何>
平面点、线、圆、三角形的浮点运算库：预置 `sign`/`EPS`、点线封装，到交点/距离/投影/旋转、圆与切线、三角形四心，文末另附 SMU\_inch 自包含板子。所有判定走 `sign` 不直接 `==`；几何题的错大多出在精度与退化（平行、共线、圆心重合），不在公式。

本章默认 `ld = long double`，`EPS = 1e-7`（文末 SMU\_inch 板子改用 `double` + `1e-9`，两套不要混）。`T` 用 `int` / `i64` 做整点，用 `ld` 做浮点。`Pd` / `Ld` 为 `Point<ld>` / `Line<ld>`，`Pi` 为 `Point<int>`；`Pt` / `Lt` 是模板别名，随模板一起印：`template<typename T> using Pt = Point<T>;`（`Lt` 同）。`sign` 返回 $- 1 \/ 0 \/ 1$。

== format 格式化输出小数点
<format-格式化输出小数点>
C++20。没有 `format` 时用下面预置里的 `cc(x)`（`fixed << setprecision`）。

```cpp
cout << format("{:.2f}", 114514.1919810) << endl;
// output: 114514.19
```

== 库实数类实现 \(双精度)
<库实数类实现-双精度>
上半用 `std::complex`，`Real = int` 只适于整点（叉积会溢出就改 `i64`）。下半按 `.x/.y` 写，与 `complex` 不是同一种类型。

#pitfall[两套 `cross/dot` 不能同时编译（重定义），按题目留一套。]

```cpp
using Real = int;  // 整点；需要更大范围改 i64
using Point = complex<Real>;

Real cross(const Point &a, const Point &b) {
    return (conj(a) * b).imag();
}
Real dot(const Point &a, const Point &b) {
    return (conj(a) * b).real();
}

// 下面按 Point.x/.y 写，与上面 complex 版不能同时存在
Real cross(const Point &a, const Point &b) {
    return a.x * b.y - a.y * b.x;
} 
Real dot(const Point &a, const Point &b) {
    return a.x * b.x + a.y * b.y;
}
```

== 平面几何必要初始化
<平面几何必要初始化>
浮点比较用 `eps`（约 $1 e - 8$～$1 e - 12$）。`sign` 把差压成 $- 1 \/ 0 \/ 1$。下面点线圆都靠叉积/点积。

=== 字符串读入浮点数
<字符串读入浮点数>
去掉小数点后按 $k$ 位补零，当成整数用。`Knum` 按题目小数位数改；位数多时 `stoi` 会溢出，改 `stoll`。

#include-code("code/二维几何/字符串读入浮点数.cpp")

=== 预置函数
<预置函数>
全章浮点比较都走 `EPS` / `sign` / `equal`，不要直接 `==`。`EPS` 按坐标范围改。

#include-code("code/二维几何/预置函数.cpp")

=== 点线封装
<点线封装>
点当向量用。加减缩放、`dot` 点积、`cross` 叉积。直线用点+方向，或一般式 $a x + b y + c = 0$。

#include-code("code/二维几何/点线封装.cpp")

=== 叉乘
<叉乘>
定义公式 $a times b = lr(|a|) lr(|b|) "sin" theta$。

```cpp
template<typename T>  // 叉乘
T cross(Point<T> a, Point<T> b) { return a.x * b.y - a.y * b.x; }
template<typename T>  // 叉乘 (p1 - p0) x (p2 - p0);
T cross(Point<T> p1, Point<T> p2, Point<T> p0) { return cross(p1 - p0, p2 - p0); }
```

=== 点乘
<点乘>
定义公式 $a dot b = lr(|a|) lr(|b|) "cos" theta$。（原文写成了 $times$，与叉乘混淆）

```cpp
template<typename T>  // 点乘
T dot(Point<T> a, Point<T> b) { return a.x * b.x + a.y * b.y; }
template<typename T>  // 点乘 (p1 - p0) * (p2 - p0);
T dot(Point<T> p1, Point<T> p2, Point<T> p0) { return dot(p1 - p0, p2 - p0); }
```

=== 欧几里得距离公式
<欧几里得距离公式>
最常用的距离公式。

#pitfall[开根号会丢精度——如无强制要求先不开根，留到最后一步一起开；比较距离用平方比较。]

#include-code("code/二维几何/欧几里得距离公式.cpp")

=== 曼哈顿距离公式
<曼哈顿距离公式>
$lr(|x_1 - x_2|) + lr(|y_1 - y_2|)$。转坐标 $(x + y , x - y)$ 后变切比雪夫。

```cpp
template<typename T> T dis1(Point<T> p1, Point<T> p2) {  // 曼哈顿距离公式
    return abs(p1.x - p2.x) + abs(p1.y - p2.y);
}
```

=== 将向量转换为单位向量
<将向量转换为单位向量>
除以模长。零向量不要除。

```cpp
Point<ld> standardize(Point<ld> vec) {  // 转换为单位向量
    return vec / sqrt(vec.x * vec.x + vec.y * vec.y);
}
```

=== 向量旋转
<向量旋转>
将当前向量移动至原点后顺时针旋转 $90^circle.stroked.tiny$ ，即获取垂直于当前向量的、起点为原点的向量。在计算垂线时非常有用。例如，要想获取点 $a$ 绕点 $o$ 顺时针旋转 $90^circle.stroked.tiny$ 后的点，可以这样书写代码：`auto ans = o + rotate(o, a);` ；如果是逆时针旋转，那么只需更改符号即可：`auto ans = o - rotate(o, a);` 。参数顺序是 `(原点, 被旋转点)`。

```cpp
template<typename T> Point<T> rotate(Point<T> p1, Point<T> p2) {  // 旋转
    Point<T> vec = p1 - p2;
    return {-vec.y, vec.x};
}
```

== 平面角度与弧度
<平面角度与弧度>
C++ 三角函数吃弧度。$pi$ 用 `acos(-1)`。

=== 弧度角度相互转换
<弧度角度相互转换>
$"deg" = "rad" dot 180 \/ pi$。

#include-code("code/二维几何/弧度角度相互转换.cpp")

=== 正弦定理
<正弦定理>
$frac(a, "sin" A) = frac(b, "sin" B) = frac(c, "sin" C) = 2 R$ ，其中 $R$ 为三角形外接圆半径；

=== 余弦定理（已知三角形三边，求角）
<余弦定理已知三角形三边求角>
$"cos" C = frac(a^2 + b^2 - c^2, 2 a b) , "cos" B = frac(a^2 + c^2 - b^2, 2 a c) , "cos" A = frac(b^2 + c^2 - a^2, 2 b c)$。可以借此推导出三角形面积公式 $S_(triangle.stroked.t A B C) = frac(a b dot "sin" C, 2) = frac(b c dot "sin" A, 2) = frac(a c dot "sin" B, 2)$。

注意，计算格式是：由 $b , c , a$ 三边求 $angle A$；由 $a , c , b$ 三边求 $angle B$；由 $a , b , c$ 三边求 $angle C$。

```cpp
ld angle(ld a, ld b, ld c) {  // 余弦定理
    ld val = acos((a * a + b * b - c * c) / (2.0 * a * b));  // 计算弧度
    return val;
}
```

=== 求两向量的夹角
<求两向量的夹角>
能够计算 $[0^circle.stroked.tiny , 180^circle.stroked.tiny]$ 区间的角度。

```cpp
ld angle(Point<ld> a, Point<ld> b) {
    ld val = abs(cross(a, b));
    return abs(atan2(val, a.x * b.x + a.y * b.y));
}
```

=== 向量旋转任意角度
<向量旋转任意角度>
逆时针旋转，转换公式：${x prime = x "cos" theta - y "sin" theta\
y prime = x "sin" theta + y "cos" theta$

```cpp
Point<ld> rotate(Point<ld> p, ld rad) {
    return {p.x * cos(rad) - p.y * sin(rad), p.x * sin(rad) + p.y * cos(rad)};
}
```

=== 点绕点旋转任意角度
<点绕点旋转任意角度>
点 $a$ 绕点 $b$ 逆时针转 `rad` 弧度。转换公式：${x prime = (x_0 - x_1) "cos" theta - (y_0 - y_1) "sin" theta + x_1\
y prime = (x_0 - x_1) "sin" theta + (y_0 - y_1) "cos" theta + y_1$

#include-code("code/二维几何/点绕点旋转任意角度.cpp")

== 平面点线相关
<平面点线相关>
叉积为 $0$ 则共线/点在直线上；符号判断左右侧。点到直线距离是叉积绝对值除以方向长。投影：沿法向落到直线上。

=== 点是否在直线上（三点是否共线）
<点是否在直线上三点是否共线>
叉积为 $0$。浮点用 `sign`。

#include-code("code/二维几何/点是否在直线上三点是否共线.cpp")

=== 点是否在向量（直线）左侧
<点是否在向量直线左侧>
#strong[需要注意];，向量的方向会影响答案；点在向量上时不视为在左侧。

```cpp
template<typename T> bool pointOnLineLeft(Pt p, Lt l) {
    return cross(l.b, p, l.a) > 0;
}
```

=== 两点是否在直线同侧/异侧
<两点是否在直线同侧异侧>
两点对直线叉积同号则同侧，异号则异侧。

```cpp
template<typename T> bool pointOnLineSide(Pt p1, Pt p2, Lt vec) {
    T val = cross(p1, vec.a, vec.b) * cross(p2, vec.a, vec.b);
    return sign(val) == 1;
}
template<typename T> bool pointNotOnLineSide(Pt p1, Pt p2, Lt vec) {
    T val = cross(p1, vec.a, vec.b) * cross(p2, vec.a, vec.b);
    return sign(val) == -1;
}
```

=== 两直线相交交点
<两直线相交交点>
参数方程求交。必须用浮点类型。

#pitfall[使用前先判平行，否则分母为 $0$。]

```cpp
Pd lineIntersection(Ld l1, Ld l2) {
    ld val = cross(l2.b - l2.a, l1.a - l2.a) / cross(l2.b - l2.a, l1.a - l1.b);
    return l1.a + (l1.b - l1.a) * val;
}
```

=== 两直线是否平行/垂直/相同
<两直线是否平行垂直相同>
方向叉积 $0$ 平行；点积 $0$ 垂直；平行再看一点是否在另一线上即相同。

```cpp
template<typename T> bool lineParallel(Lt p1, Lt p2) {
    return sign(cross(p1.a - p1.b, p2.a - p2.b)) == 0;
}
template<typename T> bool lineVertical(Lt p1, Lt p2) {
    return sign(dot(p1.a - p1.b, p2.a - p2.b)) == 0;
}
template<typename T> bool same(Line<T> l1, Line<T> l2) {
    return lineParallel(Line{l1.a, l2.b}, {l1.b, l2.a}) &&
           lineParallel(Line{l1.a, l2.a}, {l1.b, l2.b}) && lineParallel(l1, l2);
}
```

=== 点到直线的最近距离与最近点
<点到直线的最近距离与最近点>
垂足。距离 $= lr(|A B times A P|) \/ lr(|A B|)$。

```cpp
pair<Pd, ld> pointToLine(Pd p, Ld l) {
    Pd ans = lineIntersection({p, p + rotate(l.a, l.b)}, l);
    return {ans, dis(p, ans)};
}
```

如果只需要计算最近距离，下方的写法可以减少书写的代码量，效果一致。

```cpp
template<typename T> ld disPointToLine(Pt p, Lt l) {
    ld ans = cross(p, l.a, l.b);
    return abs(ans) / dis(l.a, l.b);  // 面积除以底边长
}
```

=== 点是否在线段上
<点是否在线段上>
共线且在两端点包围盒内（点积 $lt.eq 0$ 或坐标夹在中间）。

```cpp
template<typename T> bool pointOnSegment(Pt p, Lt l) {  // 端点也算
    return sign(cross(p, l.a, l.b)) == 0 && min(l.a.x, l.b.x) <= p.x && p.x <= max(l.a.x, l.b.x) &&
           min(l.a.y, l.b.y) <= p.y && p.y <= max(l.a.y, l.b.y);
}
template<typename T> bool pointOnSegmentEx(Pt p, Lt l) {  // 端点不算（与上一函数区分名）
    return pointOnSegment(p, l) && min(l.a.x, l.b.x) < p.x && p.x < max(l.a.x, l.b.x) &&
           min(l.a.y, l.b.y) < p.y && p.y < max(l.a.y, l.b.y);
}
```

=== 点到线段的最近距离与最近点
<点到线段的最近距离与最近点>
垂足落在段内用垂足，否则取较近端点。

```cpp
pair<Pd, ld> pointToSegment(Pd p, Ld l) {
    if (sign(dot(p, l.b, l.a)) == -1) {  // 特判到两端点的距离
        return {l.a, dis(p, l.a)};
    } else if (sign(dot(p, l.a, l.b)) == -1) {
        return {l.b, dis(p, l.b)};
    }
    return pointToLine(p, l);
}
```

=== 点在直线上的投影点（垂足）
<点在直线上的投影点垂足>
$A + "proj"_(A B) (A P)$。直线两端无线。

```cpp
Pd project(Pd p, Ld l) {  // 投影
    Pd vec = l.b - l.a;
    ld r = dot(vec, p - l.a) / (vec.x * vec.x + vec.y * vec.y);
    return l.a + vec * r;
}
```

=== 线段的中垂线
<线段的中垂线>
中点 + 方向旋转 $90^circle.stroked.tiny$。外心、垂直平分用。

```cpp
template<typename T> Lt midSegment(Lt l) {
    Pt mid = (l.a + l.b) / 2;  // 线段中点
    return {mid, mid + rotate(l.a, l.b)};
}
```

=== 两线段是否相交及交点
<两线段是否相交及交点>
该扩展版可以同时返回相交状态和交点，分为四种情况：$0$ 代表不相交；$1$ 代表普通相交；$2$ 代表重叠（交于两个点）；$3$ 代表相交于端点。#strong[需要注意];，部分运算可能会使用到直线求交点，此时务必保证变量类型为浮点数！

```cpp
template<typename T> tuple<int, Pt, Pt> segmentIntersection(Lt l1, Lt l2) {
    auto [s1, e1] = l1;
    auto [s2, e2] = l2;
    auto A = max(s1.x, e1.x), AA = min(s1.x, e1.x);
    auto B = max(s1.y, e1.y), BB = min(s1.y, e1.y);
    auto C = max(s2.x, e2.x), CC = min(s2.x, e2.x);
    auto D = max(s2.y, e2.y), DD = min(s2.y, e2.y);
    if (A < CC || C < AA || B < DD || D < BB) {
        return {0, {}, {}};
    }
    if (sign(cross(e1 - s1, e2 - s2)) == 0) {
        if (sign(cross(s2, e1, s1)) != 0) {
            return {0, {}, {}};
        }
        Pt p1(max(AA, CC), max(BB, DD));
        Pt p2(min(A, C), min(B, D));
        if (!pointOnSegment(p1, l1)) {
            swap(p1.y, p2.y);
        }
        if (p1 == p2) {
            return {3, p1, p2};
        } else {
            return {2, p1, p2};
        }
    }
    auto cp1 = cross(s2 - s1, e2 - s1);
    auto cp2 = cross(s2 - e1, e2 - e1);
    auto cp3 = cross(s1 - s2, e1 - s2);
    auto cp4 = cross(s1 - e2, e1 - e2);
    if (sign(cp1 * cp2) == 1 || sign(cp3 * cp4) == 1) {
        return {0, {}, {}};
    }
    // 使用下方函数时请使用浮点数
    Pd p = lineIntersection(l1, l2);
    if (sign(cp1) != 0 && sign(cp2) != 0 && sign(cp3) != 0 && sign(cp4) != 0) {
        return {1, p, p};
    } else {
        return {3, p, p};
    }
}
```

如果不需要求交点，那么使用快速排斥+跨立实验即可，其中重叠、相交于端点均视为相交。

```cpp
// TODO：跨立点序与上面 tuple 版不同；原文 sign==1 会把端点/重叠判成不相交，与“均视为相交”矛盾
template<typename T> bool segmentIntersection(Lt l1, Lt l2) {
    auto [s1, e1] = l1;
    auto [s2, e2] = l2;
    auto A = max(s1.x, e1.x), AA = min(s1.x, e1.x);
    auto B = max(s1.y, e1.y), BB = min(s1.y, e1.y);
    auto C = max(s2.x, e2.x), CC = min(s2.x, e2.x);
    auto D = max(s2.y, e2.y), DD = min(s2.y, e2.y);
    return A >= CC && B >= DD && C >= AA && D >= BB &&
           sign(cross(s1, s2, e1) * cross(s1, e1, e2)) != 1 &&  // 不能写 ==1：端点/重叠会判不相交
           sign(cross(s2, s1, e2) * cross(s2, e2, e1)) != 1;
}
```

== 平面圆相关 \(浮点数处理)
<平面圆相关-浮点数处理>
圆是圆心+半径。相交看圆心距与两半径关系；切线从点向圆作垂直于半径的线。交点、切点都用单位方向拼出来。浮点，先 `sign` 再算。

=== 点到圆的最近点
<点到圆的最近点>
同时返回最近点与最近距离。#strong[需要注意];，当点为圆心时，这样的点有无数个，此时我们视作输入错误，直接返回圆心。

#include-code("code/二维几何/点到圆的最近点.cpp")

=== 根据圆心角获取圆上某点
<根据圆心角获取圆上某点>
将圆上最右侧的点以圆心为旋转中心，逆时针旋转 `rad` #strong[弧度];（原文写成“度”，与 `cos/sin` 不符）。

```cpp
Point<ld> getPoint(Point<ld> p, ld r, ld rad) {
    return {p.x + cos(rad) * r, p.y + sin(rad) * r};
}
```

=== 直线是否与圆相交及交点
<直线是否与圆相交及交点>
$0$ 代表不相交；$1$ 代表相切；$2$ 代表相交。

#include-code("code/二维几何/直线是否与圆相交及交点.cpp")

=== 线段是否与圆相交及交点
<线段是否与圆相交及交点>
$0$ 代表不相交；$1$ 代表相切；$2$ 代表相交于一个点；$3$ 代表相交于两个点。

```cpp
tuple<int, Pd, Pd> segmentCircleCross(Ld l, Pd o, ld r) {
    auto [type, U, V] = lineCircleCross(l, o, r);
    bool f1 = pointOnSegment(U, l), f2 = pointOnSegment(V, l);
    if (type == 1 && f1) {
        return {1, U, {}};
    } else if (type == 2 && f1 && f2) {
        return {3, U, V};
    } else if (type == 2 && f1) {
        return {2, U, {}};
    } else if (type == 2 && f2) {
        return {2, V, {}};
    } else {
        return {0, {}, {}};
    }
}
```

=== 两圆是否相交及交点
<两圆是否相交及交点>
$0$ 代表内含；$1$ 代表相离；$2$ 代表相切；$3$ 代表相交。

#include-code("code/二维几何/两圆是否相交及交点.cpp")

=== 两圆相交面积
<两圆相交面积>
上述所言四种相交情况均可计算，之所以不使用三角形面积计算公式是因为在计算过程中会出现“负数”面积（扇形面积与三角形面积的符号关系会随圆的位置关系发生变化），故公式全部重新推导，这里采用的是扇形面积减去扇形内部的那个三角形的面积。

#include-code("code/二维几何/两圆相交面积.cpp")

=== 三点确定一圆
<三点确定一圆>
外接圆，圆心是两边中垂线交点。共线无解。

```cpp
tuple<int, Pd, ld> getCircle(Pd A, Pd B, Pd C) {
    if (onLine(A, B, C)) {  // 特判三点共线
        return {0, {}, 0};
    }
    Ld l1 = midSegment(Line{A, B});
    Ld l2 = midSegment(Line{A, C});
    Pd O = lineIntersection(l1, l2);
    return {1, O, dis(A, O)};
}
```

=== 求解点到圆的切线数量与切点
<求解点到圆的切线数量与切点>
点 $p$ 向圆 $(A , r)$ 引切线。返回切线数量和切点。

#include-code("code/二维几何/求解点到圆的切线数量与切点.cpp")

=== 求解两圆的内公、外公切线数量与切点
<求解两圆的内公外公切线数量与切点>
同时返回公切线数量以及每个圆的切点。

#include-code("code/二维几何/求解两圆的内公、外公切线数量与切点.cpp")

== 平面三角形相关 \(浮点数处理)
<平面三角形相关-浮点数处理>
面积 $lr(|A B times A C|) \/ 2$。外心：三边中垂线交点；内心：角平分线，到三边等距；垂心：高线交点。退化（共线）时这些心无定义。

=== 三角形面积
<三角形面积>
$lr(|A B times A C|) \/ 2$。有向面积保留符号。

```cpp
ld area(Point<ld> a, Point<ld> b, Point<ld> c) {
    return abs(cross(b, c, a)) / 2;
}
```

=== 三角形外心
<三角形外心>
三角形外接圆的圆心，即三角形三边垂直平分线的交点。

```cpp
template<typename T> Pt center1(Pt p1, Pt p2, Pt p3) {  // 外心
    return lineIntersection(midSegment({p1, p2}), midSegment({p2, p3}));
}
```

=== 三角形内心
<三角形内心>
三角形内切圆的圆心，也是三角形三个内角的角平分线的交点。其到三角形三边的距离相等。`#define atan2(p)` 会污染库函数，用完注意作用域。两角平分线夹角可能跨过 $plus.minus pi$ 接缝，极端数据优先用边权公式 $I = (a A + b B + c C) \/ (a + b + c)$。

#include-code("code/二维几何/三角形内心.cpp")

=== 三角形垂心
<三角形垂心>
三角形的三条高线所在直线的交点。锐角三角形的垂心在三角形内；直角三角形的垂心在直角顶点上；钝角三角形的垂心在三角形外。

```cpp
Pd center3(Pd p1, Pd p2, Pd p3) {  // 垂心
    Ld U = {p1, p1 + rotate(p2, p3)};  // 垂线
    Ld V = {p2, p2 + rotate(p1, p3)};
    return lineIntersection(U, V);
}
```

== 平面直线方程转换
<平面直线方程转换>
两点式、点向式、一般式 $a x + b y + c = 0$ 互转。一般式不唯一，可约掉公约数。

=== 浮点数计算直线的斜率
<浮点数计算直线的斜率>
一般很少使用到这个函数，因为斜率的取值不可控（例如接近平行于 $x , y$ 轴时）。#strong[需要注意];，当直线平行于 $y$ 轴时斜率为 `inf` 。

```cpp
template<typename T> ld slope(Pt p1, Pt p2) {  // 斜率，注意 inf 的情况
    return (p1.y - p2.y) / (p1.x - p2.x);
}
template<typename T> ld slope(Lt l) {
    return slope(l.a, l.b);
}
```

=== 分数精确计算直线的斜率
<分数精确计算直线的斜率>
调用分数四则运算精确计算斜率，返回最简分数，只适用于整数计算。

```cpp
template<typename T> Frac<T> slopeEx(Pt p1, Pt p2) {
    Frac<T> U = p1.y - p2.y;
    Frac<T> V = p1.x - p2.x;
    return U / V;  // 调用分数精确计算
}
```

=== 两点式转一般式
<两点式转一般式>
返回由三个整数构成的方程，在输入较大时可能找不到较小的满足题意的一组整数解。可以处理平行于 $x , y$ 轴、两点共点的情况。

```cpp
template<typename T> tuple<T, T, T> getfun(Lt p) {
    T A = p.a.y - p.b.y, B = p.b.x - p.a.x, C = p.a.x * A + p.a.y * B;
    if (A < 0) {  // 符号调整
        A = -A, B = -B, C = -C;
    } else if (A == 0) {
        if (B < 0) {
            B = -B, C = -C;
        } else if (B == 0 && C < 0) {
            C = -C;
        }
    }
    if (A == 0) {  // 数值计算
        if (B == 0) {
            C = 0;  // 共点特判
        } else {
            T g = fgcd(abs(B), abs(C));
            B /= g, C /= g;
        }
    } else if (B == 0) {
        T g = fgcd(abs(A), abs(C));
        A /= g, C /= g;
    } else {
        T g = fgcd(fgcd(abs(A), abs(B)), abs(C));
        A /= g, B /= g, C /= g;
    }
    return tuple{A, B, C};  // Ax + By = C
}
```

=== 一般式转两点式
<一般式转两点式>
由于整数点可能很大或者不存在，故直接采用浮点数；如果与 $x , y$ 轴有交点则取交点。可以处理平行于 $x , y$ 轴的情况。

#include-code("code/二维几何/一般式转两点式.cpp")

=== 抛物线与 x 轴是否相交及交点
<抛物线与-x-轴是否相交及交点>
$0$ 代表没有交点；$1$ 代表相切；$2$ 代表有两个交点。

#include-code("code/二维几何/抛物线与-x-轴是否相交及交点.cpp")

== SMU\_inch
<smu_inch>
另一套自包含板子（`double` + `EPS=1e-9`，点类型是 `P` 不是上面的 `Point`）。`#define pop pop_back`、`#define list vector` 会污染标准名，用时小心。`N` / `MOD` 按题目改。与上文模板不要混用。

上文模板没有、只在这块里的算法（免得埋在整板里翻不到）：

- `min_circle` 最小圆覆盖，期望 #O($N$)
- `areaCT` 圆与"顶点在圆心的三角形"的交面积（有向）
- `convexDiamter` 凸包直径（旋转卡壳）
- `convexCut` 用直线切凸多边形，取左侧
- `disSS` 两线段距离；`reflect` 点关于直线反射
- `isSS_strict` / `onSeg_strict` 严格相交 / 严格在线段上

#include-code("code/二维几何/SMU_inch.cpp")
