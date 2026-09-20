#include "../contest.hpp"
#include "kmp.cpp"

// @book-begin
bool kmp(const std::string& s, const std::string& t) {
    if (t.empty()) return true;
    if (t.length() > s.length())return false;
    auto next = get_next(t);

    for (int i = 0, j = 0; i < (int)s.size() && j < (int)t.size();) {
        if (j == -1 || s[i] == t[j]) {
            ++i;
            ++j;
        }
        else
            j = next[j];
        if (j == (int)t.size())return true;
    }
    return false;
}
// @book-end
