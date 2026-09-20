#include "../contest.hpp"

// @book-begin
const ld EPS = 1e-7;  // 按坐标范围改；SMU_inch 板是 1e-9
const ld INF = numeric_limits<ld>::max();
#define cc(x) cout << fixed << setprecision(x);

ld fgcd(ld x, ld y) {  // 实数域gcd
    return abs(y) < EPS ? abs(x) : fgcd(y, fmod(x, y));
}
template<typename T, typename S>
bool equal(T x, S y) {
    if constexpr (is_integral_v<T> && is_integral_v<S>) return x == y;
    else return abs(ld(x) - ld(y)) < EPS;
}
template<typename T>
int sign(T x) {
    if constexpr (is_integral_v<T>) return (x > 0) - (x < 0);
    if (-EPS < x && x < EPS) return 0;
    return x < 0 ? -1 : 1;
}
// @book-end
