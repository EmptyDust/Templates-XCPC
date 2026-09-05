#include "../contest.hpp"
int n, m;

// @book-begin
int main() {
    string s;
    getline(cin, s);
    stringstream ss;
    ss << s;
    while (ss >> s) {
        auto res = stoi(s);
        cout << res * 100 << endl;
    }
}
// @book-end
