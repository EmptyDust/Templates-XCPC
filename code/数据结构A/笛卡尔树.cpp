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

// @book-begin
int n, top;
int nums[M], ls[M], rs[M], stk[M];  // M 见 contest.hpp（按题目改）

int main() {
    cin >> n;
    for (int i = 0;i < n;++i)cin >> nums[i];
    for (int i = 0;i < n;++i)rs[i] = -1;
    for (int i = 0;i < n;++i)ls[i] = -1;
    top = 0;
    for (int i = 0; i < n; i++) {
        int k = top;
        while (k > 0 && nums[stk[k - 1]] > nums[i]) k--;
        if (k) rs[stk[k - 1]] = i;  // rs代表笛卡尔树每个节点的右儿子
        if (k < top) ls[i] = stk[k];  // ls代表笛卡尔树每个节点的左儿子
        stk[k++] = i;
        top = k;
    }
}
// @book-end
