#include "../基础算法/快速幂与常用函数.cpp"

// @book-begin
const int SIZE = 2;
struct Matrix {
    i64 M[SIZE + 1][SIZE + 1]{};
    void clear() { memset(M, 0, sizeof(M)); }
    void reset() {  //初始化
        clear();
        for (int i = 1; i <= SIZE; ++i) M[i][i] = 1;
    }
    Matrix friend operator*(const Matrix &A, const Matrix &B) {
        Matrix Ans;
        Ans.clear();
        for (int i = 1; i <= SIZE; ++i)
            for (int j = 1; j <= SIZE; ++j)
                for (int k = 1; k <= SIZE; ++k)
                    Ans.M[i][j] = (Ans.M[i][j] + A.M[i][k] * B.M[k][j]) % mod;
        return Ans;
    }
    Matrix friend operator+(const Matrix &A, const Matrix &B) {
        Matrix Ans;
        Ans.clear();
        for (int i = 1; i <= SIZE; ++i)
            for (int j = 1; j <= SIZE; ++j)
                Ans.M[i][j] = (A.M[i][j] + B.M[i][j]) % mod;
        return Ans;
    }
};


bool ok = true;
Matrix getinv(const Matrix &input) {  // mod 为素数；无逆时 ok=false，返回零阵
    ok = true;
    array<array<i64, 2 * SIZE + 1>, SIZE + 1> a{};
    for (int i = 1; i <= SIZE; ++i) {
        for (int j = 1; j <= SIZE; ++j) a[i][j] = (input.M[i][j] % mod + mod) % mod;
        a[i][i + SIZE] = 1;
    }
    for (int i = 1; i <= SIZE; ++i) {
        int pivot = i;
        while (pivot <= SIZE && a[pivot][i] == 0) ++pivot;
        if (pivot > SIZE) {
            ok = false;
            return Matrix{};
        }
        swap(a[i], a[pivot]);
        i64 inverse = mypow(a[i][i], mod - 2, mod);
        for (int j = 1; j <= 2 * SIZE; ++j) a[i][j] = a[i][j] * inverse % mod;
        for (int j = 1; j <= SIZE; ++j) {
            if (j == i) continue;
            i64 factor = a[j][i];
            for (int k = 1; k <= 2 * SIZE; ++k) {
                a[j][k] = (a[j][k] - factor * a[i][k] % mod + mod) % mod;
            }
        }
    }
    Matrix result;
    for (int i = 1; i <= SIZE; ++i) {
        for (int j = 1; j <= SIZE; ++j) result.M[i][j] = a[i][SIZE + j];
    }
    return result;
}
// @book-end
