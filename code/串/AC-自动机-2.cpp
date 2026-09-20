#include "../contest.hpp"

// @book-begin
// 第二个封装：fail 树 + 出现次数统计。
// add(s) 返回 s 结尾节点；work(s) 先按文本走自动机，再在 fail 树上自底向上聚合，
// 返回每个节点（模式串）在文本中的出现次数，常用于"每个模板串各出现几次"。
struct AhoCorasick {
    static constexpr int ALPHABET = 26;
    struct Node {
        int len;
        int link;
        std::array<int, ALPHABET> next;
        Node() : len{ 0 }, link{ 0 }, next{} {}
    };

    std::vector<Node> t;
    vector<int> order;
    bool built = false;

    AhoCorasick() {
        init();
    }

    void init() {
        built = false;
        order.clear();
        t.assign(2, Node());
        t[0].next.fill(1);
        t[0].len = -1;
    }

    int newNode() {
        t.emplace_back();
        return t.size() - 1;
    }

    int add(const std::string& a) {
        assert(!built && !a.empty());
        int p = 1;
        for (auto c : a) {
            int x = c - 'a';
            if (t[p].next[x] == 0) {
                t[p].next[x] = newNode();
                t[t[p].next[x]].len = t[p].len + 1;
            }
            p = t[p].next[x];
        }
        return p;
    }

    void get_fail() {
        if (built) return;
        built = true;
        std::queue<int> q;
        q.push(1);

        while (!q.empty()) {
            int x = q.front();
            q.pop();
            order.push_back(x);

            for (int i = 0; i < ALPHABET; i++) {
                if (t[x].next[i] == 0) {
                    t[x].next[i] = t[t[x].link].next[i];
                }
                else {
                    t[t[x].next[i]].link = t[t[x].link].next[i];
                    q.push(t[x].next[i]);
                }
            }
        }
    }

    std::vector<int> work(const std::string &s) {
        get_fail();
        int p = 1;
        std::vector<int> f(t.size());
        for (auto c : s) {
            p = next(p, c - 'a');
            f[p]++;
        }

        for (int i = int(order.size()) - 1; i > 0; --i) {
            int v = order[i];
            f[link(v)] += f[v];
        }
        return f;
    }

    int next(int p, int x) const {
        return t[p].next[x];
    }

    int link(int p) const {
        return t[p].link;
    }

    int len(int p) const {
        return t[p].len;
    }

    int size() const {
        return t.size();
    }
};
// @book-end
