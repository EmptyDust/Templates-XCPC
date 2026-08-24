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


struct Line {
  i64 a, b, r;
  bool operator<(Line l) { return pair(a, b) > pair(l.a, l.b); }
  bool operator<(i64 x) { return r < x; }
};
struct Lines : vector<Line> {
  static constexpr i64 inf = numeric_limits<i64>::max();
  Lines(i64 a, i64 b) : vector<Line>{{a, b, inf}} {}
  Lines(vector<Line>& lines) {
    if (not ranges::is_sorted(lines, less())) ranges::sort(lines, less());
    for (auto [a, b, _] : lines) {
      for (; not empty(); pop_back()) {
        if (back().a == a) continue;
        i64 da = back().a - a, db = b - back().b;
        back().r = db / da - (db < 0 and db % da);
        if (size() == 1 or back().r > end()[-2].r) break;
      }
      emplace_back(a, b, inf);
    }
  }
  Lines operator+(Lines& lines) {
    vector<Line> res(size() + lines.size());
    ranges::merge(*this, lines, res.begin(), less());
    return Lines(res);
  }
  i64 min(i64 x) {
    auto [a, b, _] = *lower_bound(begin(), end(), x, less());
    return a * x + b;
  }
};

// @book-begin
using i64 = long long;
const double PI = acos(-1);
struct FFT_mul {
    std::vector<std::complex<double>> A, B;
    std::vector<i64> ret;
    std::vector<std::complex<double>> roots;  // 预处理单位根表

    // 初始化单位根表
    void init_roots(int n) {
        roots.resize(n);
        for (int i = 0; i < n; i++) {
            double ang = 2 * PI * i / n;
            roots[i] = std::complex<double>(cos(ang), sin(ang));
        }
    }

    // 迭代 FFT
    void FFT(std::vector<std::complex<double>>& a, bool invert) {
        int n = (int)a.size();
        // bit-reversal
        for (int i = 1, j = 0; i < n; i++) {
            int bit = n >> 1;
            for (; j & bit; bit >>= 1) j ^= bit;
            j ^= bit;
            if (i < j) swap(a[i], a[j]);
        }

        for (int len = 2; len <= n; len <<= 1) {
            int step = n / len;
            for (int i = 0; i < n; i += len) {
                for (int j = 0; j < len / 2; j++) {
                    std::complex<double> u = a[i + j];
                    // 正变换用 roots，逆变换用共轭
                    std::complex<double> v =
                        a[i + j + len / 2] * (invert ? conj(roots[j * step]) : roots[j * step]);
                    a[i + j] = u + v;
                    a[i + j + len / 2] = u - v;
                }
            }
        }
        if (invert) {
            for (auto& x : a) x /= n;
        }
    }

    // 卷积
    void count(int x, int y) {
        if ((int)A.size() < x + 1) A.resize(x + 1);
        if ((int)B.size() < y + 1) B.resize(y + 1);

        int need = x + y + 1;
        int n = 1;
        while (n < need) n <<= 1;

        init_roots(n);

        std::vector<std::complex<double>> fa(n), fb(n);
        copy(A.begin(), A.begin() + (x + 1), fa.begin());
        copy(B.begin(), B.begin() + (y + 1), fb.begin());

        FFT(fa, false);
        FFT(fb, false);
        for (int i = 0; i < n; i++) fa[i] *= fb[i];
        FFT(fa, true);

        ret.assign(need, 0);
        for (int i = 0; i < need; i++) {
            ret[i] = (i64)llround(fa[i].real());
        }
    }
};
// @book-end

int main() { return 0; }
