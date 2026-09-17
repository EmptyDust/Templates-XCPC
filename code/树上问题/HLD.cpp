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
struct HLD {
    int n, dfn;
    vector<vector<int>> ver;
    vector<int> siz, dep, top, son, parent, in;
    HLD(int n) : n(n), dfn(0), ver(n + 1), siz(n + 1), dep(n + 1), top(n + 1),
        son(n + 1), parent(n + 1), in(n + 1) {}
    void add(int x, int y) {
        ver[x].push_back(y);
        ver[y].push_back(x);
    }
    void dfs1(int x) {
        siz[x] = 1;
        dep[x] = dep[parent[x]] + 1;
        for (int y : ver[x]) {
            if (y == parent[x]) continue;
            parent[y] = x;
            dfs1(y);
            siz[x] += siz[y];
            if (siz[y] > siz[son[x]]) {
                son[x] = y;
            }
        }
    }
    void dfs2(int x, int tp) {
        in[x] = ++dfn;
        top[x] = tp;
        if (son[x]) {
            dfs2(son[x], tp);
        }
        for (int y : ver[x]) {
            if (y == parent[x] || y == son[x]) continue;
            dfs2(y, y);
        }
    }
    void work(int root = 1) {
        dfs1(root);
        dfs2(root, root);
    }
    int lca(int u, int v) {
        while (top[u] != top[v]) {
            if (dep[top[u]] < dep[top[v]]) {
                swap(u, v);
            }
            u = parent[top[u]];
        }
        return dep[u] < dep[v] ? u : v;
    }
    int dist(int u, int v) {  // 边数
        return dep[u] + dep[v] - 2 * dep[lca(u, v)];
    }
    template<class F>
    void path(int u, int v, F &&op) {  // 点路径，闭区间
        while (top[u] != top[v]) {
            if (dep[top[u]] < dep[top[v]]) {
                swap(u, v);
            }
            op(in[top[u]], in[u]);
            u = parent[top[u]];
        }
        if (dep[u] > dep[v]) {
            swap(u, v);
        }
        op(in[u], in[v]);
    }
    template<class F>
    void subtree(int u, F &&op) {
        op(in[u], in[u] + siz[u] - 1);
    }
};
// @book-end

int main() { return 0; }
