#include <bits/stdc++.h>
using i64 = long long;
constexpr int MAXN = 1e6 + 10, inf = 1e9, mod = 1e9 + 7;
using pt = std::pair<int, int>;

int stk[MAXN], ls[MAXN], rs[MAXN], h[MAXN];
signed main()
{
    std::ios::sync_with_stdio(false);
    std::cin.tie(0), std::cout.tie(0);
    int n;
    std::cin >> n;
    for (int i = 1; i <= n; ++i)
        std::cin >> h[i];
    int top = 1;
    for (int i = 1; i <= n; i++)
    {
        int k = top;
        while (k > 0 && h[stk[k]] > h[i])
            k--;
        if (k)
            rs[stk[k]] = i; // rs代表笛卡尔树每个节点的右儿子
        if (k < top)
            ls[i] = stk[k + 1]; // ls代表笛卡尔树每个节点的左儿子
        stk[++k] = i;
        top = k;
    }
    for (int i = 1; i <= n; ++i)
    {
        std::cout << i << ' ' << ls[i] << ' ' << rs[i] << "\n";
    }
    return 0;
}