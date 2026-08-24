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

struct Tree {
    int n;
    vector<vector<int>> ver;
    Tree(int n) {
        this->n = n;
        ver.resize(n + 1);
    }
    void add(int x, int y) {
        ver[x].push_back(y);
        ver[y].push_back(x);
    }
    int getlen(int root) { // 获取x所在树的直径
        map<int, int> dep; // map用于优化输入为森林时的深度计算，亦可用vector
        function<void(int, int)> dfs = [&](int x, int fa) -> void {
            for (auto y : ver[x]) {
                if (y == fa) continue;
                dep[y] = dep[x] + 1;
                dfs(y, x);
            }
            if (dep[x] > dep[root]) {
                root = x;
            }
        };
        dfs(root, 0);
        int st = root; // 记录直径端点

        dep.clear();
        dfs(root, 0);
        int ed = root; // 记录直径另一端点

        return dep[root];
    }
};
struct HLD {
    int n, idx;
    vector<vector<int>> ver;
    vector<int> siz, dep;
    vector<int> top, son, parent;

    HLD(int n) {
        this->n = n;
        ver.resize(n + 1);
        siz.resize(n + 1);
        dep.resize(n + 1);

        top.resize(n + 1);
        son.resize(n + 1);
        parent.resize(n + 1);
    }
    void add(int x, int y) { // 建立双向边
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
    int clac(int x, int y) { // 查询两点间距离
        return dep[x] + dep[y] - 2 * dep[lca(x, y)];
    }
    void work(int root = 1) {  // 在此初始化
        dfs1(root);
        dfs2(root, root);
    }
};
struct LCA {
    int n, LOG;
    std::vector<int> l, r, id, dep, parent, lg;
    std::vector<std::vector<int>> st;
    const std::vector<std::vector<int>>& adj;
    int tot = 0;

    // 构造函数：传入节点数 n (1-index)、邻接表 adj、根节点 root
    LCA(int _n, const std::vector<std::vector<int>>& _adj, int root)
        : n(_n), adj(_adj)
    {
        LOG = 32 - __builtin_clz(n);  // ⌊log2(n)⌋ 的上界
        l.assign(n + 1, 0);
        r.assign(n + 1, 0);
        id.assign(n + 1, 0);
        dep.assign(n + 1, 0);
        parent.assign(n + 1, 0);
        lg.assign(n + 2, 0);

        // 预处理对数
        for (int i = 2; i <= n; i++)
            lg[i] = lg[i >> 1] + 1;

        // 1) 建立 dfs 序，记录 l[u], r[u], id[]
        dfs(root, 0);

        // 2) 构建 ST 表用于 RMQ
        st.assign(LOG + 1, std::vector<int>(n + 2));
        for (int i = 1; i <= n; i++)
            st[0][i] = id[i];

        for (int j = 1; j <= LOG; j++) {
            for (int i = 1; i + (1 << j) - 1 <= n; i++) {
                int x = st[j - 1][i];
                int y = st[j - 1][i + (1 << (j - 1))];
                st[j][i] = (dep[x] < dep[y] ? x : y);
            }
        }
    }

    // 返回节点 u 在序列中的位置 l[u], 以及构造 parent, dep
    void dfs(int u, int p) {
        parent[u] = p;
        dep[u] = dep[p] + 1;
        l[u] = ++tot;
        id[tot] = u;
        for (int v : adj[u]) {
            if (v == p) continue;
            dfs(v, u);
        }
        r[u] = tot;
    }

    // O(1) 查询 LCA
    int lca(int u, int v) const {
        // 如果 u 是 v 的祖先，直接返回 u；反之同理
        if (l[u] <= l[v] && r[u] >= r[v]) return u;
        if (l[v] <= l[u] && r[v] >= r[u]) return v;

        if (l[u] > l[v]) std::swap(u, v);

        int L = l[u], R = l[v];
        int k = lg[R - L + 1];
        int x1 = st[k][L], x2 = st[k][R - (1 << k) + 1];
        int x = (dep[x1] < dep[x2] ? x1 : x2);

        return parent[x];
    }
};

// @book-begin
// 代码摘自原文，结点是从 0 标号的
vector<vector<int>> adj;

vector<int> pruefer_code() {
  int n = adj.size();
  set<int> leafs;
  vector<int> degree(n);
  vector<bool> killed(n, false);
  for (int i = 0; i < n; i++) {
    degree[i] = adj[i].size();
    if (degree[i] == 1) leafs.insert(i);
  }

  vector<int> code(n - 2);
  for (int i = 0; i < n - 2; i++) {
    int leaf = *leafs.begin();
    leafs.erase(leafs.begin());
    killed[leaf] = true;
    int v;
    for (int u : adj[leaf])
      if (!killed[u]) v = u;
    code[i] = v;
    if (--degree[v] == 1) leafs.insert(v);
  }
  return code;
}
// @book-end

int main() { return 0; }
