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
template<class... A> int itoa(A&&...);

// @book-begin
int main() {
    // 【不建议使用】itoa允许你将整数转换成任意进制的字符串，参数为待转换整数、目标字符数组、进制。
    // char* itoa(int value, char* string, int radix);
    char ans[10] = {};
    itoa(12, ans, 2);
    cout << ans << endl; /*1100*/

    // 长整型函数名ltoa，最高支持到int型上限2^31。ultoa同理。
}
// @book-end
