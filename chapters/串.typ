#import "../prelude.typ": *

= 串
<串>
字符串结构主战场：匹配（KMP / Z 函数 / AC 自动机）、哈希、回文（Manacher / PAM）、后缀结构（SA / SAM / 子序列自动机）。选型信号：单模式匹配 → KMP 或 Z；多模式同时匹配 → AC 自动机；判等与比较 → 哈希；回文统计 → Manacher 或 PAM；子串计数/出现次数 → SAM；只判子序列 → 子序列自动机。

== 子串与子序列
<子串与子序列>
#figure(
align(center)[#table(
  columns: 3,
  align: (col, row) => (center,center,center,).at(col),
  inset: 6pt,
  [中文名称], [常见英文名称], [解释],
  [子串],
  [substring],
  [连续的选择一段字符（可以全选、可以不选）组成的新字符串],
  [子序列],
  [subsequence],
  [从左到右取出若干个字符（可以不取、可以全取、可以不连续）组成的新字符串],
)]
)

== kmp
<kmp>
#quote(block: true)[
应用：

+ 在字符串中查找子串；
+ 最小周期：字符串长度-整个字符串的 border；
+ 最小循环节：区别于周期，当字符串长度 $n mod (n - n x t [n]) = 0$ 时，等于最小周期，否则为 $n$ 。
]

#specline([最坏 #O($N + M$)])
计算 $t$ 在 $s$ 中出现的全部位置。

#include-code("code/串/kmp.cpp")

#include-code("code/串/kmp-2.cpp")

== zfunction
<zfunction>
#specline([整串 #O($N)$)])
$z [i]$ 为 $s$ 与后缀 $s [i dots.c ]$ 的 LCP。维护已匹配窗口 $[l , r]$，窗口内可 $O (1)$ 抄 $z [i - l]$，出界再暴力延。匹配 $t$ 时对 $t + \# + s$ 跑 Z。

#include-code("code/串/zfunction.cpp")

== 最长公共子序列 LCS
<最长公共子序列-lcs>
两串公共子序列的最长长度（可不连续）。$f [i] [j] = "max" (f [i - 1] [j] , f [i] [j - 1] , f [i - 1] [j - 1] + [s_i = t_j])$。$n lt.eq 10^3$ 用二维 DP；$n$ 更大把一串 LIS 化（转成另一串出现位置）。

=== 小数据解
<小数据解>
$n , m lt.eq 10^3$，$cal(O)(n m)$。

```cpp
const int N = 1e3 + 10;
char a[N], b[N];
int n, m, f[N][N];
void solve(){
    cin >> n >> m >> a + 1 >> b + 1;
    for (int i = 1; i <= n; i++)
        for (int j = 1; j <= m; j++){
            f[i][j] = max(f[i - 1][j], f[i][j - 1]);
            if (a[i] == b[j]) f[i][j] = max(f[i][j], f[i - 1][j - 1] + 1);
        }
    cout << f[n][m] << "\n";
}
int main(){
    solve();
    return 0;
}
```

=== 大数据解
<大数据解>
#specline([#O($N "log" N$)（$10^5$ 以内）])
把第二个序列映射到第一个序列中的位置后跑 LIS。`maxn` 需自行定义。

#pitfall[要求两个序列都是排列（元素互不相同），否则 `p[a[i]] = i` 的映射会互相覆盖。]

```cpp
const int INF = 0x7fffffff;
int n, a[maxn], b[maxn], f[maxn], p[maxn];
int main(){
    cin >> n;
    for (int i = 1; i <= n; i++){
        scanf("%d", &a[i]);
        p[a[i]] = i;  //将第二个序列中的元素映射到第一个中
    }
    for (int i = 1; i <= n; i++){
        scanf("%d", &b[i]);
        f[i] = INF;
    }
    int len = 0;
    f[0] = 0;
    for (int i = 1; i <= n; i++){
        if (p[b[i]] > f[len]) f[++len] = p[b[i]];
        else {
            int l = 0, r = len;
            while (l < r){
                int mid = (l + r) >> 1;
                if (f[mid] > p[b[i]]) r = mid;
                else l = mid + 1;
            }
            f[l] = min(f[l], p[b[i]]);
        }
    }
    cout << len << "\n";
    return 0;
}
```

== 字符串哈希
<字符串哈希>
#specline([预处理 #O($N$)], [比相等 #O($1$)])
把串看成 $B$ 进制数对模取余，子串哈希用前缀差：$h [r + 1] - h [l] dot B^(r - l + 1)$。

#pitfall[单模可能被卡，双模或随机底数更稳。]

=== 双哈希封装
<双哈希封装>
先 `init()` 生成幂表；`Zmod` 见数论章。前导哨兵 `1`（空串哈希为 `1`），`substring(l, r)` 为 $0$ 下标闭区间，`modify(idx, x)` 单点替换。随机质数：1111111121、1211111123、1311111119。

```cpp
const int N = 1 << 21;
static const int mod1 = 1E9 + 7, base1 = 127;
static const int mod2 = 1E9 + 9, base2 = 131;
using U = Zmod<mod1>;
using V = Zmod<mod2>;
vector<U> val1;
vector<V> val2;
void init(int n = N) {
    val1.resize(n + 1), val2.resize(n + 2);
    val1[0] = 1, val2[0] = 1;
    for (int i = 1; i <= n; i++) {
        val1[i] = val1[i - 1] * base1;
        val2[i] = val2[i - 1] * base2;
    }
}
struct String {
    vector<U> hash1;
    vector<V> hash2;
    string s;

    String(string s_) : s(s_), hash1{1}, hash2{1} {
        for (auto it : s) {
            hash1.push_back(hash1.back() * base1 + it);
            hash2.push_back(hash2.back() * base2 + it);
        }
    }
    pair<U, V> get() {  // 输出整串的哈希值
        return {hash1.back(), hash2.back()};
    }
    pair<U, V> substring(int l, int r) { // 输出子串的哈希值
        if (l > r) swap(l, r);
        U ans1 = hash1[r + 1] - hash1[l] * val1[r - l + 1];
        V ans2 = hash2[r + 1] - hash2[l] * val2[r - l + 1];
        return {ans1, ans2};
    }
    pair<U, V> modify(int idx, char x) { // 修改 idx 位为 x
        int n = s.size() - 1;
        U ans1 = hash1.back() + val1[n - idx] * (x - s[idx]);
        V ans2 = hash2.back() + val2[n - idx] * (x - s[idx]);
        return {ans1, ans2};
    }
};
```

=== 前后缀去重
<前后缀去重>
`sample please ease` 去重后得到 `samplease`。

```cpp
string compress(vector<string> in) {  // 前后缀压缩
    vector<U> hash1{1};
    vector<V> hash2{1};
    string ans = "#";
    for (auto s : in) {
        s = "#" + s;
        int st = 0;
        U chk1 = 0;
        V chk2 = 0;
        for (int j = 1; j < s.size() && j < ans.size(); j++) {
            chk1 = chk1 * base1 + s[j];
            chk2 = chk2 * base2 + s[j];
            if ((hash1.back() == hash1[ans.size() - 1 - j] * val1[j] + chk1) &&
                (hash2.back() == hash2[ans.size() - 1 - j] * val2[j] + chk2)) {
                st = j;
            }
        }
        for (int j = st + 1; j < s.size(); j++) {
            ans += s[j];
            hash1.push_back(hash1.back() * base1 + s[j]);
            hash2.push_back(hash2.back() * base2 + s[j]);
        }
    }
    return ans.substr(1);
}
```

== 马拉车
<马拉车>
#specline([#O($N$)])
求每个位置的回文半径：`d1[i]` 为以 $i$ 为中心的奇回文半径（#strong[含中心];），`d2[i]` 为以 $i$ 与 $i - 1$ 中间为中心的偶回文半径。以 $i$ 为中心的最长奇回文长度为 `2*d1[i]-1`，偶回文为 `2*d2[i]`。

#pitfall[下方 `check(l, r)` 返回 `true` 表示区间 $[l , r]$ #strong[不是];回文——按原题语义，与直觉相反。]

#include-code("code/串/马拉车.cpp")

== 字典树 trie
<字典树-trie>
按字符（或二进制位）从根往下开儿子。公共前缀共用一条路径。查前缀、统计出现、01 trie 贪心异或最值都靠它。

=== 基础封装
<基础封装>
字符集 `a-z A-Z 0-9` 共 $62$ 类（先 `init()` 建映射）。`cnt[u]++` 记在路径上——`query` 返回#strong[以该串为前缀];的个数；要恰好出现次数，在插入末尾单独打标记。

#include-code("code/串/基础封装.cpp")

=== 01 字典树
<字典树>
按二进制从高到低插入。`query(x)` 每步优先走与 $x$ 相反的位，贪心得到集合中与 $x$ 异或的最大值。深度 `30` 按值域改（`long long` 用 `63`）。

```cpp
struct Trie {
    int n, idx;
    vector<vector<int>> ch;
    Trie(int n) {
        this->n = n;
        idx = 0;
        ch.resize(30 * (n + 1), vector<int>(2));
    }
    void insert(int x) {
        int u = 0;
        for (int i = 30; ~i; i--) {
            int &v = ch[u][x >> i & 1];
            if (!v) v = ++idx;
            u = v;
        }
    }
    int query(int x) {
        int u = 0, res = 0;
        for (int i = 30; ~i; i--) {
            int v = x >> i & 1;
            if (ch[u][!v]) {
                res += (1 << i);
                u = ch[u][!v];
            } else {
                u = ch[u][v];
            }
        }
        return res;
    }
};
```

== 后缀数组 SA
<后缀数组-sa>
#specline([倍增法 #O($N "log" N$)（原标注 #O($N$) 有误，线性需 SA-IS）])
`sa[i]` 为排名 $i$ 的后缀起点，`rk[i]` 为后缀 $i$ 的排名，`lc[rk[i]-1]` 为后缀 $i$ 与排名前一后缀的 LCP（即 height 数组）。常用结论：任意两后缀的 LCP 为对应区间 height 的 RMQ。

#include-code("code/串/后缀数组-SA.cpp")

== AC 自动机
<ac-自动机>
#specline([#O($sum lr(|s_i|) + lr(|S|)$)，字符集默认 $26$])
多模式串同时在文本里匹配。先 `insert` 每个模式，`build()` 求 fail（失配跳到当前后缀里最长的已有前缀），再 `query(文本)`。fail 把 Trie 连成 KMP 自动机，匹配沿边走即可。第二份 `add` 返回模式终点，`work(文本)` 在 fail 树上汇总出现次数。

#include-code("code/串/AC-自动机.cpp")

#include-code("code/串/AC-自动机-2.cpp")

== 回文自动机 PAM \(回文树)
<回文自动机-pam-回文树>
#specline([#O($N$)（在线）])
维护所有#strong[本质不同];的回文子串，节点数 $lt.eq n + 2$（两个根长度 $0$ 与 $- 1$）。`len[v]` 为该节点回文长度，`fail[v]` 指向最长回文真后缀，`dep[v]` 为回文后缀链深度（即不同回文后缀个数），`cnt[v]` 需在建完后 `countAll()` 从大到小向 `fail` 累加才成为真实出现次数。插入按字符逐个 `insert(c, i)`。

#include-code("code/串/回文自动机-PAM-回文树.cpp")

#include-code("code/串/回文自动机-PAM-回文树-2.cpp")

== 后缀自动机 SAM
<后缀自动机-sam>
#specline([#O($N "log" lr(|Sigma|)$)])
识别一个串的全部子串：每个状态对应 endpos 相同的一类子串。`len` 是该状态最长串的长度，`link` 指向更短的后缀状态。逐字符 `last = extend(last, c)`（第一份从节点 `p` 接字符 `c`，返回新 last；多串时 last 复位为 $0$ 即广义 SAM）。本质不同子串数 $sum ("len" [v] - "len" ["link" [v]])$，复杂度 $cal(O)(N "log" lr(|Sigma|))$。

#include-code("code/串/后缀自动机-SAM.cpp")

第二个 SAM 封装：`endpos` 为该状态最短出现位置记录（按需使用），`size` 为出现次数——按 `len` 降序（即节点编号倒序，clones 在前）把 `size` 累加到 `link` 上即可；以 `link` 为父边构成的后缀链接树可当后缀树用。复杂度 $cal(O)(N "log" lr(|Sigma|))$（`next` 用 `std::map`）。

#include-code("code/串/后缀自动机-SAM-2.cpp")

== 子序列自动机
<子序列自动机>
#specline([预处理 #O($n$)], [单次判定 #O($m "log" n$)])
对给定主串 $s$（长 $n$，对每个字符开桶存出现位置）判定长度为 $m$ 的询问串是否为 $s$ 的子序列。核心是 `next[i][c]`：位置 $i$ 之后（不含 $i$）字符 $c$ 第一次出现的位置，匹配时贪心跳转。常见用途：

+ 判断一个（或多个）串是否为主串的子序列
+ 多串各自建自动机后同步转移，求最短公共超序列等公共子序列变种
+ 在自动机上 DP 统计本质不同子序列个数
+ 配合 DP 求字典序第 $k$ 小的子序列

相比 SAM/PAM 结构简单、预处理快，适合字符集小、反复判断子序列的场景。

=== 自动离散化、自动类型匹配封装
<自动离散化自动类型匹配封装>
字符不必是 `char`：先离散再按值建后继表。用法同上，适合整数序列上的子序列判定。

#include-code("code/串/自动离散化、自动类型匹配封装.cpp")

=== 朴素封装
<朴素封装>
原时间复杂度中的 $upright("size:") s$ 需要手动设置。类型需要手动设置。

```cpp
struct SequenceAutomaton {
    vector<vector<int>> ver;

    SequenceAutomaton(vector<int> &in, int size) : ver(size + 1) {
        for (int i = 0; i < in.size(); i++) {
            ver[in[i]].push_back(i + 1);
        }
    }
    bool contains(vector<int> &in) {
        int at = 0;
        for (auto &i : in) {
            auto it = lower_bound(ver[i].begin(), ver[i].end(), at + 1);
            if (it == ver[i].end()) {
                return false;
            }
            at = *it;
        }
        return true;
    }
};
```
