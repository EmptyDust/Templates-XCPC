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
// 模板版：对任意整型 T 均正确，用于防 log2/sqrt 等浮点函数大整数精度丢失；
// int 型建议直接用下面的 __builtin 版（更快）。
template<typename T> int log2floor(T n) {
    assert(n > 0);
    for (T i = 0, chk = 1;; i++, chk *= 2) {
        if (chk <= n && n < chk * 2) {
            return i;
        }
    }
}
template<typename T> int log2ceil(T n) {
    assert(n > 0);
    for (T i = 0, chk = 1;; i++, chk *= 2) {
        if (n <= chk) {
            return i;
        }
    }
}
// __builtin 版：仅 int（ll 版各加一个 ll 后缀）
int log2floor(int x) {  // 向下取整；x > 0
    return 31 - __builtin_clz(x);
}
int log2ceil(int x) {  // 向上取整；x > 0
    return log2floor(x) + (__builtin_popcount(x) != 1);
}
// @book-end

int main() { return 0; }
