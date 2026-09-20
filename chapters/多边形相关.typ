#import "../prelude.typ": *

= 多边形相关
<多边形相关>
多边形的判定与度量：面积（鞋带 / 皮克定理）、点与线段在形内、二维凸包（静态 Andrew / 动态set）、闵可夫斯基和与半平面交。全部依赖二维章的点线原语；顶点按逆时针存时面积为正。

依赖二维章的 `Point` / `Line` / `cross` / `sign` / `Pt` / `Lt`。

== 平面多边形
<平面多边形>
顶点按序给出。面积用叉积求和（鞋带）；点在形内用绕数或射线。逆时针面积为正。

=== 两向量构成的平面四边形有向面积
<两向量构成的平面四边形有向面积>
以 $p_1$ 为公共顶点，$arrow(p_1 p_2) times arrow(p_1 p_3)$，是平行四边形有向面积（三角形的两倍）。

```cpp
template<typename T> T areaEx(Point<T> p1, Point<T> p2, Point<T> p3) {
    return cross(p2, p3, p1);
}
```

=== 判断四个点能否组成矩形/正方形
<判断四个点能否组成矩形正方形>
可以处理浮点数、共点的情况。返回分为三种情况：$2$ 代表构成正方形；$1$ 代表构成矩形；$0$ 代表其他情况。`Pt` / `Lt` 见二维章。先按坐标排序再两两对边。

```cpp
template<typename T> int isSquare(vector<Pt<T>> x) {  // 有意复制并排序四个点
    assert(x.size() == 4);
    sort(x.begin(), x.end());
    if (equal(dis(x[0], x[1]), dis(x[2], x[3])) && sign(dis(x[0], x[1])) &&
        equal(dis(x[0], x[2]), dis(x[1], x[3])) && sign(dis(x[0], x[2])) &&
        lineParallel(Lt{x[0], x[1]}, Lt{x[2], x[3]}) &&
        lineParallel(Lt{x[0], x[2]}, Lt{x[1], x[3]}) &&
        lineVertical(Lt{x[0], x[1]}, Lt{x[0], x[2]})) {
        return equal(dis(x[0], x[1]), dis(x[0], x[2])) ? 2 : 1;
    }
    return 0;
}
```

=== 点是否在任意多边形内
<点是否在任意多边形内>
射线法判定，$t$ 为穿越次数，当其为奇数时即代表点在多边形内部；返回 $2$ 代表点在多边形边界上，返回 $1$ 在内、$0$ 在外。复杂度 $cal(O)(n)$。不要求凸。

```cpp
template<typename T> int pointInPolygon(Point<T> a, vector<Point<T>> p) {
    int n = p.size();
    for (int i = 0; i < n; i++) {
        if (pointOnSegment(a, Line{p[i], p[(i + 1) % n]})) {
            return 2;
        }
    }
    int t = 0;
    for (int i = 0; i < n; i++) {
        auto u = p[i], v = p[(i + 1) % n];
        if (u.x < a.x && v.x >= a.x && pointOnLineLeft(a, Line{v, u})) {
            t ^= 1;
        }
        if (u.x >= a.x && v.x < a.x && pointOnLineLeft(a, Line{u, v})) {
            t ^= 1;
        }
    }
    return t == 1;
}
```

=== 线段是否在任意多边形内部
<线段是否在任意多边形内部>
两端点都在多边形内（含边界），且与边的相交不是“穿出去”。凹多边形要处理顶点处的局部拐向，分支较多。

```cpp
template<typename T>
bool segmentInPolygon(Line<T> l, vector<Point<T>> p) {
// 线段与多边形边界不相交且两端点都在多边形内部
#define L(x, y) pointOnLineLeft(x, y)
    int n = p.size();
    if (!pointInPolygon(l.a, p)) return false;
    if (!pointInPolygon(l.b, p)) return false;
    for (int i = 0; i < n; i++) {
        auto u = p[i];
        auto v = p[(i + 1) % n];
        auto w = p[(i + 2) % n];
        auto [t, p1, p2] = segmentIntersection(l, Line(u, v));
        if (t == 1) return false;
        if (t == 0) continue;
        if (t == 2) {
            if (pointOnSegment(v, l) && v != l.a && v != l.b) {
                if (cross(v - u, w - v) > 0) {
                    return false;
                }
            }
        } else {
            if (p1 != u && p1 != v) {
                if (L(l.a, Line(v, u)) || L(l.b, Line(v, u))) {
                    return false;
                }
            } else if (p1 == v) {
                if (l.a == v) {
                    if (L(u, l)) {
                        if (L(w, l) && L(w, Line(u, v))) {
                            return false;
                        }
                    } else {
                        if (L(w, l) || L(w, Line(u, v))) {
                            return false;
                        }
                    }
                } else if (l.b == v) {
                    if (L(u, Line(l.b, l.a))) {
                        if (L(w, Line(l.b, l.a)) && L(w, Line(u, v))) {
                            return false;
                        }
                    } else {
                        if (L(w, Line(l.b, l.a)) || L(w, Line(u, v))) {
                            return false;
                        }
                    }
                } else {
                    if (L(u, l)) {
                        if (L(w, Line(l.b, l.a)) || L(w, Line(u, v))) {
                            return false;
                        }
                    } else {
                        if (L(w, l) || L(w, Line(u, v))) {
                            return false;
                        }
                    }
                }
            }
        }
    }
    return true;
}
```

=== 任意多边形的面积
<任意多边形的面积>
鞋带公式。逆时针为正；要绝对值就包一层 `abs`。与二维章三角形 `area` 同名。

```cpp
template<typename T> ld area(vector<Point<T>> P) {
    int n = P.size();
    ld ans = 0;
    for (int i = 0; i < n; i++) {
        ans += cross(P[i], P[(i + 1) % n]);
    }
    return ans / 2.0;
}
```

=== 皮克定理
<皮克定理>
绘制在方格纸上的多边形面积公式可以表示为 $S = n + s / 2 - 1$ ，其中 $n$ 表示多边形内部的点数、$s$ 表示多边形边界上的点数。一条线段上的点数为 $"gcd" (lr(|x_1 - x_2|) , lr(|y_1 - y_2|)) + 1$。

=== 任意多边形上/内的网格点个数（仅能处理整数）
<任意多边形上内的网格点个数仅能处理整数>
皮克定理用。边上点数每条边计 $"gcd" (Delta x , Delta y)$（每顶点恰好计一次）。内部 $I = A - B \/ 2 + 1$。

```cpp
int onPolygonGrid(vector<Point<int>> p) { // 多边形上
    int n = p.size(), ans = 0;
    for (int i = 0; i < n; i++) {
        auto a = p[i], b = p[(i + 1) % n];
        ans += gcd(abs(a.x - b.x), abs(a.y - b.y));
    }
    return ans;
}
int inPolygonGrid(vector<Point<int>> p) { // 多边形内
    int n = p.size(), ans = 0;
    for (int i = 0; i < n; i++) {
        auto a = p[i], b = p[(i + 1) % n], c = p[(i + 2) % n];
        ans += b.y * (a.x - c.x);
    }
    ans = abs(ans);
    return (ans - onPolygonGrid(p)) / 2 + 1;
}
```

== 二维凸包
<二维凸包>
包住所有点的最小凸多边形。Andrew：按坐标排序，左右各扫一遍，叉积 $lt.eq 0$ 则弹出（右转不凸）。$cal(O)(N "log" N)$，瓶颈在排序。

=== 获取二维静态凸包（Andrew 算法）
<获取二维静态凸包andrew-算法>
#specline([#O($N "log" N$)（瓶颈在排序）])
按 $x$ 排序后两遍扫描、叉积弹栈分别构造下壳与上壳。`flag=0` 边上的点也加入（不严格）；`flag=1` 不加入（严格）。返回逆时针，起点最左下。

```cpp
template<typename T> vector<Point<T>> staticConvexHull(vector<Point<T>> A, int flag = 1) {
    int n = A.size();
    if (n <= 2) {  // 特判
        return A;
    }
    vector<Point<T>> ans(n * 2);
    sort(A.begin(), A.end());
    int now = -1;
    auto bad = [&](Point<T> o, Point<T> a, Point<T> b) {  // flag=1 弹共线（严格），flag=0 保留（非严格）
        auto cr = cross(o, a, b);
        return flag ? cr <= 0 : cr < 0;
    };
    for (int i = 0; i < n; i++) {  // 维护下凸包
        while (now > 0 && bad(A[i], ans[now], ans[now - 1])) {
            now--;
        }
        ans[++now] = A[i];
    }
    int pre = now;
    for (int i = n - 2; i >= 0; i--) {  // 维护上凸包
        while (now > pre && bad(A[i], ans[now], ans[now - 1])) {
            now--;
        }
        ans[++now] = A[i];
    }
    ans.resize(now);
    return ans;
}
```

=== 二维动态凸包
<二维动态凸包>
固定为 `int` 型，`cmp` 用于判定边界情况。可以处理如下两个要求：

- 动态插入点 $(x , y)$ 到当前凸包中；
- 判断点 $(x , y)$ 是否在凸包上或是在内部（包括边界）。

#pitfall[本段的 `Line` 与二维章的 `Line` 冲突，不要同时编译。]

```cpp
template<typename T> bool turnRight(const Pt<T> &a, const Pt<T> &b) {
    return cross(a, b) < 0 || (cross(a, b) == 0 && dot(a, b) < 0);
}
struct Line {
    static int cmp;
    mutable Point<int> a, b;
    friend bool operator<(Line x, Line y) {
        return cmp ? x.a < y.a : turnRight(x.b, y.b);
    }
    friend auto &operator<<(ostream &os, Line l) {
        return os << "<" << l.a << ", " << l.b << ">";
    }
};

int Line::cmp = 1;
struct UpperConvexHull : set<Line> {
    bool contains(const Point<int> &p) const {
        auto it = lower_bound({p, 0});
        if (it != end() && it->a == p) return true;
        if (it != begin() && it != end() && cross(prev(it)->b, p - prev(it)->a) <= 0) {
            return true;
        }
        return false;
    }
    void add(const Point<int> &p) {
        if (contains(p)) return;
        auto it = lower_bound({p, 0});
        for (; it != end(); it = erase(it)) {
            if (turnRight(it->a - p, it->b)) {
                break;
            }
        }
        for (; it != begin() && prev(it) != begin(); erase(prev(it))) {
            if (turnRight(prev(prev(it))->b, p - prev(prev(it))->a)) {
                break;
            }
        }
        if (it != begin()) {
            prev(it)->b = p - prev(it)->a;
        }
        if (it == end()) {
            insert({p, {0, -1}});
        } else {
            insert({p, it->a - p});
        }
    }
};
struct ConvexHull {
    UpperConvexHull up, low;
    bool empty() const {
        return up.empty();
    }
    bool contains(const Point<int> &p) const {
        Line::cmp = 1;
        return up.contains(p) && low.contains(-p);
    }
    void add(const Point<int> &p) {
        Line::cmp = 1;
        up.add(p);
        low.add(-p);
    }
    bool isIntersect(int A, int B, int C) const {
        Line::cmp = 0;
        if (empty()) return false;
        Point<int> k = {-B, A};
        if (k.x < 0) k = -k;
        if (k.x == 0 && k.y < 0) k.y = -k.y;
        Point<int> P = up.upper_bound({{0, 0}, k})->a;
        Point<int> Q = -low.upper_bound({{0, 0}, k})->a;
        return sign(A * P.x + B * P.y - C) * sign(A * Q.x + B * Q.y - C) > 0;
    }
    friend ostream &operator<<(ostream &out, const ConvexHull &ch) {
        for (const auto &line : ch.up) out << "(" << line.a.x << "," << line.a.y << ")";
        cout << "/";
        for (const auto &line : ch.low) out << "(" << -line.a.x << "," << -line.a.y << ")";
        return out;
    }
};
```

=== 点与凸包的位置关系
<点与凸包的位置关系>
#specline([线性扫描 #O($n$)（凸包上二分可 #O($"log" n$)，本板未写）])
$0$ 代表点在凸包外面；$1$ 代表在凸壳上；$2$ 代表在凸包内部。输入须按绕序。

```cpp
template<typename T> int contains(Point<T> p, vector<Point<T>> A) {
    int n = A.size();
    bool in = false;
    for (int i = 0; i < n; i++) {
        Point<T> a = A[i] - p, b = A[(i + 1) % n] - p;
        if (a.y > b.y) {
            swap(a, b);
        }
        if (a.y <= 0 && 0 < b.y && cross(a, b) < 0) {
            in = !in;
        }
        if (cross(a, b) == 0 && dot(a, b) <= 0) {
            return 1;
        }
    }
    return in ? 2 : 0;
}
```

=== 闵可夫斯基和
<闵可夫斯基和>
#specline([#O($n + m$)])
计算两个凸包的向量和 ${ p + q }$，结果仍是凸包。做法：各自从最低点起把边向量按极角归并依次相接。输入须已是有序凸包。

```cpp
template<typename T> vector<Point<T>> mincowski(vector<Point<T>> P1, vector<Point<T>> P2) {
    int n = P1.size(), m = P2.size();
    vector<Point<T>> V1(n), V2(m);
    for (int i = 0; i < n; i++) {
        V1[i] = P1[(i + 1) % n] - P1[i];
    }
    for (int i = 0; i < m; i++) {
        V2[i] = P2[(i + 1) % m] - P2[i];
    }
    vector<Point<T>> ans = {P1.front() + P2.front()};
    int t = 0, i = 0, j = 0;
    while (i < n && j < m) {
        Point<T> val = sign(cross(V1[i], V2[j])) > 0 ? V1[i++] : V2[j++];
        ans.push_back(ans.back() + val);
    }
    while (i < n) ans.push_back(ans.back() + V1[i++]);
    while (j < m) ans.push_back(ans.back() + V2[j++]);
    return ans;
}
```

=== 半平面交
<半平面交>
计算有向直线 `a→b` 左侧闭半平面的交集，依赖二维点线封装、预置函数、叉积、点积与 `lineIntersection`。使用 `Ld` / `Pd`，每条线的两点必须不同。复杂度 $cal(O)(N "log" N)$。

本接口要求交集有界：正面积时返回逆时针凸多边形；空集或退化成点、线段时返回空。不区分无界交集与空集；若题目另有矩形边界，应将其四条逆时针边加入输入，不能凭空添加“足够大”的方框。同向平行线只保留限制更紧的一条。排序使用精确极角顺序，几何判定使用 EPS；近退化数据仍须按题目尺度选择容差。

```cpp
vector<Pd> halfcut(vector<Ld> lines) {  // 有意复制并排序输入
    auto direction = [](const Ld &l) { return l.b - l.a; };
    auto half = [](const Pd &d) { return d.y > 0 || (d.y == 0 && d.x >= 0); };
    auto outside = [](const Ld &l, const Pd &p) { return sign(cross(l.b - l.a, p - l.a)) < 0; };
    for (const Ld &l : lines) assert(l.a.x != l.b.x || l.a.y != l.b.y);
    sort(lines.begin(), lines.end(), [&](const Ld &a, const Ld &b) {
        Pd u = direction(a), v = direction(b);
        if (half(u) != half(v)) return half(u) > half(v);
        return cross(u, v) > 0;
    });
    vector<Ld> unique;
    for (const Ld &l : lines) {
        if (!unique.empty() && sign(cross(direction(unique.back()), direction(l))) == 0 &&
            dot(direction(unique.back()), direction(l)) > 0) {
            if (outside(l, unique.back().a)) unique.back() = l;
        } else unique.push_back(l);
    }
    deque<Ld> q;
    for (const Ld &l : unique) {
        while (q.size() > 1 && outside(l, lineIntersection(q[q.size() - 2], q.back()))) q.pop_back();
        while (q.size() > 1 && outside(l, lineIntersection(q[0], q[1]))) q.pop_front();
        if (!q.empty() && sign(cross(direction(q.back()), direction(l))) == 0) return {};
        q.push_back(l);
    }
    while (q.size() > 2 && outside(q.front(), lineIntersection(q[q.size() - 2], q.back()))) q.pop_back();
    while (q.size() > 2 && outside(q.back(), lineIntersection(q[0], q[1]))) q.pop_front();
    if (q.size() < 3 || sign(cross(direction(q.front()), direction(q.back()))) == 0) return {};
    vector<Pd> result;
    for (int i = 0; i < q.size(); ++i) result.push_back(lineIntersection(q[i], q[(i + 1) % q.size()]));
    ld area = 0;
    for (int i = 1; i + 1 < result.size(); ++i) area += cross(result[i] - result[0], result[i + 1] - result[0]);
    if (sign(area) == 0) return {};
    return result;
}
```
