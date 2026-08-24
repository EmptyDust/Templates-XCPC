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
int main() {
    int n, k; cin >> n >> k;
    vector<int> in(n);
    for (auto &it : in) { cin >> it; }
    int comb = (1 << k) - 1, U = 1 << n;
    while (comb < U) {
        int add = 0;
        for (int i = 0; i < n; i++) {
            if (1 << i & comb) {
                add += in[i];
            }
        }
        cout << add << "\n";
    
        int x = comb & -comb;
        int y = comb + x;
        int z = comb & ~y;
        comb = (z / x >> 1) | y;
    }
}
// @book-end
