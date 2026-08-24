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

int W;
int dp[M];
int n;
int num;
int s;
int t;
int v[M];
int w[M];
int x;
int y;

// @book-begin
int main() {
    for (int i = 1; i <= n; i++){
        scanf("%lld%lld%lld", &x, &y, &s);  //x 为体积， y 为价值， s 为数量
        t = 1;
        while (s >= t){
            w[++num] = x * t;
            v[num] = y * t;
            s -= t;
            t *= 2;
        }
        w[++num] = x * s;
        v[num] = y * s;
    }
    for (int i = 1; i <= num; i++)
        for (int j = W; j >= w[i]; j--)
            dp[j] = max(dp[j], dp[j - w[i]] + v[i]);
}
// @book-end
