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
int f[20];
void jie_cheng(int n) {  // 打出1-n的阶乘表
    f[0] = f[1] = 1; // 0的阶乘为1
    for (int i = 2; i <= n; i++) f[i] = f[i - 1] * i;
}
string str;  // kangtuo 读这个全局串
int kangtuo() {
    int ans = 1;  // 注意，因为 12345 是算作0开始计算的，最后结果要把12345看作是第一个
    int len = str.length();
    for (int i = 0; i < len; i++) {
        int tmp = 0; // 用来计数的
        // 计算str[i]是第几大的数，或者说计算有几个比他小的数
        for (int j = i + 1; j < len; j++)
            if (str[i] > str[j]) tmp++;
        ans += tmp * f[len - i - 1];
    }
    return ans;
}
int main() {
    jie_cheng(10);
    str = "52413";  // 原来又定义了局部 string str，kangtuo 读的是全局空串
    cout << kangtuo() << endl;
}
// @book-end
