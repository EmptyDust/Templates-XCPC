#include "../contest.hpp"
#include "空间点是否在线段上.cpp"

// @book-begin
bool segmentIntersection(const L3 &l1, const L3 &l2, bool strict = false) {
    P3 u = l1.b - l1.a, v = l2.b - l2.a, w = l2.a - l1.a;
    P3 normal = crossEx(u, v);
    if (sign(len(normal)) == 0) {
        if (strict) return false;  // 平行、重叠、退化均不算严格相交
        return pointOnSegment(l1.a, l2) || pointOnSegment(l1.b, l2) ||
               pointOnSegment(l2.a, l1) || pointOnSegment(l2.b, l1);
    }
    if (sign(dot(w, normal)) != 0) return false;  // 异面
    ld denominator = dot(normal, normal);
    ld s = dot(crossEx(w, v), normal) / denominator;
    ld t = dot(crossEx(w, u), normal) / denominator;
    if (strict) return sign(s) > 0 && sign(s - 1) < 0 && sign(t) > 0 && sign(t - 1) < 0;
    return sign(s) >= 0 && sign(s - 1) <= 0 && sign(t) >= 0 && sign(t - 1) <= 0;
}
bool segmentIntersection1(const L3 &l1, const L3 &l2) {  // 两段严格内部交于唯一一点
    return segmentIntersection(l1, l2, true);
}
// @book-end
