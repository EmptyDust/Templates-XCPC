#import "../prelude.typ": *

= 常用例题
<常用例题>
零散题型集：逆序对、区间不同数、状压枚举、德州扑克、数独、装箱这类"单独成不了章"的题。先扫一眼有没有现成的，再决定造轮子。整数用 `i64`。`N` / `BIT` 按题目或见数据结构章。

== 逆序对 \(归并排序解)
<逆序对-归并排序解>
$cal(O)(N "log" N)$。数组 $1$-index。`N` 按题目改。

#quote(block: true)[
性质：交换序列的任意两元素，序列的逆序数的奇偶性必定发生改变。
]

#include-code("code/常见例题/逆序对-归并排序解.cpp")

== 统计区间不同数字的数量 \(离线查询)
<统计区间不同数字的数量-离线查询>
核心在于使用 `pre` 数组滚动维护每一个数字出现的最后位置，配以树状数组统计数量。由于滚动维护具有后效性，所以需要离线操作，从前往后更新。时间复杂度 $cal(O)(N "log" N)$ ，常数瓶颈在于 `map`，用手造哈希或者离散化可以优化到理想区间；同时也有莫队做法，复杂度稍劣。#link("https://www.luogu.com.cn/problem/P1972")[例题链接] 。

```cpp
signed main() {
    int n;
    cin >> n;
    vector<int> in(n + 1);
    for (int i = 1; i <= n; i++) {
        cin >> in[i];
    }
    
    int q;
    cin >> q;
    vector<array<int, 3>> query;
    for (int i = 0; i < q; i++) {
        int l, r;
        cin >> l >> r;
        query.push_back({r, l, i});
    }
    sort(query.begin(), query.end());
    
    vector<pair<int, int>> ans;
    map<int, int> pre;
    int st = 1;
    BIT bit(n);  // 树状数组，见数据结构章
    for (auto [r, l, id] : query) {
        for (int i = st; i <= r; i++, st++) {
            if (pre.count(in[i])) {  // 消除此前操作的影响
                bit.add(pre[in[i]], -1);
            }
            bit.add(i, 1);
            pre[in[i]] = i;  // 更新操作
        }
        ans.push_back({id, bit.ask(r) - bit.ask(l - 1)});
    }
    
    sort(ans.begin(), ans.end());
    for (auto [id, w] : ans) {
        cout << w << endl;
    }
}
```

== 选数 \(DFS 解)
<选数-dfs-解>
从 $N$ 个整数中任选 $K$ 个相加，枚举组合。$cal(O)(binom(N, K) dot K)$。

#include-code("code/常见例题/选数-DFS-解.cpp")

== 选数 \(位运算状压)
<选数-位运算状压>
Gosper：按字典序枚举恰好 $k$ 个 $1$ 的位集。$n$ 须能压进 `int`。

#include-code("code/常见例题/选数-位运算状压.cpp")

== 网格路径计数
<网格路径计数>
从 $(0 , 0)$ 走到 $(a , b)$，规定每次只能从 $(x , y)$ 走到左下或者右下，方案数记为 $f (a , b)$ 。

- $f (a , b) = binom(a, frac(a + b, 2))$ ；
- 若路径和直线 $y = k , k in.not [0 , b]$ 不能有交点，则方案数为 $f (a , b) - f (a , 2 k - b)$ ；
- 若路径和两条直线 $y = k_1 ， y = k_2 （ k_1 < 0 lt.eq b < k_2 ）$ 不能有交点，方案数记为 $g (a , b , k_1 , k_2)$ ，可以使用 $cal(O)(N)$ 递归求解；
- 若路径必须碰到 $y = k_1$ 但是不能碰到 $y = k_2$ ，方案数记为 $h (a , b , k_1 , k_2)$，可以使用 $cal(O)(N)$ 递归求解（递归过程中两条直线距离会越来越大）。

从 $(0 , 0)$ 走到 $(a , 0)$，规定每次只能走到左下或者右下，且必须有#strong[恰好一次];传送（向下 $b$ 单位），且不能走到 $x$ 轴下方，方案数为 $binom(a + 1, frac(a - b, 2) + k + 1)$ 。TODO：原式含未定义的 $k$，与组合数学章同一条，保留待核。

== 德州扑克
<德州扑克>
读入牌型，比较两手牌。依赖赛场宏 `FOR` / `ALL` / `sz`。`clac` 是比较入口（拼写未改，避免和旧代码对不上）。

```cpp
#define FOR(i, a, b) for (int i = (a); i <= (b); i++)  // 本题解私用宏，页内自洽
#define ALL(x) x.begin(), x.end()

struct card {
      int suit, rank;
      friend bool operator < (const card &a, const card &b) {
        return a.rank < b.rank;
    }
    friend bool operator == (const card &a, const card &b) {
        return a.rank == b.rank;
    }
    friend bool operator != (const card &a, const card &b) {
        return a.rank != b.rank;
    }
    friend auto &operator>> (istream &it, card &C) {
        string S, T; it >> S;
        T = "__23456789TJQKA";  //点数
        FOR (i, 0, (int)T.size() - 1) {
            if (T[i] == S[0]) C.rank = i;
        }
        T = "_SHCD";  //花色
        FOR (i, 0, (int)T.size() - 1) {
            if (T[i] == S[1]) C.suit = i;
        }
        return it;
    }
};
struct game {
    int level;
    vector<card> peo;
    int a, b, c, d, e;
    int u, v, w, x, y;
    bool Rk10() {  //Rk10: Royal Flush，五张牌同花色，且点数为AKQJT（14,13,12,11,10）
        sort(ALL(peo));
        reverse(ALL(peo));
        a = peo[0].rank, b = peo[1].rank, c = peo[2].rank, d = peo[3].rank, e = peo[4].rank;
        u = peo[0].suit, v = peo[1].suit, w = peo[2].suit, x = peo[3].suit, y = peo[4].suit;
        
        if (u != v || v != w || w != x || x != y) return 0;
        if (a == 14 && b == 13 && c == 12 && d == 11 && e == 10) return 1;
        return 0;
    }
    bool Dif(vector<card> &peo) {  //专门用于检查A2345这种顺子的情况（这是最小的顺子）
        a = peo[0].rank, b = peo[1].rank, c = peo[2].rank, d = peo[3].rank, e = peo[4].rank;
        u = peo[0].suit, v = peo[1].suit, w = peo[2].suit, x = peo[3].suit, y = peo[4].suit;
        
        if (a != 14 || b != 5 || c != 4 || d != 3 || e != 2) return 0;
        vector<card> peo2 = {peo[1], peo[2], peo[3], peo[4], peo[0]};  //重新排序
        peo = peo2;
        return 1;
    }
    bool Rk9() { //Rk9: Straight Flush，五张牌同花色，且顺连【r1 > r2 > r3 > r4 > r5】
        sort(ALL(peo));
        reverse(ALL(peo));
        a = peo[0].rank, b = peo[1].rank, c = peo[2].rank, d = peo[3].rank, e = peo[4].rank;
        u = peo[0].suit, v = peo[1].suit, w = peo[2].suit, x = peo[3].suit, y = peo[4].suit;
        
        if (u != v || v != w || w != x || x != y) return 0;
        if (Dif(peo)) return 1; //特判：A2345
        if (a == b + 1 && b == c + 1 && c == d + 1 && d == e + 1) return 1;
        return 0;
    }
    bool Rk8() { //Rk8: Four of a Kind，四张牌点数一样【r1 = r2 = r3 = r4】
        sort(ALL(peo));
        a = peo[0].rank, b = peo[1].rank, c = peo[2].rank, d = peo[3].rank, e = peo[4].rank;
        u = peo[0].suit, v = peo[1].suit, w = peo[2].suit, x = peo[3].suit, y = peo[4].suit;
        
        if (a == b && b == c && c == d) return 1;
        if (b == c && c == d && d == e) {
            reverse(ALL(peo));
            return 1;
        }
        return 0;
    }
    bool Rk7() { //Rk7: Fullhouse，三张牌点数一样，另外两张点数也一样【r1 = r2 = r3，r4 = r5】
        sort(ALL(peo));
        a = peo[0].rank, b = peo[1].rank, c = peo[2].rank, d = peo[3].rank, e = peo[4].rank;
        u = peo[0].suit, v = peo[1].suit, w = peo[2].suit, x = peo[3].suit, y = peo[4].suit;
        
        if (a == b && b == c && d == e) return 1;
        if (a == b && c == d && d == e) {
            reverse(ALL(peo));
            return 1;
        }
        return 0;
    }
    bool Rk6() { //Rk6: Flush，五张牌同花色【r1 > r2 > r3 > r4 > r5】
        sort(ALL(peo));
        reverse(ALL(peo));
        a = peo[0].rank, b = peo[1].rank, c = peo[2].rank, d = peo[3].rank, e = peo[4].rank;
        u = peo[0].suit, v = peo[1].suit, w = peo[2].suit, x = peo[3].suit, y = peo[4].suit;
        
        if (u != v || v != w || w != x || x != y) return 0;
        return 1;
    }
    bool Rk5() { //Rk5: Straight，五张牌顺连【r1 > r2 > r3 > r4 > r5】
        sort(ALL(peo));
        reverse(ALL(peo));
        a = peo[0].rank, b = peo[1].rank, c = peo[2].rank, d = peo[3].rank, e = peo[4].rank;
        u = peo[0].suit, v = peo[1].suit, w = peo[2].suit, x = peo[3].suit, y = peo[4].suit;
        
        if (Dif(peo)) return 1; //特判：A2345
        if (a == b + 1 && b == c + 1 && c == d + 1 && d == e + 1) return 1;
        return 0;
    }
    bool Rk4() { //Rk4: Three of a kind，三张牌点数一样【r1 = r2 = r3，r4 > r5】
        sort(ALL(peo));
        reverse(ALL(peo));
        a = peo[0].rank, b = peo[1].rank, c = peo[2].rank, d = peo[3].rank, e = peo[4].rank;
        u = peo[0].suit, v = peo[1].suit, w = peo[2].suit, x = peo[3].suit, y = peo[4].suit;
        
        if (a == b && b == c) return 1;
        if (b == c && c == d) {
            swap(peo[3], peo[0]);
            return 1;
        }
        if (c == d && d == e) {
            swap(peo[3], peo[0]);
            swap(peo[4], peo[1]);
            return 1;
        }
        return 0;
    }
    bool Rk3() { //Rk3: Two Pairs，两张牌点数一样，另外有两张点数也一样（两个对子）【r1 = r2 > r3 = r4】
        sort(ALL(peo));
        reverse(ALL(peo));
        a = peo[0].rank, b = peo[1].rank, c = peo[2].rank, d = peo[3].rank, e = peo[4].rank;
        u = peo[0].suit, v = peo[1].suit, w = peo[2].suit, x = peo[3].suit, y = peo[4].suit;
        
        if (a == b && c == d) return 1;
        if (a == b && d == e) {
            swap(peo[2], peo[4]);
            return 1;
        }
        if (b == c && d == e) {
            swap(peo[0], peo[2]);
            swap(peo[2], peo[4]);
            return 1;
        }
        return 0;
    }
    bool Rk2() { //Rk2: One Pairs，两张牌点数一样（一个对子）【r1 = r2，r3 > r4 > r5】
        sort(ALL(peo));
        reverse(ALL(peo));
        a = peo[0].rank, b = peo[1].rank, c = peo[2].rank, d = peo[3].rank, e = peo[4].rank;
        u = peo[0].suit, v = peo[1].suit, w = peo[2].suit, x = peo[3].suit, y = peo[4].suit;
        
        vector<card> peo2;
        if (a == b) return 1;
        if (b == c) {
            peo2 = {peo[1], peo[2], peo[0], peo[3], peo[4]};
            peo = peo2;
            return 1;
        }
        if (c == d) {
            peo2 = {peo[2], peo[3], peo[0], peo[1], peo[4]};
            peo = peo2;
            return 1;
        }
        if (d == e) {
            peo2 = {peo[3], peo[4], peo[0], peo[1], peo[2]};
            peo = peo2;
            return 1;
        }
        return 0;
    }
    bool Rk1() { //Rk1: high card
        sort(ALL(peo));
        reverse(ALL(peo));
        return 1;
    }
    game (vector<card> New_peo) {
        peo = New_peo;
        if (Rk10()) { level = 10; return; }
        if (Rk9()) { level = 9; return; }
        if (Rk8()) { level = 8; return; }
        if (Rk7()) { level = 7; return; }
        if (Rk6()) { level = 6; return; }
        if (Rk5()) { level = 5; return; }
        if (Rk4()) { level = 4; return; }
        if (Rk3()) { level = 3; return; }
        if (Rk2()) { level = 2; return; }
        if (Rk1()) { level = 1; return; }
    }
    friend bool operator < (const game &a, const game &b) {
        if (a.level != b.level) return a.level < b.level;
        FOR (i, 0, 4) if (a.peo[i] != b.peo[i]) return a.peo[i] < b.peo[i];
        return 0;
    }
    friend bool operator == (const game &a, const game &b) {
        if (a.level != b.level) return 0;
        FOR (i, 0, 4) if (a.peo[i] != b.peo[i]) return 0;
        return 1;
    }
};
void debug(vector<card> peo) {
    for (auto it : peo) cout << it.rank << " " << it.suit << "  ";
    cout << "\n\n";
}
int clac(vector<card> Ali, vector<card> Bob) {
    game atype(Ali), btype(Bob);
    if (atype < btype) return -1;
    else if (atype == btype) return 0;
    return 1;
}
```

== N\*M 数独字典序最小方案
<nm-数独字典序最小方案>
构造字典序最小填充，不用搜。宫 $2^N times 2^M$，整盘 $(2^(N + M))^2$。公式 $0$-index。

规则：每个宫大小为 $2^N \* 2^M$ ，大图一共由 $M \* N$ 个宫组成（总大小即 $2^N 2^M \* 2^N 2^M$ ），要求每行、每列、每宫都要出现 $1$ 到 $2^N \* 2^M$ 的全部数字。输出字典序最小方案。

下例为 $2 , 1$ 和 $1 , 2$ 时数独字典序最小的示意。

#image("/images/img-01.png")

公式：$(i , j)$ 格所填的内容为 $#scale(x: 120%, y: 120%)[\(] i mod 2^N xor ⌊j / 2^M⌋ #scale(x: 120%, y: 120%)[\)] dot 2^M + #scale(x: 120%, y: 120%)[\(] ⌊i / 2^N⌋ xor j mod 2^M #scale(x: 120%, y: 120%)[\)] + 1$ ，注意 $i , j$ 从 $0$ 开始。

== 高精度进制转换
<高精度进制转换>
$2$–$62$ 进制互转。输入：`原进制 目标进制 数字`。字符 $0$-$9$A-Z$a$-$z$。短除法，大数。

#include-code("code/常见例题/高精度进制转换.cpp")

== 物品装箱
<物品装箱>
有 $N$ 个物品，第 $i$ 个物品为 $a [i]$ ，有无限个容量为 $C$ 的空箱子。两种装箱方式，输出需要多少个箱子才能装完所有物品。

=== 从前往后装（线段树解）
<从前往后装线段树解>
每个箱子容量 $C$，物品按输入顺序装进#strong[最靠前];还能放下的箱子。线段树维护剩余容量最大值。

#include-code("code/常见例题/从前往后装线段树解.cpp")

=== 选择最优的箱子装（multiset 解）
<选择最优的箱子装multiset-解>
选择能放下物品且剩余容量最小的箱子放物品。`multiset` 内部有序，`lower_bound(物品体积)` 即最小可行箱，装入后删旧容量插新容量，每步 $cal(O)("log" N)$。

#include-code("code/常见例题/选择最优的箱子装multiset-解.cpp")

== 浮点数比较
<浮点数比较>
比一堆形如 $x^(y^z)$ 与 $(x^y)^z$ 的大小。取 $"log"$ 后排序。`equal` 见二维几何。`ans[]` 是输出串表，本段未给出，按题目填。

比较下列浮点数的大小： $x^y^z , x^z^y , (x^y)^z , (x^z)^y , y^x^z , y^z^x , (y^x)^z , (y^z)^x , z^x^y , z^y^x , (z^x)^y$ 和 $(z^y)^x$ 。

```cpp
vector<pair<ld, int>> val = {
    {log(x) * pow(y, z), 0}, {log(x) * pow(z, y), 1}, {log(x) * y * z, 2},
    {log(x) * z * y, 3},     {log(y) * pow(x, z), 4}, {log(y) * pow(z, x), 5},
    {log(y) * x * z, 6},     {log(y) * z * x, 7},     {log(z) * pow(x, y), 8},
    {log(z) * pow(y, x), 9}, {log(z) * x * y, 10},    {log(z) * y * x, 11}};

sort(val.begin(), val.end(), [&](auto x, auto y) {
    if (equal(x.first, y.first)) return x.second < y.second;  // equal 见二维几何；原来写成 queal
    return x.first > y.first;
});
cout << ans[val.front().second] << endl;
```
