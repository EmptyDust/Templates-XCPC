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

int m;
int n;

// @book-begin
int main() {
    vector C(n + 1, vector<i64>(n + 1));  // 原来 vector<int>，C(34,17)≈2e9 就爆 int
    C[0][0] = 1;
    for (int i = 1; i <= n; i++) {
        C[i][0] = 1;
        for (int j = 1; j <= n; j++) {  // j>i 时加出来仍是 0，不单独截断
            C[i][j] = C[i - 1][j] + C[i - 1][j - 1];
        }
    }
    cout << C[n][m] << endl;
}
// @book-end
