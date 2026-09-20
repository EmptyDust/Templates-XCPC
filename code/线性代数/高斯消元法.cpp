#include "../contest.hpp"

// @book-begin
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
        return 0; // 空基
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
    i64 kthquery(u64 k) { // 非空子集的不同异或值，第 k 小，k 从 1 开始
        if (k == 0) return -1;
        if (flag) --k;
        if (!k) return 0;
        i64 res = 0;
        if (k >= (1ULL << cnt)) return -1;
        for (int i = 0; i < cnt; i++) {  // p 只填了 [0,cnt)，不能枚举到 BASE
            if (k & (1LL << i)) res ^= p[i];
        }
        return res;
    }
    void Merge(const LB &b) {  // 合并后需重新 rebuild 才能查询第 k 小
        flag |= b.flag;
        for (int i = BASE - 1; i >= 0; i--) {
            if (b.d[i]) {
                insert(b.d[i]);
            }
        }
    }
};
// @book-end
