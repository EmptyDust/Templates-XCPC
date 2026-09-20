#include "../contest.hpp"
// @book-begin
char buf[1 << 21], *p1 = buf, *p2 = buf;
inline int getc() {
    if (p1 == p2) {
        p1 = buf;
        p2 = buf + fread(buf, 1, sizeof(buf), stdin);
        if (p1 == p2) return EOF;
    }
    return static_cast<unsigned char>(*p1++);
}
template<typename T> bool Cin(T &a) {
    int c = getc();
    while (c != EOF && isspace(c)) c = getc();
    if (c == EOF) return false;
    bool negative = c == '-';
    if (c == '-' || c == '+') c = getc();
    using U = make_unsigned_t<T>;
    U value = 0;
    while (c >= '0' && c <= '9') {
        value = value * 10 + (c - '0');
        c = getc();
    }
    if (negative && value != 0) a = -T(value - 1) - 1;  // 兼容有符号最小值
    else a = T(value);
    return true;
}
template<typename T, typename... Args> bool Cin(T &a, Args &...args) {
    return Cin(a) && (Cin(args) && ...);
}
template<typename T> void Cout(T x) {  // 注意，这里输出不带换行
    using U = make_unsigned_t<T>;
    U value = x;
    if (x < 0) {
        putchar('-');
        value = U(0) - value;
    }
    if (value > 9) Cout(value / 10);
    putchar(value % 10 + '0');
}
// @book-end

int main() { return 0; }
