#import "../prelude.typ": *

= 数据结构 B
<数据结构-b>
数据结构 A 之外的补充：线性 RMQ、珂朵莉树、pbds 平衡树、vector 暴力与若干结论/例题。选型信号：静态 RMQ 卡 log → 线性 RMQ；区间推平为主且数据随机 → 珂朵莉树；要有序集合的排名/前驱后继又不想手写平衡树 → pbds `tree`。

== 基于状压的线性 RMQ 算法
<基于状压的线性-rmq-算法>
#specline([预处理 #O($N$)（严格）], [查询 #O($1$)])
查询区间为#strong[左闭右开 $\[ l , r \)$];，仅支持静态数组；`T` 需可用 `cmp` 比较（默认 `less<T>`，取区间最大改为 `greater<T>`）。

#include-code("code/数据结构B/基于状压的线性-RMQ-算法.cpp")

== 珂朵莉树 \(OD Tree)
<珂朵莉树-od-tree>
#specline([随机数据约 #O($N "log" "log" N$)])
核心是 `split(pos)` 把含 `pos` 的区间拆成两段并返回左端点为 `pos` 的段，`assign(l, r, x)` 把区间推平成一个值——只有大量区间覆盖/推平操作才有收益。常用：`add(l,r,x)` 区间加，`kth(l,r,k)` 区间第 $k$ 小，`powersum(l,r,x,mod)` 区间元素 $x$ 次方和模 `mod`。

#pitfall[复杂度保证只在数据随机时成立，否则可被构造卡回 #O($N^2$)。]

#include-code("code/数据结构B/珂朵莉树-OD-Tree.cpp")

== pbds 扩展库实现平衡二叉树
<pbds-扩展库实现平衡二叉树>
记得加上下面的头文件与命名空间。模板第三个参数是比较器（默认 `less`，改成 `greater` 即翻转顺序）。`tree` 不容许重复键，用第二维计数 `{x, ++dic[x]}` 实现可重集合（见下例）。

#quote(block: true)[
附常见成员函数：

```cpp
empty() / size()
insert(x) // 插入元素x
erase(x) // 删除元素/迭代器x
order_of_key(x) // 返回元素x的排名
find_by_order(x) // 返回排名为x的元素迭代器
lower_bound(x) / upper_bound(x) // 返回迭代器
join(Tree) // 将Tree树的全部元素并入当前的树
split(x, Tree) // 将大于x的元素放入Tree树
```
]

```cpp
#include <ext/pb_ds/assoc_container.hpp>
using namespace __gnu_pbds;
using V = pair<int, int>;
tree<V, null_type, less<V>, rb_tree_tag, tree_order_statistics_node_update> ver;
map<int, int> dic;

int n; cin >> n;
for (int i = 1, op, x; i <= n; i++) {
    cin >> op >> x;
    if (op == 1) {  // 插入一个元素x，允许重复
        ver.insert({x, ++dic[x]});
    } else if (op == 2) { // 删除元素x，若有重复，则任意删除一个
        ver.erase({x, dic[x]--});
    } else if (op == 3) { // 查询元素x的排名（排名定义为比当前数小的数的个数+1）
        cout << ver.order_of_key({x, 1}) + 1 << endl;
    } else if (op == 4) { // 查询排名为x的元素
        cout << ver.find_by_order(--x)->first << endl;
    } else if (op == 5) { // 查询元素x的前驱
        int idx = ver.order_of_key({x, 1}) - 1;  // 无论x存不存在，idx都代表x的位置，需要-1
        cout << ver.find_by_order(idx)->first << endl;
    } else if (op == 6) { // 查询元素x的后继
        int idx = ver.order_of_key( {x, dic[x]}); // 如果x不存在，那么idx就是x的后继
        if (ver.find({x, 1}) != ver.end()) idx++; // 如果x存在，那么idx是x的位置，需要+1
        cout << ver.find_by_order(idx)->first << endl;
    }
}
```

== vector 模拟实现平衡二叉树
<vector-模拟实现平衡二叉树>
#specline([单次 #O($N$)], [总计 #O($N^2$)])
用 `lower_bound` 定位后在中间插入/删除，#strong[只适合小数据或暴力骗分];；需要 $cal(O)("log" N)$ 维护有序序列请用 pbds `tree`。

#include-code("code/数据结构B/vector-模拟实现平衡二叉树.cpp")

== 常见结论
<常见结论>
题意：（区间移位问题）要求将整个序列左移/右移若干个位置，例如，原序列为 $A = (a_1 , a_2 , dots.h , a_n)$ ，右移 $x$ 位后变为 $A = (a_(x + 1) , a_(x + 2) , dots.h , a_n , a_1 , a_2 , dots.h , a_x)$ 。

区间的端点只是一个数字，即使被改变了，通过一定的转换也能够还原，所以我们可以 $cal(O)(1)$ 解决这一问题。为了方便计算，我们规定下标从 $0$ 开始，即整个线段的区间为 $\[ 0 , n \)$ ，随后，使用一个偏移量 `shift` 记录。使用 `shift = (shift + x) % n;` 更新偏移量；此后的区间查询/修改前，再将坐标偏移回去即可，下方代码使用区间修改作为示例。

```cpp
cin >> l >> r >> x;
l--;  // 坐标修改为 0 开始
r--;
l = (l + shift) % n;  // 偏移
r = (r + shift) % n;
if (l > r) {  // 区间分离则分别操作
    segt.modify(l, n - 1, x);
    segt.modify(0, r, x);
} else {
    segt.modify(l, r, x);
}
```

== 常见例题
<常见例题>
题意：（带修莫队 - 维护队列）要求能够处理以下操作：

- `'Q' l r` ：询问区间 $[l , r]$ 有几个颜色；
- `'R' idx w` ：将下标 `idx` 的颜色修改为 `w`。

输入格式为：第一行 $n$ 和 $q med (1 lt.eq n , q lt.eq 133333)$ 分别代表区间长度和操作数量；第二行 $n$ 个整数 $a_1 , a_2 dots.h , a_n med (1 lt.eq a_i lt.eq 10^6)$ 代表初始颜色；随后 $q$ 行为具体操作。

带修莫队 \= 普通莫队 + 时间维：查询按（左端点块，右端点块，时间）排序，`t` 指针沿时间维移动，`time()` 中用 `swap` 回溯修改；复杂度约 $cal(O)(n^(5 / 3))$。

#include-code("code/数据结构B/常见例题.cpp")
