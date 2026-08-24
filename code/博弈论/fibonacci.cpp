#include <bits/stdc++.h>
using namespace std;

// @book-begin
long long fib[100] = {1, 2};  // 原来 int，fib[47] 已超 INT_MAX
map<long long, bool> mp;  // 是否斐波那契数
void Force() {  // 预处理，Solve 前调用一次
  for (int i = 2; i <= 86; ++ i) fib[i] = fib[i - 1] + fib[i - 2];  // 86 项盖住约 9e17
    for (int i = 0; i <= 86; ++ i) mp[fib[i]] = 1;
}
void Solve() {
    int n; cin >> n;  // n 超过 int 时改 long long
    if (mp[n] == 1) cout << "lose\n";  // 斐波那契数先手必败
    else cout << "win\n";
}
// @book-end

int main() {
    Force();
    Solve();
    return 0;
}
