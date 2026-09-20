#include "../contest.hpp"

// @book-begin
int main() {
    int n;
    cin >> n;
    vector<int> val;
    for (int i = 0; i < n; ++i) {
        int x;
        cin >> x;
        auto it = lower_bound(val.begin(), val.end(), x);  // 严格递增；非递减改为 upper_bound
        if (it == val.end()) val.push_back(x);
        else *it = x;
    }
    cout << val.size() << '\n';
}
// @book-end
