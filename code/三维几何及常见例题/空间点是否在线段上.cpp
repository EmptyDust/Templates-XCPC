#include "../contest.hpp"
#include "../二维几何/预置函数.cpp"
#include "其他函数.cpp"

// @book-begin
bool pointOnSegment(const P3 &p, const L3 &l) {
    return sign(cross(p - l.a, l.b - l.a)) == 0 && sign(dot(p - l.a, p - l.b)) <= 0;
}
bool pointOnSegmentEx(const P3 &p, const L3 &l) {  // 严格内部；退化线段返回 false
    return sign(cross(p - l.a, l.b - l.a)) == 0 && sign(dot(p - l.a, p - l.b)) < 0;
}
// @book-end
