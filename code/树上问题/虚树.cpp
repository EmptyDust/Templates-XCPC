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
struct VirtualTree {
    int n, cnt = 0;
    vector<vector<int>> ver, h;  // 原树 / 虚树邻接表
    vector<int> siz, dep, top, son, parent, dfn, stk;

    VirtualTree(int n) : n(n) {
        ver.resize(n + 1);
        h.resize(n + 1);
        siz.resize(n + 1);
        dep.resize(n + 1);
        top.resize(n + 1);
        son.resize(n + 1);
        parent.resize(n + 1);
        dfn.resize(n + 1);
        stk.resize(n + 1);
    }
    void add(int x, int y) {  // 建立双向边
        ver[x].push_back(y);
        ver[y].push_back(x);
    }
    void dfs1(int x) {
        siz[x] = 1;
        dep[x] = dep[parent[x]] + 1;
        for (auto y : ver[x]) {
            if (y == parent[x]) continue;
            parent[y] = x;
            dfs1(y);
            siz[x] += siz[y];
            if (siz[y] > siz[son[x]]) {
                son[x] = y;
            }
        }
    }
    void dfs2(int x, int up) {
        top[x] = up;
        dfn[x] = ++cnt;
        if (son[x]) dfs2(son[x], up);
        for (auto y : ver[x]) {
            if (y == parent[x] || y == son[x]) continue;
            dfs2(y, y);
        }
    }
    int lca(int x, int y) {
        while (top[x] != top[y]) {
            if (dep[top[x]] > dep[top[y]]) {
                x = parent[top[x]];
            } else {
                y = parent[top[y]];
            }
        }
        return dep[x] < dep[y] ? x : y;
    }
    vector<int> build(vector<int> q) {  // 返回虚树上的全部点（含自动补入的根）
        if (find(q.begin(), q.end(), 1) == q.end()) {
            q.push_back(1);  // 补根：虚树从根连通，dp 才有起点
        }
        sort(q.begin(), q.end(), [&](int a, int b) { return dfn[a] < dfn[b]; });
        vector<int> used;  // dp 完按它清空 h，供多组询问复用
        int tp = 0;        // 单调栈存根到栈顶的链，dfn 递增
        auto push = [&](int x) { stk[++tp] = x; used.push_back(x); };
        auto link = [&](int u, int v) { h[u].push_back(v); h[v].push_back(u); };
        for (int x : q) {
            if (!tp) {
                push(x);
                continue;
            }
            int l = lca(stk[tp], x);
            while (tp > 1 && dep[stk[tp - 1]] >= dep[l]) {
                link(stk[tp - 1], stk[tp]);
                tp--;
            }
            if (dep[stk[tp]] > dep[l]) {
                link(l, stk[tp--]);
            }
            if (stk[tp] != l) {
                push(l);
            }
            push(x);
        }
        while (tp > 1) {
            link(stk[tp - 1], stk[tp]);
            tp--;
        }
        return used;
    }
    void work(int root = 1) {  // 先 work 再 build
        dfs1(root);
        dfs2(root, root);
    }
};
// @book-end

int main() { return 0; }
