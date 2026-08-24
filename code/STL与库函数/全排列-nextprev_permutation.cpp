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
int main() {
    int n;
    cin >> n;
    vector<int> a(n);
    // iota(a.begin(), a.end(), 1);
    for (auto &it : a) cin >> it;
    sort(a.begin(), a.end());  // 必须先排序，才能按字典序生成完整全排列

    do {
        for (auto it : a) cout << it << " ";
        cout << endl;
    } while (next_permutation(a.begin(), a.end()));
}
// @book-end
