#include "../contest.hpp"

// @book-begin
// 有向无环图
// extend(p, c) 从最后一个节点 p 续加字符 c，返回新的 last；连续放多个串时把 last 复位为 1 即广义 SAM。
struct SuffixAutomaton {
    static constexpr int N = 1e6;
    static constexpr int root = 1;
    struct node {
        int len, link, nxt[26];
    } t[N << 1];
    int cntNodes;
    SuffixAutomaton() {
        cntNodes = 1;
        t[0] = t[1] = {};
        fill(t[0].nxt, t[0].nxt + 26, 1);
        t[0].len = -1;
    }
    int extend(int p, int c) {
        if (t[p].nxt[c]) {
            int q = t[p].nxt[c];
            if (t[q].len == t[p].len + 1) {
                return q;
            }
            int r = ++cntNodes;
            assert(r < (N << 1));
            t[r] = {};
            t[r].len = t[p].len + 1;
            t[r].link = t[q].link;
            copy(t[q].nxt, t[q].nxt + 26, t[r].nxt);
            t[q].link = r;
            while (t[p].nxt[c] == q) {
                t[p].nxt[c] = r;
                p = t[p].link;
            }
            return r;
        }
        int cur = ++cntNodes;
        assert(cur < (N << 1));
        t[cur] = {};
        t[cur].len = t[p].len + 1;

        while (!t[p].nxt[c]) {
            t[p].nxt[c] = cur;
            p = t[p].link;
        }
        t[cur].link = extend(p, c);
        return cur;
    }
};
// @book-end
