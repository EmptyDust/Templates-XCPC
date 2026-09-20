import itertools
import math
import random
import unittest
from support import check, compile_program, printed, run


class NumericTests(unittest.TestCase):
    def test_arithmetic_and_inverse(self):
        check("arithmetic", printed("code/基础算法/快速幂与常用函数.cpp") +
              printed("chapters/数论.typ", "扩展欧几里得解") + r'''
int main() {
    assert(mypow(1000000000000000000LL, 2, 1000000007) == 2401);
    assert(mypow(LLONG_MIN, 2, INT_MAX) == 4);
    assert(mypow(-2, 3, 5) == 2);
    assert(mypow(7, 0, 1) == 0);
    assert(mysqrt(LLONG_MAX) == 3037000499LL);
    assert(mysqrt(0) == 0 && mysqrt(1) == 1);
    assert(mylcm(INT_MIN, INT_MAX) == 4611686016279904256LL);
    assert(getInv(1, INT_MAX) == 1 && getInv(-1, INT_MAX) == INT_MAX - 1);
    for (int p = 1; p < 150; ++p) {
        for (int a = -100; a <= 100; ++a) {
            i64 inv = getInv(a, p);
            if (gcd(a, p) != 1) assert(inv == -1);
            else assert(((i64(a) * inv) % p + p) % p == 1 % p);
        }
    }
}
''')

    def test_factorization(self):
        check("factorization", printed("code/数论/Miller---Rabin-素数测试.cpp") +
              printed("code/数论/Pollard---Rho-因式分解.cpp") + r'''
int main() {
    vector<bool> prime(100001, true);
    prime[0] = prime[1] = false;
    for (int i = 2; i <= 100000; ++i) {
        if (prime[i]) for (int j = 2 * i; j <= 100000; j += i) prime[j] = false;
        assert(MR(i) == prime[i]);
    }
    assert(!MR(-1) && !MR(0) && !MR(1));
    assert(MR(2147483659LL) && !MR(4294967299LL));
    assert(!MR(341550071728321LL));
    vector<i64> cases{1, 4294967299LL, LLONG_MAX, 1000000007LL * 1000000009LL};
    mt19937 rng(123);
    for (int i = 0; i < 400; ++i) cases.push_back(1 + rng() % 100000);
    for (i64 n : cases) {
        auto factors = fac(n);
        assert(is_sorted(factors.begin(), factors.end()));
        i128 product = 1;
        for (i64 p : factors) {
            assert(MR(p));
            if (p <= 100000) assert(prime[p]);
            product *= p;
        }
        assert(product == n);
    }
}
''')

    def test_matrix(self):
        source = printed("code/基础算法/快速幂与常用函数.cpp")
        matrix = printed("code/数论/矩阵四则运算.cpp")
        for size in [2, 6]:
            source += f"namespace size{size} {{\n" + matrix.replace("const int SIZE = 2;", f"const int SIZE = {size};") + r'''
void test() {
    Matrix a;
    a.reset();
    a.M[1][1] = 2;
    auto inv = getinv(a);
    assert(ok);
    auto product = a * inv;
    assert(product.M[1][1] == 1);
    getinv(Matrix{});
    assert(!ok);
    mt19937 rng(9);
    for (int t = 0; t < 100; ++t) {
        a.reset();
        for (int i = 1; i <= SIZE; ++i) {
            a.M[i][i] = 1 + rng() % 100;
            for (int j = i + 1; j <= SIZE; ++j) a.M[i][j] = rng() % mod;
        }
        auto b = getinv(a);
        assert(ok);
        auto left = a * b, right = b * a;
        for (int i = 1; i <= SIZE; ++i) for (int j = 1; j <= SIZE; ++j) {
            assert(left.M[i][j] == (i == j));
            assert(right.M[i][j] == (i == j));
        }
    }
}
}
'''
        check("matrix", source + "int main() { size2::test(); size6::test(); }\n")

    def test_basis(self):
        check("basis", printed("code/线性代数/高斯消元法.cpp") + r'''
int main() {
    LB full;
    for (int i = 0; i < 63; ++i) full.insert(1LL << i);
    full.rebuild();
    assert(full.kthquery(1) == 1 && full.kthquery(LLONG_MAX) == LLONG_MAX);
    assert(full.kthquery(1ULL << 63) == -1);
    LB repeated, merged;
    repeated.insert(1); repeated.insert(1);
    merged.Merge(repeated); merged.rebuild();
    assert(merged.kthquery(1) == 0 && merged.kthquery(2) == 1);
    mt19937 rng(18);
    for (int trial = 0; trial < 300; ++trial) {
        LB basis;
        vector<int> a(1 + rng() % 9);
        for (int &x : a) { x = rng() % 128; basis.insert(x); }
        set<i64> expected;
        for (int mask = 1; mask < (1 << a.size()); ++mask) {
            int value = 0;
            for (int i = 0; i < (int)a.size(); ++i) if (mask >> i & 1) value ^= a[i];
            expected.insert(value);
        }
        basis.rebuild();
        int k = 1;
        for (i64 value : expected) assert(basis.kthquery(k++) == value);
        assert(basis.kthquery(k) == -1 && basis.kthquery(0) == -1);
    }
}
''')

    def test_polynomial(self):
        source = printed("code/基础算法/快速幂与常用函数.cpp")
        source += printed("code/杂项/取模类.cpp")
        source += printed("chapters/多项式.typ", "离散傅里叶变换-dft-与其逆变换-idft")
        source += printed("chapters/多项式.typ", "多项式封装")
        source += printed("chapters/多项式.typ", "快速数论变换-ntt")
        source += printed("chapters/多项式.typ", "拉格朗日插值")
        source += printed("code/多项式/快速数论变换-NTT-2.cpp")
        check("polynomial", source + r'''
int main() {
    Z z;
    istringstream input("4294967296 -9223372036854775808");
    input >> z; assert(input && z == Z(4294967296LL));
    input >> z; assert(input && z == Z(LLONG_MIN));
    using Large = Zmod<2147483647>;
    assert((Large(INT_MAX - 1) + Large(INT_MAX - 1)).val() == INT_MAX - 2);
    vector<Z> empty, single{7};
    dft(empty); idft(empty); dft(single); idft(single); assert(single[0] == 7);
    vector<int> values{1, 2, 3, 4};
    Polynomial transform(values);
    transform.ntt(transform.z, values.size(), -1);
    for (int i = 0; i < 4; ++i) assert(transform.z[i] == values[i]);
    assert((Poly<>{}.pow(0, 3) == Poly<>{1, 0, 0}));
    mt19937 rng(17);
    for (int trial = 0; trial < 35; ++trial) {
        int n = trial == 0 ? 160 : 1 + rng() % 20;
        int m = trial == 0 ? 150 : 1 + rng() % 20;
        Poly<> a(n), b(m), expected(n + m - 1);
        for (auto &x : a) x = rng() % 100;
        for (auto &x : b) x = rng() % 100;
        for (int i = 0; i < n; ++i) for (int j = 0; j < m; ++j) expected[i + j] += a[i] * b[j];
        assert(a * b == expected);
        vector<i64> left(n), right(m);
        for (int i = 0; i < n; ++i) left[i] = a[i].val() - nttMod;
        for (int i = 0; i < m; ++i) right[i] = b[i].val();
        auto convolution = mul(left, right);
        for (int i = 0; i < n + m - 1; ++i) assert(convolution[i] == expected[i].val());
        vector<Z> points{0, 1, 2, 2, -3};
        auto evaluated = a.eval(points);
        for (int i = 0; i < (int)points.size(); ++i) {
            Z answer = 0;
            for (int j = n - 1; j >= 0; --j) answer = answer * points[i] + a[j];
            assert(evaluated[i] == answer);
        }
        assert(a.eval({}).empty());
        a[0] = 1;
        auto inverse = (a * a.inv(n)).trunc(n);
        assert(inverse == Poly<>{1}.trunc(n));
        assert(a.log(n).exp(n) == a);
        assert((a * a).trunc(n).sqrt(n) == a);
        assert(a.pow(3, n) == (a * a * a).trunc(n));
    }
    for (int degree = 0; degree <= 8; ++degree) {
        Lagrange interpolation(degree);
        Z sum = 0;
        for (int k = 0; k <= 100; ++k) {
            if (k) sum += mypow(Z(k), degree);
            assert(interpolation.solve(k) == sum);
        }
        assert(interpolation.solve(Z::modulus + 1LL) == 1);
    }
    assert(mul(vector<i64>{-1, 2}, vector<i64>{3, 4}) == vector<i64>({nttMod - 3, 2, 8}));
    assert(mul(vector<i64>{}, vector<i64>{1}).empty());
    auto smallMod = [&]<int P>() {
        for (int m = 1; m < P; ++m) {
            Poly<P> a(m);
            a[0] = 1;
            for (int i = 1; i < m; ++i) a[i] = rng() % P;
            Poly<P> t = a, power{1}, logarithm(m);
            t[0] = 0;
            for (int k = 1; k < m; ++k) {
                power = (power * t).trunc(m);
                logarithm += power * (Zmod<P>(k).inv() * (k % 2 ? 1 : -1));
            }
            assert(a.log(m) == logarithm);
            assert((a * a.inv(m)).trunc(m) == Poly<P>{1}.trunc(m));
            assert(a.log(m).exp(m) == a);
            assert((a * a).trunc(m).sqrt(m) == a);
            assert(a.pow(3, m) == (a * a * a).trunc(m));
        }
    };
    smallMod.operator()<7>();
    smallMod.operator()<11>();
    smallMod.operator()<17>();
}
''')

    def test_prime_sum(self):
        check("prime_sum", printed("chapters/数论.typ", "min25-筛") + r'''
int main() {
    vector<bool> prime(100001, true);
    prime[0] = prime[1] = false;
    for (int p = 2; p <= 100000; ++p) if (prime[p]) {
        for (int j = 2 * p; j <= 100000; j += p) prime[j] = false;
    }
    vector<i64> sums(100001);
    for (int i = 1; i <= 100000; ++i) sums[i] = sums[i - 1] + (prime[i] ? i : 0);
    for (int p : {1, 2, 6, 1000000007, INT_MAX}) {
        for (int n = 0; n < 500; ++n) assert(min25::solve(n, p) == sums[n] % p);
        assert(min25::solve(100000, p) == sums[100000] % p);
    }
    assert(min25::solve(10000000000LL, 1) == 0);
}
''')

    def test_fractions_and_bigints(self):
        check("fractions_bigints", printed("code/杂项/分数运算类.cpp") +
              printed("code/杂项/大整数类-高精度计算.cpp") + r'''
string str(const bigint &x) { ostringstream s; s << x; return s.str(); }
int main() {
    using F = Frac<i64>;
    assert(F(1, 2) + F(1, 3) == F(5, 6));
    assert(F(1, 2) - F(1, 3) == F(1, 6));
    assert(F(1, 2) * F(1, 3) == F(1, 6));
    assert(F(1, 2) / F(1, 3) == F(3, 2));
    assert(F(1, -2).norm() == F(-1, 2));
    assert(str(bigint(LLONG_MIN)) == to_string(LLONG_MIN));
    assert(str(-bigint(0)) == "0");
    assert(str(bigint(6) * -2) == "-12" && str(bigint(6) / -2) == "-3");
    assert(str(bigint(1) * INT_MIN) == to_string(INT_MIN));
    assert(str(bigint(LLONG_MIN) / INT_MIN) == "4294967296");
    for (i64 a = -60; a <= 60; ++a) for (int b = -12; b <= 12; ++b) {
        assert(str(bigint(a) * b) == to_string(a * b));
        assert(str(bigint(a) + bigint(b)) == to_string(a + b));
        assert(str(bigint(a) - bigint(b)) == to_string(a - b));
        if (b) {
            assert(str(bigint(a) / b) == to_string(a / b));
            assert(bigint(a) % b == a % b);
            assert(str(bigint(a) / bigint(b)) == to_string(a / b));
            assert(str(bigint(a) % bigint(b)) == to_string(a % b));
        }
    }
}
''')

    def test_decimal_power(self):
        exe = compile_program("decimal_power", printed("code/杂项/魔改十进制快速幂暴力计算.cpp"))
        rng = random.Random(12)
        cases = [(999999998, 2, 999999999), (1, 0, 1)]
        cases += [(rng.randrange(10**30), rng.randrange(10**12), rng.randrange(1, 10**9)) for _ in range(30)]
        for n, k, p in cases:
            run(exe, f"{n} {k} {p}\n", str(pow(n, k, p)))

    def test_fast_io_eof_and_limits(self):
        source = printed('code/杂项/快读.cpp')
        example = compile_program('fast_io_example', source + printed('chapters/杂项.typ', '快读'))
        for data, expected in [
            ('', ''), (' \r\n\t', ''), ('0', '0'),
            ('+7 -0\n-9223372036854775808 9223372036854775807',
             '7\n0\n-9223372036854775808\n9223372036854775807'),
            (' ' * ((1 << 21) - 1) + '-9223372036854775808', '-9223372036854775808'),
        ]:
            run(example, data, expected, timeout=3)
        limits = compile_program('fast_io_limits', source + r'''
template<class T> void roundtrip() {
    T x = 17;
    assert(Cin(x));
    Cout(x);
    putchar('\n');
    T saved = x;
    assert(!Cin(x) && x == saved);
    assert(!Cin(x) && x == saved);
}
int main() {
    int mode;
    assert(Cin(mode));
    if (mode == 0) roundtrip<i64>();
    if (mode == 1) roundtrip<u64>();
    if (mode == 2) roundtrip<i128>();
    if (mode == 3) {
        i64 x = 17;
        assert(!Cin(x) && x == 17);
    }
    if (mode == 4) {
        int a = 7, b = 9, c = 11;
        assert(!Cin(a, b, c));
        assert(a == 1 && b == 2 && c == 11);
    }
    if (mode == 5) {
        int a;
        i64 b;
        u64 c;
        assert(Cin(a, b, c));
        assert(a == INT_MIN && b == LLONG_MIN && c == ULLONG_MAX);
    }
}
''')
        for mode, values in [(0, [-(1 << 63), 0, (1 << 63) - 1]),
                             (1, [0, (1 << 64) - 1]),
                             (2, [-(1 << 127), (1 << 127) - 1])]:
            for value in values:
                run(limits, f'{mode} {value}', str(value), timeout=3)
        for token in ['', ' \t\r\n']:
            run(limits, '3 ' + token, '', timeout=3)
        run(limits, '4 1 2', '', timeout=3)
        run(limits, '5 -2147483648 -9223372036854775808 18446744073709551615', '', timeout=3)

    def test_lattice_path_formulas(self):
        def choose(n,k):return math.comb(n,k) if 0<=k<=n else 0
        for n in range(1,5):
            for m in range(1,5):
                heights=[]
                for positions in itertools.combinations(range(n+m),m):
                    ups=set(positions);path=[0]
                    for i in range(n+m):path.append(path[-1]+(i in ups))
                    heights.append(path)
                strict=weak=0
                for p in heights:
                    for q in heights:
                        strict+=all(x>y for x,y in zip(p[1:-1],q[1:-1]))
                        weak+=all(x>=y for x,y in zip(p,q))
                self.assertEqual(strict,choose(n+m-2,n-1)**2-choose(n+m-2,n-2)*choose(n+m-2,n))
                self.assertEqual(weak,choose(n+m,n)**2-choose(n+m,n-1)*choose(n+m,n+1))

if __name__ == "__main__":
    unittest.main()
