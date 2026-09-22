#include "../contest.hpp"

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
    void work(int root = 1) {
        assert(1 <= root && root <= n);
        dfn = 0;
        parent[root] = 0;
        dep[root] = 1;
        vector<int> order{root};
        for (int i = 0; i < order.size(); ++i) {
            int x = order[i];
            for (int y : ver[x]) {
                if (y == parent[x]) continue;
                parent[y] = x;
                dep[y] = dep[x] + 1;
                order.push_back(y);
            }
        }
        for (int i = int(order.size()) - 1; i >= 0; --i) {  // 子节点先于父节点
            int x = order[i];
            siz[x] = 1;
            son[x] = 0;
            for (int y : ver[x]) {
                if (y == parent[x]) continue;
                siz[x] += siz[y];
                if (siz[y] > siz[son[x]]) son[x] = y;
            }
        }
        order.assign(1, root);  // 复用为 DFS 栈，重儿子最后入栈、最先访问
        top[root] = root;
        while (!order.empty()) {
            int x = order.back();
            order.pop_back();
            in[x] = ++dfn;
            for (auto it = ver[x].rbegin(); it != ver[x].rend(); ++it) {
                int y = *it;
                if (y == parent[x] || y == son[x]) continue;
                top[y] = y;
                order.push_back(y);
            }
            if (son[x]) {
                top[son[x]] = top[x];
                order.push_back(son[x]);
            }
        }
    }
    int lca(int u, int v) const {
        while (top[u] != top[v]) {
            if (dep[top[u]] < dep[top[v]]) {
                swap(u, v);
            }
            u = parent[top[u]];
        }
        return dep[u] < dep[v] ? u : v;
    }
    int dist(int u, int v) const {  // 边数
        return dep[u] + dep[v] - 2 * dep[lca(u, v)];
    }
    template<class F>
    void path(int u, int v, F &&op) const {  // 点路径，闭区间
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
    void subtree(int u, F &&op) const {
        op(in[u], in[u] + siz[u] - 1);
    }
};
// @book-end
