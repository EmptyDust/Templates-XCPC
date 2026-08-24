#include <bits/stdc++.h>
using namespace std;

// @book-begin
const double lorry = (sqrt(5.0) + 1.0) / 2.0;  // 黄金分割 (1+√5)/2
//const double lorry = 1.618033988749894848204586834; // 堆更大时换这段高精度常数
void Solve() {
    int n, m; cin >> n >> m;
    if (n < m) swap(n, m);  // 约定 n >= m
    double x = n - m;  // 冷局面差为 k，小堆应等于 floor(k * φ)
    if ((int)(lorry * x) == m) cout << "lose\n";  // 落在冷局面，先手必败
    else cout << "win\n";
}
// @book-end

int main() {
    Solve();
    return 0;
}
