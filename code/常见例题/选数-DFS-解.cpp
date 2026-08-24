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
    vector<int> in(n), now(n);
    for (auto &it : in) { cin >> it; }
    auto dfs = [&](auto self, int k, int bit, int idx) -> void {
        for (int i = idx; i < n; i++) {
            now[bit] = in[i];
            if (bit < k - 1) { self(self, k, bit + 1, i + 1); }
            if (bit == k - 1) {
                int add = 0;
                for (int j = 0; j < k; j++) {
                    add += now[j];
                }
                cout << add << endl;
            }
        }
    };
    dfs(dfs, k, 0, 0);
}
// @book-end
