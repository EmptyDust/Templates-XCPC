## STL 与库函数

### 数组打乱 shuffle

```cpp
mt19937_64 rng(chrono::steady_clock::now().time_since_epoch().count());
shuffle(ver.begin(), ver.end(), rng);
```

### bit 库与位运算函数 \_\_builtin\_

```cpp
__builtin_popcount(x) // 返回x二进制下含1的数量，例如x=15=(1111)时答案为4

__builtin_ffs(x) // 返回x右数第一个1的位置(1-idx)，1(1) 返回 1，8(1000) 返回 4，26(11010) 返回 2

__builtin_ctz(x) // 返回x二进制下后导0的个数，1(1) 返回 0，8(1000) 返回 3

bit_width(x) // 返回x二进制下的位数，9(1001) 返回 4，26(11010) 返回 5
```

注：以上函数的 $\tt{}long\ long$ 版本只需要在函数后面加上 `ll` 即可（例如 `__builtin_popcountll(x)` )， $\tt{}unsigned\ long\ long$ 加上 `ull` 。

### 数字转字符串函数

`itoa` 虽然能将整数转换成任意进制的字符串，但是其不是标准的 C 函数，且为 Windows 独有，且不支持 `long long` ，建议手写。

```cpp
// to_string函数会直接将你的各种类型的数字转换为字符串。
// string to_string(T val);
double val = 12.12;
cout << to_string(val);
```

```cpp
// 【不建议使用】itoa允许你将整数转换成任意进制的字符串，参数为待转换整数、目标字符数组、进制。
// char* itoa(int value, char* string, int radix);
char ans[10] = {};
itoa(12, ans, 2);
cout << ans << endl; /*1100*/

// 长整型函数名ltoa，最高支持到int型上限2^31。ultoa同理。
```

### 字符串转数字

```cpp
// stoi直接使用
cout << stoi("12") << endl;

// 【不建议使用】stoi转换进制，参数为待转换字符串、起始位置、进制。
// int stoi(string value, int st, int radix);
cout << stoi("1010", 0, 2) << endl; /*10*/
cout << stoi("c", 0, 16) << endl; /*12*/
cout << stoi("0x3f3f3f3f", 0, 0) << endl; /*1061109567*/

// 长整型函数名stoll，最高支持到long long型上限2^63。stoull、stod、stold同理。
```

```cpp
// atoi直接使用，空字符返回0，允许正负符号，数字字符前有其他字符返回0，数字字符前有空白字符自动去除
cout << atoi("12") << endl;
cout << atoi("   12") << endl; /*12*/
cout << atoi("-12abc") << endl; /*-12*/
cout << atoi("abc12") << endl; /*0*/

// 长整型函数名atoll，最高支持到long long型上限2^63。
```

### xxxxxxxxxx2 1p=(a+b+c)/2;2sum=sqrt(p*(p-a)*(p-b)\*(p-c));cpp

在提及这个函数时，我们先需要补充几点字典序相关的知识。

> 对于三个字符所组成的序列`{a,b,c}`，其按照字典序的 6 种排列分别为：
> `{abc}`，`{acb}`，`{bac}`，`{bca}`，`{cab}`，`{cba}`
> 其排序原理是：先固定 `a` (序列内最小元素)，再对之后的元素排列。而 `b` < `c` ，所以 `abc` < `acb` 。同理，先固定 `b` (序列内次小元素)，再对之后的元素排列。即可得出以上序列。

$\tt{}next\_permutation$ 算法，即是按照**字典序顺序**输出的全排列；相对应的， $\tt{}prev\_permutation$ 则是按照**逆字典序顺序**输出的全排列。可以是数字，亦可以是其他类型元素。其直接在序列上进行更新，故直接输出序列即可。

```cpp
int n;
cin >> n;
vector<int> a(n);
// iota(a.begin(), a.end(), 1);
for (auto &it : a) cin >> it;
sort(a.begin(), a.end());

do {
    for (auto it : a) cout << it << " ";
    cout << endl;
} while (next_permutation(a.begin(), a.end()));
```

### 字符串转换为数值函数 sto

可以快捷的将**一串字符串**转换为**指定进制的数字**。

使用方法

- `stoi(字符串, 0, x进制)` ：将一串 $\tt{}x$ 进制的字符串转换为 $\tt{}int$ 型数字。

![](https://img2020.cnblogs.com/blog/2491503/202201/2491503-20220117162754548-696368550.png)

- `stoll(字符串, 0, x进制)` ：将一串 $\tt{}x$ 进制的字符串转换为 $\tt{}long\ long$ 型数字。
- $\tt{}stoull，stod，stold$ 同理。

### 数值转换为字符串函数 to_string

允许将**各种数值类型**转换为字符串类型。

```cpp
//将数值num转换为字符串s
string s = to_string(num);
```

### 判断非递减 is_sorted

```cpp
//a数组[start,end)区间是否是非递减的，返回bool型
cout << is_sorted(a + start, a + end);
```

### 累加 accumulate

```cpp
//将a数组[start,end)区间的元素进行累加，并输出累加和+x的值
cout << accumulate(a + start, a + end, x);
```

### 迭代器 iterator

```cpp
//构建一个UUU容器的正向迭代器，名字叫it
UUU::iterator it;

vector<int>::iterator it; //创建一个正向迭代器，++ 操作时指向下一个
vector<int>::reverse_iterator it; //创建一个反向迭代器，++ 操作时指向上一个
```

### 特殊函数 `next` 和 `prev` 详解：

```cpp
auto it = s.find(x); // 建立一个迭代器
prev(it) / next(it); // 默认返回迭代器it的前/后一个迭代器
prev(it, 2) / next(it, 2); // 可选参数可以控制返回前/后任意个迭代器

/* 以下是一些应用 */
auto pre = prev(s.lower_bound(x)); // 返回第一个<x的迭代器
int ed = *prev(S.end(), 1); // 返回最后一个元素
```

### 其他函数

`exp2(x)` ：返回 $2^x$

`log2(x)` ：返回 $\log_2(x)$

`gcd(x, y) / lcm(x, y)` ：以 $\log$ 的复杂度返回 $\gcd(|x|, |y|)$ 与 ${\tt lcm}(|x|, |y|)$ ，且返回值符号也为正数。

## 容器与成员函数

### 优先队列 priority_queue

默认升序（大根堆），自定义排序需要重载 `<` 。

```cpp
//没有clear函数
priority_queue<int, vector<int>, greater<int> > p; //重定义为降序（小根堆）
push(x); //向栈顶插入x
top(); //获取栈顶元素
pop(); //弹出栈顶元素
```

```cpp
//重载运算符【注意，符号相反！！！】
struct Node {
    int x; string s;
    friend bool operator < (const Node &a, const Node &b) {
        if (a.x != b.x) return a.x > b.x;
        return a.s > b.s;
    }
};
```

### bitset

将数据转换为二进制，从高位到低位排序，以 $0$ 为最低位。当位数相同时支持全部的位运算。

```cpp
// 如果输入的是01字符串，可以直接使用">>"读入
bitset<10> s;
cin >> s;

//使用只含01的字符串构造——bitset<容器长度>B (字符串)
string S; cin >> S;
bitset<32> B (S);

//使用整数构造（两种方式）
int x; cin >> x;
bitset<32> B1 (x);
bitset<32> B2 = x;

// 构造时，尖括号里的数字不能是变量
int x; cin >> x;
bitset<x> ans; // 错误构造

[] //随机访问
set(x) //将第x位置1，x省略时默认全部位置1
reset(x) //将第x位置0，x省略时默认全部位置0
flip(x) //将第x位取反，x省略时默认全部位取反
to_ullong() //重转换为ULL类型
to_string() //重转换为ULL类型
count() //返回1的个数
any() //判断是否至少有一个1
none() //判断是否全为0

_Find_fisrt() // 找到从低位到高位第一个1的位置
_Find_next(x) // 找到当前位置x的下一个1的位置，复杂度 O(n/w + count)

bitset<23> B1("11101001"), B2("11101000");
cout << (B1 ^ B2) << "\n";  //按位异或
cout << (B1 | B2) << "\n";  //按位或
cout << (B1 & B2) << "\n";  //按位与
cout << (B1 == B2) << "\n"; //比较是否相等
cout << B1 << " " << B2 << "\n"; //你可以直接使用cout输出
```

### 哈希系列 unordered

通常指代 unordered_map、unordered_set、unordered_multimap、unordered_multiset，与原版相比不进行排序。

如果将不支持哈希的类型作为 `key` 值代入，编译器就无法正常运行，这时需要我们为其手写哈希函数。而我们写的这个哈希函数的正确性其实并不是特别重要（但是不可以没有），当发生冲突时编译器会调用 `key` 的 `operator ==` 函数进行进一步判断。[参考](https://finixlei.blog.csdn.net/article/details/110267430?spm=1001.2101.3001.6650.3&utm_medium=distribute.pc_relevant.none-task-blog-2%7Edefault%7EBlogCommendFromBaidu%7ERate-3-110267430-blog-101406104.topnsimilarv1&depth_1-utm_source=distribute.pc_relevant.none-task-blog-2%7Edefault%7EBlogCommendFromBaidu%7ERate-3-110267430-blog-101406104.topnsimilarv1&utm_relevant_index=4)

#### 对 pair、tuple 定义哈希

```cpp
struct hash_pair {
    template<typename T1, typename T2>
    size_t operator()(const pair<T1, T2> &p) const {
        return hash<T1>()(p.fi) ^ hash<T2>()(p.se);
    }
};
unordered_set<pair<int, int>, int, hash_pair> S;
unordered_map<tuple<int, int, int>, int, hash_pair> M;
```

#### 对结构体定义哈希

需要两个条件，一个是在结构体中重载等于号（区别于非哈希容器需要重载小于号，如上所述，当冲突时编译器需要根据重载的等于号判断），第二是写一个哈希函数。注意 `hash<>()` 的尖括号中的类型匹配。

```cpp
struct fff {
    string x, y;
    int z;
    friend bool operator == (const fff &a, const fff &b) {
        return a.x == b.x || a.y == b.y || a.z == b.z;
    }
};
struct hash_fff {
    size_t operator()(const fff &p) const {
        return hash<string>()(p.x) ^ hash<string>()(p.y) ^ hash<int>()(p.z);
    }
};
unordered_map<fff, int, hash_fff> mp;
```

#### 对 vector 定义哈希

以下两个方法均可。注意 `hash<>()` 的尖括号中的类型匹配。

```cpp
struct hash_vector {
    size_t operator()(const vector<int> &p) const {
        size_t seed = 0;
        for (auto it : p) {
            seed ^= hash<int>()(it);
        }
        return seed;
    }
};
unordered_map<vector<int>, int, hash_vector> mp;
```

```cpp
namespace std {
    template<> struct hash<vector<int>> {
        size_t operator()(const vector<int> &p) const {
            size_t seed = 0;
            for (int i : p) {
                seed ^= hash<int>()(i) + 0x9e3779b9 + (seed << 6) + (seed >> 2);
            }
            return seed;
        }
    };
}
unordered_set<vector<int> > S;
```

<div style="page-break-after:always">/END/</div>
