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

struct HLD {
    vector<int> in, dep;
    int lca(int, int);
};

// @book-begin
struct VirtualTree {
    int n;
    vector<vector<int>> h;
    vector<int> stk;

    VirtualTree(int n) : n(n), h(n + 1), stk(n + 1) {}
    vector<int> build(vector<int> q, HLD &t) {  // q 按值：内部要补根、按 dfn 排序；返回虚树上的全部点（含自动补入的根）
        if (find(q.begin(), q.end(), 1) == q.end()) {
            q.push_back(1);  // 补根：虚树从根连通，dp 才有起点
        }
        sort(q.begin(), q.end(), [&](int a, int b) { return t.in[a] < t.in[b]; });
        vector<int> used;  // dp 完按它清空 h，供多组询问复用
        int tp = 0;
        auto push = [&](int x) { stk[++tp] = x; used.push_back(x); };
        auto link = [&](int u, int v) { h[u].push_back(v); h[v].push_back(u); };
        for (int x : q) {
            if (!tp) {
                push(x);
                continue;
            }
            int l = t.lca(stk[tp], x);
            while (tp > 1 && t.dep[stk[tp - 1]] >= t.dep[l]) {
                link(stk[tp - 1], stk[tp]);
                tp--;
            }
            if (t.dep[stk[tp]] > t.dep[l]) {
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
};
// @book-end

int main() { return 0; }
