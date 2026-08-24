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
template<class... A> int check(A&&...);
int l;
int r;

// @book-begin
int main() {
    while (l < r) {
        int mid = l + (r - l) / 2;  // 防溢出中点
        if (check(mid) <= check(mid + 1)) r = mid;
        else l = mid + 1;
    }
    cout << check(l) << endl;
}
// @book-end
