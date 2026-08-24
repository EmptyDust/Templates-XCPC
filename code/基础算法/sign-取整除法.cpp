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
const double PI = acos(-1.0);

// @book-begin
// sign / floor / ceil 均为整数域版本：C++ 的除法向零取整，本实现改为
// 向负无穷(floor) / 向正无穷(ceil)取整；对负数区间二分等处必须用这套语义。
template<typename T> T sign(const T &a) {
    return a == 0 ? 0 : (a < 0 ? -1 : 1);
}
template<typename T> T floor(const T &a, const T &b) {
    // 注意 A + B - 1 对大 T 可能溢出（如 T = int 且 A,B ~ 2^31），大数场景改用 __int128
    T A = abs(a), B = abs(b);
    assert(B != 0);
    return sign(a) * sign(b) > 0 ? A / B : -(A + B - 1) / B;
}
template<typename T> T ceil(const T &a, const T &b) {
    T A = abs(a), B = abs(b);
    assert(b != 0);
    return sign(a) * sign(b) > 0 ? (A + B - 1) / B : -A / B;
}
// @book-end

int main() { return 0; }
