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
int main(){
    ios::sync_with_stdio(false);cin.tie(0);
    i64 n, m;
    cin >> n >> m;
    vector <i64> p(m);
    for (int i = 0; i < m; i ++ )
        cin >> p[i];
    i64 ans = 0;
    auto dfs = [&](auto &&self, i64 x, i64 s, i64 odd) -> void {  // x 当前下标，s 已选积，odd 容斥符号
        if (x == m){
            if (s == 1) return;  // 空集不贡献
            ans += odd * (n / s);
            return;
        }
        self(self, x + 1, s, odd);  // 不选 p[x]
        if (s <= n / p[x]) self(self, x + 1, s * p[x], -odd);  // 选；先除后乘防溢出
    };
    dfs(dfs, 0, 1, -1);  // odd 初值 -1，选第一个数后变成 +
    cout << ans << "\n";
    return 0;
}
// @book-end
