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
int n;

// @book-begin
int main() {
    i64 l = 0, r = n;  // 按题目改边界，保证答案在 [l, r] 内
    auto check = [&](i64 x) -> bool {
        // todo: x 是否满足条件（单调）
        return false;
    };
    while (l < r) {
        auto mid = l + (r - l) / 2;  // 防溢出的中点写法
        if (check(mid)) r = mid;
        else l = mid + 1;
    }
    // l 即为答案；若 check 始终为 false，l 会停在 r，记得判无解
}
// @book-end
