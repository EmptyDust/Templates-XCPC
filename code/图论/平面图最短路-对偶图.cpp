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

template<class... A> int add(A&&...);
int n;
int net;
int now;
int s;
int t;

// @book-begin
int Hash(int x, int y) { return x * (n + 1) + y; }  // 格点 → 对偶图节点编号

int main() {
    for (int i = 1; i <= n + 1; i++) {
        for (int j = 1, w; j <= n; j++) {
            cin >> w;
            int pre = Hash(i - 1, j), now = Hash(i, j);
            if (i == 1) {
                add(s, now, w);
            } else if (i == n + 1) {
                add(pre, t, w);
            } else {
                add(pre, now, w);
            }
            // flow.add(Hash(i, j), Hash(i, j + 1), w);
        }
    }
    for (int i = 1; i <= n; i++) {
        for (int j = 1, w; j <= n + 1; j++) {
            cin >> w;
            int now = Hash(i, j), net = Hash(i, j - 1);
            if (j == 1) {
                add(now, t, w);
            } else if (j == n + 1) {
                add(s, net, w);
            } else {
                add(now, net, w);
            }
            // flow.add(Hash(i, j), Hash(i + 1, j), w);
        }
    }
    for (int i = 1; i <= n + 1; i++) {
        for (int j = 1, w; j <= n; j++) {
            cin >> w;
            int now = Hash(i, j), net = Hash(i - 1, j);
            if (i == 1) {
                add(now, s, w);
            } else if (i == n + 1) {
                add(t, net, w);
            } else {
                add(now, net, w);
            }
            // flow.add(Hash(i, j), Hash(i, j - 1), w);
        }
    }
    for (int i = 1; i <= n; i++) {
        for (int j = 1, w; j <= n + 1; j++) {
            cin >> w;
            int pre = Hash(i, j - 1), now = Hash(i, j);
            if (j == 1) {
                add(t, now, w);
            } else if (j == n + 1) {
                add(pre, s, w);
            } else {
                add(pre, now, w);
            }
            // flow.add(Hash(i, j), Hash(i - 1, j), w);
        }
    }
}
// @book-end
