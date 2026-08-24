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
    // stoi直接使用
    cout << stoi("12") << endl;

    // stoi转换进制，参数为待转换字符串、起始位置、进制。radix 传 0 表示按前缀自动识别。
    // int stoi(string value, int st, int radix);
    cout << stoi("1010", 0, 2) << endl; /*10*/
    cout << stoi("c", 0, 16) << endl; /*12*/
    cout << stoi("0x3f3f3f3f", 0, 0) << endl; /*1061109567*/

    // 长整型函数名stoll，最高支持到long long型上限2^63。stoull、stod、stold同理。
}
// @book-end
