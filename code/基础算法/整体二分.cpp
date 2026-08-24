#include <bits/stdc++.h>
using namespace std;
typedef long long i64;
typedef long long ll;
typedef long long LL;
typedef long double ld;
typedef unsigned long long u64;
const int MOD = 998244353;
const int mod = 1000000007;
const int N = 1000005;
const int M = 2000005;
const double eps = 1e-8;
const double PI = acos(-1.0);
int ans[M];
int n;
int ql;
int qr;

// @book-begin
int cal(auto x) {  // todo: 以 mid = x 为判定标准，计算当前区间内"答案落在右儿子"的询问数
    return 0;
}

void solve(int ql, int qr, int l, int r) {
    // 回答第 ql..qr 个询问，此时其答案都在值域 [l, r] 内
    if (ql > qr)return;
    if (l > r)return;
    if (l == r) {
        for (int q = ql;q <= qr;++q)ans[q] = l;
        return;
    }
    int mid = l + r + 1 >> 1;
    int cnt = cal(mid);
    solve(std::max(ql, cnt + 1), qr, l, mid - 1);
    solve(ql, std::min(qr, cnt), mid, r);
}

void solve() {
    // input
    // TODO: 原骨架此处为 solve(ql, qr, 0, n, zf)，实参/形参数目不符，重构边界后需自行核对
    solve(ql, qr, 0, n);
    // todo
}
// @book-end

int main() { return 0; }
