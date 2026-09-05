#include "../contest.hpp"
int n, m;

// @book-begin
int main() {
    int n;
    cin >> n;
    int x = 1, y = (n + 1) / 2;
    vector ans(n + 1, vector<int>(n + 1));
    for (int i = 1; i <= n * n; i++) {
        ans[x][y] = i;
        if (!ans[(x - 2 + n) % n + 1][y % n + 1]){
            x = (x - 2 + n) % n + 1;
            y = y % n + 1;
        } else {
            x = x % n + 1;
        }
    }
}
// @book-end
