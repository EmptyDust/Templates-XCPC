#include "../contest.hpp"

// @book-begin
std::vector<int> get_next(const std::string& t) {
    std::vector<int> next(t.size() + 1);  // 多开一位：循环里 i 先自增到 size 再写 next[i]，否则越界
    next[0] = -1;  // 哨兵；next[i] 为前缀 t[0..i-1] 的最长 border 长度
    for (int i = 0, j = -1; i < (int)t.size();) {
        if (j == -1 || t[i] == t[j]) {
            ++i;
            ++j;
            next[i] = j;
        }
        else
            j = next[j];
    }
    return next;
}
// @book-end
