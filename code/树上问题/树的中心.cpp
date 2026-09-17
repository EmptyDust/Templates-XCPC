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
struct TreeCenter {
    int n, center, radius, diam;
    vector<vector<pair<int, int>>> e;
    vector<int> d1, d2, s1, up;
    TreeCenter(int n) : n(n), e(n + 1), d1(n + 1), d2(n + 1), s1(n + 1), up(n + 1) {}
    void add(int u, int v, int w = 1) {
        e[u].push_back({w, v});
        e[v].push_back({w, u});
    }
    void dfs1(int u, int fa) {
        for (auto [w, v] : e[u]) {
            if (v == fa) continue;
            dfs1(v, u);
            int x = d1[v] + w;
            if (x > d1[u]) {
                d2[u] = d1[u];
                s1[u] = v;
                d1[u] = x;
            } else if (x > d2[u]) {
                d2[u] = x;
            }
        }
    }
    void dfs2(int u, int fa) {
        for (auto [w, v] : e[u]) {
            if (v == fa) continue;
            if (s1[u] == v) {
                up[v] = max(up[u], d2[u]) + w;
            } else {
                up[v] = max(up[u], d1[u]) + w;
            }
            dfs2(v, u);
        }
    }
    void work(int root = 1) {
        dfs1(root, 0);
        dfs2(root, 0);
        center = root;
        diam = 0;
        for (int i = 1; i <= n; i++) {
            if (max(d1[i], up[i]) < max(d1[center], up[center])) {
                center = i;
            }
            diam = max(diam, d1[i] + d2[i]);
        }
        radius = max(d1[center], up[center]);
    }
};
// @book-end

int main() { return 0; }
