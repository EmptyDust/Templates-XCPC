#include "../contest.hpp"

// @book-begin
// Trie+Kmp，多模式串匹配
struct ACAutomaton {
    static constexpr int N = 1e6 + 10;
    int ch[N][26], fail[N], cntNodes;
    int cnt[N];
    bool built = false;
    ACAutomaton() {
        cntNodes = 1;
        fill(ch[1], ch[1] + 26, 0);
        fail[1] = cnt[1] = cnt[0] = 0;
    }
    void insert(const string &s) {
        assert(!built && !s.empty());
        int u = 1;
        for (auto c : s) {
            int &v = ch[u][c - 'a'];
            if (!v) {
                v = ++cntNodes;
                assert(v < N);
                fill(ch[v], ch[v] + 26, 0);
                cnt[v] = fail[v] = 0;
            }
            u = v;
        }
        cnt[u]++;
    }
    void build() {
        if (built) return;
        built = true;
        fill(ch[0], ch[0] + 26, 1);  // 0 号虚拟节点所有边指向根，便于 fail 转移
        queue<int> q;
        q.push(1);
        while (!q.empty()) {
            int u = q.front();
            q.pop();
            for (int i = 0; i < 26; i++) {
                int &v = ch[u][i];
                if (!v)
                    v = ch[fail[u]][i];
                else {
                    fail[v] = ch[fail[u]][i];
                    q.push(v);
                }
            }
        }
    }
    i64 query(const string &t) {
        build();
        vector<bool> seen(cntNodes + 1);
        i64 ans = 0;
        int u = 1;
        for (auto c : t) {
            u = ch[u][c - 'a'];
            // 同一文本内每个模式只计一次；重复插入的模式按插入次数计
            for (int v = u; v && !seen[v]; v = fail[v]) {
                ans += cnt[v];
                seen[v] = true;
            }
        }
        return ans;
    }
};
// @book-end
