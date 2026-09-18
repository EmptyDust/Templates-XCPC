#include <bits/stdc++.h>
using namespace std;

const int N = 1005;
vector<int> ver[N];  // 邻接表，须先建图（书中正文说明）

int main() {
// @book-begin
    auto dfs = [&](auto self, int x, int fa) -> int {  // 返回 R(x)=SG(x)+1
        int res = 0;  // res 为孩子 R 的异或
        for (auto y : ver[x]) {  // ver 为邻接表，须先建图
            if (y == fa) continue;
            res ^= self(self, y, x);
        }
        return res + 1;  // 叶子没有孩子，返回 1 ⇔ SG=0
    };
    cout << (dfs(dfs, 1, 0) == 1 ? "Bob\n" : "Alice\n");  // ==1 即根 SG=0，先手必败
// @book-end
    return 0;
}
