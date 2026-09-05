#include "../contest.hpp"
int n, m;

// @book-begin
void jos(){
    int64_t n, k, a{}, b{ 1 }; cin >> n >> k; --k;
    while (b < n) {
        auto s = a / k + 1, u = b / k + 1, v = min(k - a / s, (min(u * k, n) - b + u - 1) / u);
        a += s * v, b += u * v;
    }
    cout << a + 1 << '\n';
}
// @book-end

int main() { return 0; }
