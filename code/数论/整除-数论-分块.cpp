#include <bits/stdc++.h>
using namespace std;
typedef long long i64;
typedef long long ll;
typedef long long LL;
typedef long double ld;
typedef unsigned long long u64;
const int MOD = 998244353;
const int mod = 1000000007;
const int M = 2000005;
const double eps = 1e-8;
const double PI = acos(-1.0);

std::vector<int> minp, primes;

void sieve(int n) {
    minp.assign(n + 1, 0);
    primes.clear();

    for (int i = 2; i <= n; i++) {
        if (minp[i] == 0) {
            minp[i] = i;
            primes.push_back(i);
        }

        for (auto p : primes) {
            if (i * p > n) {
                break;
            }
            minp[i * p] = p;
            if (p == minp[i]) {
                break;
            }
        }
    }
}
int exgcd(int a, int b, int &x, int &y) {
    if (!b) {
        x = 1, y = 0;
        return a;
    }
    int d = exgcd(b, a % b, y, x);
    y -= a / b * x;
    return d;
}
i64 euclidean(i64 a, i64 b, i64 c, i64 n) {
    // sum{0, n}(floor((a * i + b) / c))
    i64 n2 = n * (n + 1) / 2;
    if (a >= c || b >= c)
        return euclidean(a % c, b % c, c, n) + (a / c) * n2 + (b / c) * (n + 1);
    i64 m = (a * n + b) / c;
    if (!m) return 0;
    return m * n - euclidean(c, c - b - 1, a, m - 1);
}
int phi(int n) {  //求解 phi(n)
    int ans = n;
    for(int i = 2; i <= n / i; i ++) { //注意，这里要写 n / i ，以防止 int 型溢出风险和 sqrt 超时风险
        if(n % i == 0) {
            ans = ans / i * (i - 1);
            while(n % i == 0) n /= i;
        }
    }
    if(n > 1) ans = ans / n * (n - 1); //特判 n 为质数的情况
    return ans;
}
bool is_prime(int n) {
    if (n < 2) return false;
    for (int i = 2; i <= n / i; i++) {
        if (n % i == 0) return false;
    }
    return true;
}
i64 xor_n(i64 n) {
    if (n % 4 == 1) return 1;
    else if (n % 4 == 2) return n + 1;
    else if (n % 4 == 3) return 0;
    else return n;
}
const int N = 40;  // 按题目矩阵大小改
using mat = std::array<std::array<i64, N + 1>, N + 1>;
mat operator*(const mat& a, const mat& b) {
    mat ans{};
    for (int i = 1; i <= N; i++) {
        for (int j = 1; j <= N; j++) {
            for (int k = 1; k <= N; k++)
                ans[i][j] = (ans[i][j] + a[i][k] * b[k][j]) % mod;
        }
    }
    return ans;
}

mat MatPow(mat a, i64 b) {
    mat ans{};
    for (int i = 1;i <= N;i++) ans[i][i] = 1;
    while (b) {
        if (b & 1) ans = ans * a;
        b >>= 1;
        a = a * a;
    }
    return ans;
}

// @book-begin
void solve() {
    i64 n; cin >> n;
    i64 ans = 0;
    for (i64 i = 1, j; i <= n; i = j + 1) {
        j = n / (n / i);
        ans += (i64)(j - i + 1) * (n / i);
    }
    cout << ans << "\n";
}
int main() {
    int T; cin >> T;
    while (T--) solve();
}
// @book-end
