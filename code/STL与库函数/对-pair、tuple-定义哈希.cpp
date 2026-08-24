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
const double eps = 1e-8;
const double PI = acos(-1.0);


// @book-begin
// pair 的哈希
struct hash_pair {
    template<typename T1, typename T2>
    size_t operator()(const pair<T1, T2> &p) const {
        // 异或会把 <a,b> 与 <b,a> 混为同一个桶（只影响效率不影响正确性），可换成 std::hash 的组合
        return (hash<T1>()(p.first) << 1) ^ hash<T2>()(p.second);
    }
};
unordered_set<pair<int, int>, hash_pair> S;

// tuple 的哈希（pair 拿 <T1,T2> 构造，可直接复用 hash_pair）
struct hash_tuple {
    template<typename... Ts>
    size_t operator()(const tuple<Ts...> &t) const {
        return apply([](const Ts &...xs) {
            return (hash<Ts>()(xs) ^ ...);  // 折叠表达式，C++17
        }, t);
    }
};
unordered_map<tuple<int, int, int>, int, hash_tuple> M;
// @book-end

int main() { return 0; }
