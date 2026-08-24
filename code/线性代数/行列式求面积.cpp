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

struct LB {  // Linear Basis
    using i64 = long long;
    const int BASE = 63;  // 按值域改；这里用到 bit 0..62
    std::vector<i64> d, p;
    int cnt, flag;

    LB() {
        d.resize(BASE + 1);
        p.resize(BASE + 1);
        cnt = flag = 0;
    }
    bool insert(i64 val) {
        for (int i = BASE - 1; i >= 0; i--) {
            if (val & (1ll << i)) {
                if (!d[i]) {
                    d[i] = val;
                    return true;
                }
                val ^= d[i];
            }
        }
        flag = 1; //可以异或出0
        return false;
    }
    bool check(i64 val) { // 判断 val 是否能被异或得到
        for (int i = BASE - 1; i >= 0; i--) {
            if (val & (1ll << i)) {
                if (!d[i]) {
                    return false;
                }
                val ^= d[i];
            }
        }
        return true;
    }
    i64 ask_max() {
        i64 res = 0;
        for (int i = BASE - 1; i >= 0; i--) {
            if ((res ^ d[i]) > res) res ^= d[i];
        }
        return res;
    }
    i64 ask_min() {
        if (flag) return 0;  // 特判 0
        for (int i = 0; i <= BASE - 1; i++) {
            if (d[i]) return d[i];
        }
        return 0; // 空基；原来没有返回值
    }
    void rebuild() {  // 第k小值独立预处理，把 d 消成对角再压进 p[0..cnt)
        cnt = 0;
        for (int i = BASE - 1; i >= 0; i--) {
            for (int j = i - 1; j >= 0; j--) {
                if (d[i] & (1ll << j)) d[i] ^= d[j];
            }
        }
        for (int i = 0; i <= BASE - 1; i++) {
            if (d[i]) p[cnt++] = d[i];
        }
    }
    i64 kthquery(i64 k) { // 查询能被异或得到的第 k 小值, 如不存在则返回 -1
        if (flag) k--;  // 特判 0, 如果不需要 0, 直接删去
        if (!k) return 0;
        i64 res = 0;
        if (k >= (1ll << cnt)) return -1;
        for (int i = 0; i < cnt; i++) {  // 原来按下标 BASE 取 p[i]，p 只填了 [0,cnt)
            if (k & (1LL << i)) res ^= p[i];
        }
        return res;
    }
    void Merge(const LB &b) {  // 合并两个线性基
        for (int i = BASE - 1; i >= 0; i--) {
            if (b.d[i]) {
                insert(b.d[i]);
            }
        }
    }
};

// @book-begin
int main(){
    float num[6];
    for(int i = 0; i < 6; i++)
        cin >> num[i];
    float sum = 0.0;
    sum = 0.5*(num[0]*num[3]+num[2]*num[5]+num[4]*num[1]-num[0]*num[5]-num[2]*num[1]-num[4]*num[3]);
    cout << "三角形的面积为: ";
    sum == 0 ? cout << "Impossible" : cout <<sum;  // 共线面积为 0；float 比较用 == 不稳，可改 sign
    return 0;
}
// @book-end
