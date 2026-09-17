#include <bits/stdc++.h>
using namespace std;
typedef long long i64;
typedef long long ll;
typedef long long LL;
typedef long double ld;
typedef unsigned long long u64;
const int MOD = 998244353;
const int M = 2000005;
const double eps = 1e-8;
const double PI = acos(-1.0);

// BIT 依赖数据结构章的封装（add / ask），此处仅声明供语法检查
template<typename T> struct BIT {
    BIT(int n, auto &in);
    void add(int x, T v);
    T ask(int x);
    T ask(int l, int r);
};

// @book-begin
#include <bits/stdc++.h>
using namespace std;
using i64 = long long;
const int mod = 998244353, N = 1e6 + 10;  // 模数与数组上限按题目改
i64 fact[N];
int main(){
    ios::sync_with_stdio(false);cin.tie(0);
    i64 n;
    cin >> n;
    vector<i64> zero(n + 1);
    BIT<i64> a(n, zero);  // 全 0 初值，下面逐点 add(…, 1)
    fact[0] = 1;
    for (int i = 1; i <= n; i ++ ){
        fact[i] = fact[i - 1] * i % mod;
        a.add(i, 1);  // 每个数还剩 1 次
    }
    i64 ans = 0;
    for (int i = 1; i <= n; i ++ ){
        i64 x;
        cin >> x;
        ans = (ans + a.ask(1, x - 1) * fact[n - i] % mod ) % mod;  // 左边未用且比 x 小的个数
        a.add(x, -1);  // 用掉 x
    }
    cout << (ans + 1) % mod << "\n";  // +1 变成 1-indexed 排名
    return 0;
}
// @book-end
