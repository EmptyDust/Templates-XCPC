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
template<class... A> int judge(A&&...);

// @book-begin
int main() {
    ld l = -1E9, r = 1E9;  // 初始边界要包住极值点
    for (int t = 1; t <= 100; t++) {
        ld mid1 = (l * 2 + r) / 3;
        ld mid2 = (l + r * 2) / 3;
        if (judge(mid1) < judge(mid2)) {
            r = mid2;
        } else {
            l = mid1;
        }
    }
    cout << l << endl;
}
// @book-end
