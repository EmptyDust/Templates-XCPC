#include <bits/stdc++.h>
using namespace std;
typedef long long i64;
typedef long long ll;
typedef long long LL;
typedef long double ld;
typedef unsigned long long u64;
const int MOD = 998244353;
const int mod = 1000000007;
const double eps = 1e-8;
const double PI = acos(-1.0);

int INF;

// @book-begin
const int N = 550, M = 1e5 + 7;
int n, m, k;
struct node { int x, y, w; } ver[M];
int d[N], backup[N];

void bf() {
    memset(d, 0x3f, sizeof d); d[1] = 0;
    for (int i = 1; i <= k; ++ i) {
        memcpy(backup, d, sizeof d);
        for (int j = 1; j <= m; ++ j) {
            int x = ver[j].x, y = ver[j].y, w = ver[j].w;
            d[y] = min(d[y], backup[x] + w);
        }
    }
}
int main() {
    cin >> n >> m >> k;
    for (int i = 1; i <= m; ++ i) {
        int x, y, w; cin >> x >> y >> w;
        ver[i] = {x, y, w};
    }
    bf();
    for (int i = 1; i <= n; ++ i) {
        if (d[i] > INF / 2) cout << "N" << endl;
        else cout << d[i] << endl;
    }
}
// @book-end
