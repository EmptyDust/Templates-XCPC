#include "../contest.hpp"
int n, m;

// @book-begin
#include <bits/stdc++.h>
using namespace std;
using i64 = long long;
mt19937_64 rng(chrono::steady_clock::now().time_since_epoch().count());
i64 rnd(i64 L, i64 R) {
    uniform_int_distribution<i64> dist(L, R);
    return dist(rng);
}
int main() {
    // int n = rnd(1, 1000);
    // cout << n << '\n';
}
// @book-end
