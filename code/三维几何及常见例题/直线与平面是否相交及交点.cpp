#include "../contest.hpp"
#include "../二维几何/预置函数.cpp"
#include "其他函数.cpp"

// @book-begin
pair<bool, P3> linePlaneCross(const L3 &l, const Plane &s) {
    P3 normal = getVec(s), direction = l.b - l.a;
    ld denominator = dot(normal, direction);
    if (sign(len(normal)) == 0 || sign(denominator) == 0) return {false, {}};
    ld t = dot(normal, s.u - l.a) / denominator;
    return {true, l.a + direction * t};
}
// @book-end
