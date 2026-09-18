#include <bits/stdc++.h>
using namespace std;

// @book-begin
const int N = 1e6 + 7;  // 按最大石子数改
int n, m, a[N], num[N];  // n 堆数, m 种取法
int sg(int x) {
    if (num[x] != -1) return num[x];  // -1 未算，Solve 里 memset
    unordered_set<int> S;  // 后继局面的 SG 集合
    for (int i = 1; i <= m; ++ i)
        if(x >= a[i])
            S.insert(sg(x - a[i]));  // 取走 a[i] 颗

    for (int i = 0; ; ++ i)  // mex：最小未出现的非负整数
        if (S.count(i) == 0)
            return num[x] = i;
}
void Solve() {
    cin >> m;
    for (int i = 1; i <= m; ++ i) cin >> a[i];  // 每次可取的数量
    cin >> n;

    int ans = 0; memset(num, -1, sizeof num);  // 多测须每组清空
    for (int i = 1; i <= n; ++ i) {
        int x; cin >> x;
        ans ^= sg(x); // 各堆独立，异或合并
    }

    if (ans == 0) cout << "no" << '\n';  // 输出串按题意改
    else cout << "yes" << '\n';
}
// @book-end

int main() {
    Solve();
    return 0;
}
