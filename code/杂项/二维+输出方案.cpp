#include "../contest.hpp"

// @book-begin
int main() {
    int n;
    cin >> n;
    vector<array<int, 3>> in(n + 1);
    for (int i = 1; i <= n; i++) {
        cin >> in[i][0] >> in[i][1];
        in[i][2] = i;
    }
    sort(in.begin() + 1, in.end(), [&](auto x, auto y) {
        if (x[0] != y[0]) return x[0] < y[0];
        return x[1] > y[1];
    });

    vector<int> val, idx, pre(n + 1);
    for (int i = 1; i <= n; i++) {
        auto [x, y, z] = in[i];
        int it = lower_bound(val.begin(), val.end(), y) - val.begin();  // low/upp: 严格/非严格递增
        if (it >= val.size()) {  // 新增一堆
            pre[z] = idx.empty() ? 0 : idx.back();
            val.push_back(y);
            idx.push_back(z);
        } else {  // 更新对应位置元素
            pre[z] = it == 0 ? 0 : idx[it - 1];
            val[it] = y;
            idx[it] = z;
        }
    }

    vector<int> ans;
    for (int i = idx.empty() ? 0 : idx.back(); i != 0; i = pre[i]) {
        ans.push_back(i);
    }
    reverse(ans.begin(), ans.end());
    cout << ans.size() << "\n";
    for (auto it : ans) {
        cout << it << " ";
    }
}
// @book-end
