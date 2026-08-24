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
    // atoi直接使用，空字符返回0，允许正负符号，数字字符前有其他字符返回0，数字字符前有空白字符自动去除
    cout << atoi("12") << endl;
    cout << atoi("   12") << endl; /*12*/
    cout << atoi("-12abc") << endl; /*-12*/
    cout << atoi("abc12") << endl; /*0*/

    // 长整型函数名atoll，最高支持到long long型上限2^63。
}
// @book-end
