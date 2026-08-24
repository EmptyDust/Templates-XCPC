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
    LL n, m;
    cin >> n >> m;
    vector <LL> p(m);
    for (int i = 0; i < m; i ++ )
        cin >> p[i];
    LL ans = 0;
    function<void(LL, LL, LL)> dfs = [&](LL x, LL s, LL odd){  // x 当前下标，s 已选积，odd 容斥符号
        if (x == m){
            if (s == 1) return;  // 空集不贡献
            ans += odd * (n / s);
            return;
        }
        dfs(x + 1, s, odd);  // 不选 p[x]
        if (s <= n / p[x]) dfs(x + 1, s * p[x], -odd);  // 选；先除后乘防溢出
    };
    dfs(0, 1, -1);  // odd 初值 -1，选第一个数后变成 +
    cout << ans << "\n";
    return 0;
}
// @book-end
