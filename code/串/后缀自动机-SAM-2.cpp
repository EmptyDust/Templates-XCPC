#include "../contest.hpp"

// @book-begin
struct SAM {
    struct node {
        int len, link, endpos, size;
        std::map<char, int> next;
        node() {
            len = link = endpos = -1;
            size = 0;
            next = std::map<char, int>();
        }
    };
    std::vector<node> nodes;
    int last;
    int n;

    SAM(const std::string& s) {
        n = 0;
        nodes.reserve(2 * s.size());
        nodes.assign(1, node());
        nodes[0].len = 0;
        nodes[0].link = -1;
        last = 0;
        for (int i = 0;i < s.size();++i) {
            extend(s[i], i + 1);
        }
    }

    void extend(char c, int pos) {
        assert(pos == n + 1);
        n = pos;
        int cur = nodes.size();
        nodes.emplace_back();
        nodes[cur].len = nodes[last].len + 1;
        int p = last;
        while (p != -1 && !nodes[p].next.count(c)) {
            nodes[p].next[c] = cur;
            p = nodes[p].link;
        }
        if (p == -1) {
            nodes[cur].link = 0;
        }
        else {
            int q = nodes[p].next[c];
            if (nodes[p].len + 1 == nodes[q].len) {
                nodes[cur].link = q;
            }
            else {
                int clone = nodes.size();
                nodes.emplace_back();
                nodes[clone].len = nodes[p].len + 1;
                nodes[clone].link = nodes[q].link;
                nodes[clone].next = nodes[q].next;
                nodes[clone].endpos = nodes[q].endpos;
                while (p != -1 && nodes[p].next[c] == q) {
                    nodes[p].next[c] = clone;
                    p = nodes[p].link;
                }
                nodes[q].link = nodes[cur].link = clone;
            }
        }
        nodes[cur].endpos = pos;
        nodes[cur].size = 1;
        last = cur;
    }

    vector<int> countOccurrences() const {  // 不修改原始 size，允许重复统计及继续 extend
        vector<int> count(n + 1), order(nodes.size()), result(nodes.size());
        for (const auto &v : nodes) ++count[v.len];
        for (int i = 1; i <= n; ++i) count[i] += count[i - 1];
        for (int i = 0; i < nodes.size(); ++i) {
            order[--count[nodes[i].len]] = i;
            result[i] = nodes[i].size;
        }
        for (int i = int(order.size()) - 1; i > 0; --i) {
            int v = order[i];
            result[nodes[v].link] += result[v];
        }
        return result;
    }

    void debug() const {
        for (const auto &x : nodes) {
            std::cerr << x.len << ' ';
            std::cerr << x.link << ' ';
            std::cerr << x.endpos << ' ';
            std::cerr << x.size << ' ';
            std::cerr << '\n';
        }
    }
};
// @book-end
