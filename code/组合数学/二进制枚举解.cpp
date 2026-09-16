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
    for (int i = 1; i < (1 << m); i ++ ){  // 枚举非空质因子子集
        i64 t = 1, cnt = 0;  // t 为子集积，cnt 为子集大小
        for (int j = 0; j < m; j ++ ){
            if (i >> j & 1){
                cnt ++ ;
                t *= p[j];
                if (t > n){  // 积已 >n，n/t=0，再乘会爆 i64
                    t = -1;
                    break;
                }
            }
        }
        if (t != -1){
            if (cnt & 1) ans += n / t;  // 奇数个加，偶数个减
            else ans -= n / t;
        }
    }
    cout << ans << "\n";
    return 0;
}
// @book-end
