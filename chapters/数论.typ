#import "../prelude.typ": *

= 数论
<数论>
整除、同余、素数、积性函数，前半是定义与性质速查表，后半是板子。选型信号：模意义除法 → 逆元；$10^18$ 级模乘 → 防爆模乘；大数判素/分解 → Miller-Rabin + Pollard-Rho；积性函数前缀和 → 筛法 / Min25；同余方程组 → excrt。

#quote(block: true)[
本章前半为定义与性质速查表，后半为板子；代码中 `LL` / `i64` 为 `long long`，`mod` / `MOD` / `p` 为模数，按题目替换。
]

== 整除
<整除>
#strong[定义] 设 $a , b in bold(Z)$，$a eq.not 0$。如果 $exists q in bold(Z)$，使得 $b = a q$，那么就说 $b$ 可被 $a$ #strong[整除];，记作 $a divides b$；$b$ 不被 $a$ 整除记作 $a divides.not b$。

整除的性质：

- $a divides b arrow.l.r.double - a divides b arrow.l.r.double a divides - b arrow.l.r.double lr(|a|) divides lr(|b|)$
- $a divides b and b divides c arrow.r.double.long a divides c$
- $a divides b and a divides c arrow.l.r.double forall x , y in bold(Z) , a divides (x b + y c)$
- $a divides b and b divides a arrow.r.double.long b = plus.minus a$
- 设 $m eq.not 0$，那么 $a divides b arrow.l.r.double m a divides m b$。
- 设 $b eq.not 0$，那么 $a divides b arrow.r.double.long lr(|a|) lt.eq lr(|b|)$。
- 设 $a eq.not 0 , b = q a + c$，那么 $a divides b arrow.l.r.double a divides c$。

=== 约数
<约数>
#strong[定义] 若 $a divides b$，则称 $b$ 是 $a$ 的 #strong[倍数];，$a$ 是 $b$ 的 #strong[约数];。

$0$ 是所有非 $0$ 整数的倍数。对于整数 $b eq.not 0$，$b$ 的约数只有有限个。

平凡约数（平凡因数）：对于整数 $b eq.not 0$，$plus.minus 1$、$plus.minus b$ 是 $b$ 的平凡约数。当 $b = plus.minus 1$ 时，$b$ 只有两个平凡约数。

对于整数 $b eq.not 0$，$b$ 的其他约数称为真约数（真因数、非平凡约数、非平凡因数）。

约数的性质：

- 设整数 $b eq.not 0$。当 $d$ 遍历 $b$ 的全体约数的时候，$b / d$ 也遍历 $b$ 的全体约数。
- 设整数 $b > 0$，则当 $d$ 遍历 $b$ 的全体正约数的时候，$b / d$ 也遍历 $b$ 的全体正约数。

== 带余数除法
<带余数除法>
#strong[余数] 设 $a , b$ 为两个给定的整数，$a eq.not 0$。设 $d$ 是一个给定的整数。那么，一定存在唯一的一对整数 $q$ 和 $r$，满足 $b = q a + r , d lt.eq r < lr(|a|) + d$。

无论整数 $d$ 取何值，$r$ 统称为余数。$a divides b$ 等价于 $a divides r$。

一般情况下，$d$ 取 $0$，此时等式 $b = q a + r , 0 lt.eq r < lr(|a|)$ 称为带余数除法（带余除法）。这里的余数 $r$ 称为最小非负余数。

余数往往还有两种常见取法：

- 绝对最小余数：$d$ 取 $a$ 的绝对值的一半的相反数。即 $b = q a + r , - lr(|a|) / 2 lt.eq r < lr(|a|) - lr(|a|) / 2$。
- 最小正余数：$d$ 取 $1$。即 $b = q a + r , 1 lt.eq r < lr(|a|) + 1$。

带余数除法的余数只有最小非负余数。#strong[如果没有特别说明，余数总是指最小非负余数。]

余数的性质：

- 任一整数被正整数 $a$ 除后，余数一定是且仅是 $0$ 到 $(a - 1)$ 这 $a$ 个数中的一个。
- 相邻的 $a$ 个整数被正整数 $a$ 除后，恰好取到上述 $a$ 个余数。特别地，一定有且仅有一个数被 $a$ 整除。

== 最大公约数与最小公倍数
<最大公约数与最小公倍数>
四个名词的定义不再赘述（本节的标题即前两者的定义）。

#strong[Warning] 一些作者认为 $0$ 和 $0$ 的最大公约数无定义，其余作者一般将其视为 $0$。C++ STL 的实现中采用后者，即认为 $0$ 和 $0$ 的最大公约数为 $0$。

最大公约数有如下性质：

- $(a_1 , dots.h , a_n) = (lr(|a_1|) , dots.h , lr(|a_n|))$；
- $(a , b) = (b , a)$；
- 若 $a eq.not 0$，则 $(a , 0) = (a , a) = lr(|a|)$；
- $(b q + r , b) = (r , b)$；
- $(a_1 , dots.h , a_n) = ((a_1 , a_2) , a_3 , dots.h , a_n)$。进而 $forall 1 < k < n - 1 , med (a_1 , dots.h , a_n) = ((a_1 , dots.h , a_k) , (a_(k + 1) , dots.h , a_n))$；
- 对不全为 $0$ 的整数 $a_1 , dots.h , a_n$ 和非零整数 $m$，$(m a_1 , dots.h , m a_n) = lr(|m|) (a_1 , dots.h , a_n)$；
- 对不全为 $0$ 的整数 $a_1 , dots.h , a_n$，若 $(a_1 , dots.h , a_n) = d$，则 $(a_1 \/ d , dots.h , a_n \/ d) = 1$；
- $(a^n , b^n) = (a , b)^n$。

最大公约数还有如下与互素相关的性质：

- 若 $b \| a c$ 且 $(a , b) = 1$，则 $b divides c$；
- 若 $b \| c$、$a \| c$ 且 $(a , b) = 1$，则 $a b divides c$；
- 若 $(a , b) = 1$，则 $(a , b c) = (a , c)$；
- 若 $(a_i , b_j) = 1 , med forall 1 lt.eq i lt.eq n , 1 lt.eq j lt.eq m$，则 $(product_i a_i , product_j b_j) = 1$。特别地，若 $(a , b) = 1$，则 $(a^n , b^m) = 1$；
- 对整数 $a_1 , dots.h , a_n$，若 $exists v in bold(Z) , med product_i a_i = v^m$，且 $(a_i , a_j) = 1 , med forall i eq.not j$，则 $forall 1 lt.eq i lt.eq n , med root(m, a_i) in bold(Z)$。

最小公倍数有如下性质：

- $[a_1 , dots.h , a_n] = [lr(|a_1|) , dots.h , lr(|a_n|)]$；
- $[a , b] = [b , a]$；
- 若 $a eq.not 0$，则 $[a , 1] = [a , a] = lr(|a|)$；
- 若 $a divides b$，则 $[a , b] = lr(|b|)$；
- $[a_1 , dots.h , a_n] = [[a_1 , a_2] , a_3 , dots.h , a_n]$。进而 $forall 1 < k < n - 1 , med [a_1 , dots.h , a_n] = [[a_1 , dots.h , a_k] , [a_(k + 1) , dots.h , a_n]]$；
- 若 $a_i divides m , med forall 1 lt.eq i lt.eq n$，则 $[a_1 , dots.h , a_n] divides m$；
- $[m a_1 , dots.h , m a_n] = lr(|m|) [a_1 , dots.h , a_n]$；
- $[a , b , c] [a b , b c , c a] = [a , b] [b , c] [c , a]$；
- $[a^n , b^n] = [a , b]^n$。

最大公约数和最小公倍数可以组合出很多奇妙的等式，如：

- $(a , b) [a , b] = lr(|a b|)$；
- $(a b , b c , c a) [a , b , c] = lr(|a b c|)$；
- $frac((a , b , c)^2, (a , b) (b , c) (a , c)) = frac([a , b , c]^2, [a , b] [b , c] [a , c])$。

这些性质均可通过定义或 #link(<算术基本定理>)[唯一分解定理] 证明，其中使用唯一分解定理的证明更容易理解。

=== 互素
<互素>
#strong[定义] 若 $(a_1 , a_2) = 1$，则称 $a_1$ 和 $a_2$ #strong[互素];（#strong[既约];）。

若 $(a_1 , dots.h , a_k) = 1$，则称 $a_1 , dots.h , a_k$ #strong[互素];（#strong[既约];）。

多个整数互素，不一定两两互素。例如 $6$、$10$ 和 $15$ 互素，但是任意两个都不互素。

互素的性质与最大公约数理论：裴蜀定理（Bézout’s identity），见 #link(<裴蜀定理>)[后节];。

== 素数与合数
<素数与合数>
关于素数的算法见 #link(<欧拉筛-线性筛>)[欧拉筛（线性筛）];。

#strong[定义] 设整数 $p eq.not 0 , plus.minus 1$。如果 $p$ 除了平凡约数外没有其他约数，那么称 $p$ 为 #strong[素数];（#strong[不可约数];）。

若整数 $a eq.not 0 , plus.minus 1$ 且 $a$ 不是素数，则称 $a$ 为 #strong[合数];。

$p$ 和 $- p$ 总是同为素数或者同为合数。#strong[如果没有特别说明，素数总是指正的素数。]

整数的因数是素数，则该素数称为该整数的素因数（素约数）。

素数与合数的简单性质：

- 大于 $1$ 的整数 $a$ 是合数，等价于 $a$ 可以表示为整数 $d$ 和 $e$（$1 < d , e < a$）的乘积。
- 如果素数 $p$ 有大于 $1$ 的约数 $d$，那么 $d = p$。
- 大于 $1$ 的整数 $a$ 一定可以表示为素数的乘积。
- 对于合数 $a$，一定存在素数 $p lt.eq sqrt(a)$ 使得 $p divides a$。
- 素数有无穷多个。
- 所有大于 $3$ 的素数都可以表示为 $6 n plus.minus 1$ 的形式。

== 算术基本定理
<算术基本定理>
#strong[算术基本引理] 设 $p$ 是素数，$p divides a_1 a_2$，那么 $p divides a_1$ 和 $p divides a_2$ 至少有一个成立。

算术基本引理的逆命题稍加修改也可以得到素数的另一种定义。

#strong[素数的另一种定义] 对整数 $p eq.not 0 , plus.minus 1$，若对任意满足 $p divides a_1 a_2$ 的整数 $a_1 , a_2$ 均有 $p divides a_1$ 或 $p divides a_2$ 成立，则称 $p$ 是素数。

#strong[Tip] 这个定义的动机可以从素理想中找到。

#strong[算术基本定理（唯一分解定理）] 设正整数 $a$，那么必有表示：

$ a = p_1 p_2 dots.h.c p_s $

其中 $p_j (1 lt.eq j lt.eq s)$ 是素数。并且在不计次序的意义下，该表示唯一。

#strong[标准素因数分解式] 将上述表示中，相同的素数合并，可得：

$ a = p_1^(alpha_1) p_2^(alpha_2) dots.h.c p_s^(alpha_s) , p_1 < p_2 < dots.h.c < p_s $

称为正整数 $a$ 的标准素因数分解式。

算术基本定理和算术基本引理，两个定理是等价的。

== 同余
<同余>
#strong[定义] 设整数 $m eq.not 0$。若 $m divides (a - b)$，称 $m$ 为 #strong[模数];（#strong[模];），$a$ 同余于 $b$ 模 $m$，$b$ 是 $a$ 对模 $m$ 的 #strong[剩余];。记作 $a equiv b (mod m)$。

否则，$a$ 不同余于 $b$ 模 $m$，$b$ 不是 $a$ 对模 $m$ 的剩余。记作 $a equiv.not b (mod m)$。

这样的等式，称为模 $m$ 的同余式，简称 #strong[同余式];。

根据整除的性质，上述同余式也等价于 $a equiv b (mod (- m) \)$。

后文中，如果没有特别说明，模数总是 #strong[正整数];。

式中的 $b$ 是 $a$ 对模 $m$ 的剩余，这个概念与余数完全一致。通过限定 $b$ 的范围，相应的有 $a$ 对模 $m$ 的最小非负剩余、绝对最小剩余、最小正剩余。

同余的性质：

- 同余是等价关系，即同余具有
  - 自反性：$a equiv a (mod m)$。
  - 对称性：若 $a equiv b (mod m)$，则 $b equiv a (mod m)$。
  - 传递性：若 $a equiv b (mod m) , b equiv c (mod m)$，则 $a equiv c (mod m)$。
- 线性运算：若 $a , b , c , d in bold(Z) , m in bold(N)^(\*) , a equiv b (mod m) , c equiv d (mod m)$ 则有：
  - $a plus.minus c equiv b plus.minus d (mod m)$。
  - $a times c equiv b times d (mod m)$。
- 设 $f (x) = sum_(i = 0)^n a_i x^i$ 和 $g (x) = sum_(i = 0)^n b_i x^i$ 是两个整系数多项式，$m in bold(N)^(\*)$，且 $a_i equiv b_i (mod m) , med 0 lt.eq i lt.eq n$，则对任意整数 $x$ 均有 $f (x) equiv g (x) (mod m)$。进而若 $s equiv t (mod m)$，则 $f (s) equiv g (t) (mod m)$。
- 若 $a , b in bold(Z) , k , m in bold(N)^(\*) , a equiv b (mod m)$, 则 $a k equiv b k (mod m k)$。
- 若 $a , b in bold(Z) , d , m in bold(N)^(\*) , d divides a , d divides b , d divides m$，则当 $a equiv b (mod m)$ 成立时，有 $a / d equiv b / d (mod m / d)$。
- 若 $a , b in bold(Z) , d , m in bold(N)^(\*) , d divides m$，则当 $a equiv b (mod m)$ 成立时，有 $a equiv b (mod d)$。
- 若 $a , b in bold(Z) , d , m in bold(N)^(\*)$，则当 $a equiv b (mod m)$ 成立时，有 $(a , m) = (b , m)$。若 $d$ 能整除 $m$ 及 $a , b$ 中的一个，则 $d$ 必定能整除 $a , b$ 中的另一个。

还有性质是乘法逆元，见 #link(<逆元>)[逆元];。

== 同余类与剩余系
<同余类与剩余系>
为方便讨论，对集合 $A , B$ 和元素 $r$，我们引入如下记号：

- $r + A := { r + a : a in A }$；
- $r A := { r a : a in A }$；
- $A + B := { a + b : a in A , b in B }$；
- $A B := { a b : a in A , b in B }$。

#strong[同余类] 对非零整数 $m$，把全体整数分成 $lr(|m|)$ 个两两不交的集合，且同一个集合中的任意两个数模 $m$ 均同余，我们把这 $lr(|m|)$ 个集合均称为模 $m$ 的 #strong[同余类] 或 #strong[剩余类];。用 $r mod m$ 表示含有整数 $r$ 的模 $m$ 的同余类。

不难证明对任意非零整数 $m$，上述划分方案一定存在且唯一。

由同余类的定义可知：

- $r mod m = { r + k m : k in bold(Z) }$；
- $r mod m = s mod m arrow.l.r.double r equiv s (mod m)$；
- 对任意 $r , s in bold(Z)$，要么 $r mod m = s mod m$，要么 $(r mod m) inter (s mod m) = diameter$；
- 若 $m_1 divides m$，则对任意整数 $r$ 均有 $r + m bold(Z) subset.eq r + m_1 bold(Z)$。

注意到同余是等价关系，所以同余类即为同余关系的等价类。

我们把模 $m$ 的同余类全体构成的集合记为 $bold(Z)_m$，即

$ bold(Z)_m := { r mod m : 0 lt.eq r < m } $

不难发现：

- 对任意整数 $a$，$a + bold(Z)_m = bold(Z)_m$；
- 对任意与 $m$ 互质的整数 $b$，$b bold(Z)_m = bold(Z)_m$。

由商群的定义可知 $bold(Z)_m = bold(Z) \/ m bold(Z)$，所以有时我们也会用 $bold(Z) \/ m bold(Z)$ 表示 $bold(Z)_m$。

由抽屉原理可知：

- 任取 $m + 1$ 个整数，必有两个整数模 $m$ 同余。
- 存在 $m$ 个两两模 $m$ 不同余的整数。

由此我们给出完全剩余系的定义：

#strong[完全剩余系] 对 $m$ 个整数 $a_1 , a_2 , dots.h , a_m$，若对任意的数 $x$，有且仅有一个数 $a_i$ 使得 $x$ 与 $a_i$ 模 $m$ 同余，则称这 $m$ 个整数 $a_1 , a_2 , dots.h , a_m$ 为模 $m$ 的 #strong[完全剩余系];，简称 #strong[剩余系];。

我们还可以定义模 $m$ 的：

- 最小非负（完全）剩余系：$0 , dots.h , m - 1$；
- 最小正（完全）剩余系：$1 , dots.h , m$；
- 绝对最小（完全）剩余系：$- ⌊ m \/ 2 ⌋ , dots.h , - ⌊ - m \/ 2 ⌋ - 1$；
- 最大非正（完全）剩余系：$- m + 1 , dots.h , 0$；
- 最大负（完全）剩余系：$- m , dots.h , - 1$。

若无特殊说明，一般我们只用最小非负剩余系。

我们注意到如下命题成立：

- 在模 $m$ 的任意一个同余类中，任取两个整数 $a_1 , a_2$ 均有 $(a_1 , m) = (a_2 , m)$。

考虑同余类 $r mod m$，若 $(r , m) = 1$，则该同余类的所有元素均与 $m$ 互质，这说明我们也许可以通过类似方式得知所有与 $m$ 互质的整数构成的集合的结构。

#strong[既约同余类] 对同余类 $r mod m$，若 $(r , m) = 1$，则称该同余类为 #strong[既约同余类] 或 #strong[既约剩余类];。

我们把模 $m$ 既约剩余类的个数记作 $phi (m)$，称其为 Euler 函数（欧拉函数，见 #link(<欧拉函数>)[后节];）。

我们把模 $m$ 的既约同余类全体构成的集合记为 $bold(Z)_m^(\*)$，即

$ bold(Z)_m^(\*) := { r mod m : 0 lt.eq r < m , (r , m) = 1 } $

#strong[Warning] 对于任意的整数 $a$ 和与 $m$ 互质的整数 $b$，$b bold(Z)_m^(\*) = bold(Z)_m^(\*)$，但是 $a + bold(Z)_m^(\*)$ 不一定为 $bold(Z)_m^(\*)$。这一点与 $bold(Z)_m$ 不同。

由抽屉原理可知：

- 任取 $phi (m) + 1$ 个与 $m$ 互质的整数，必有两个整数模 $m$ 同余。
- 存在 $phi (m)$ 个与 $m$ 互质且两两模 $m$ 不同余的整数。

由此我们给出既约剩余系的定义：

#strong[既约剩余系] 对 $t = phi (m)$ 个整数 $a_1 , a_2 , dots.h , a_t$，若 $(a_i , m) = 1 , med forall 1 lt.eq i lt.eq t$，且对任意满足 $(x , m) = 1$ 的数 $x$，有且仅有一个数 $a_i$ 使得 $x$ 与 $a_i$ 模 $m$ 同余，则称这 $t$ 个整数 $a_1 , a_2 , dots.h , a_t$ 为模 $m$ 的 #strong[既约剩余系];、#strong[缩剩余系] 或 #strong[简化剩余系];。

类似地，我们也可以定义最小非负既约剩余系等概念。

若无特殊说明，一般我们只用最小非负既约剩余系。

=== 剩余系的复合
<剩余系的复合>
对正整数 $m$，我们有如下定理：

- 若 $m = m_1 m_2 , med 1 lt.eq m_1 , m_2$，令 $Z_(m_1) , Z_(m_2)$ 分别为模 $m_1 , m_2$ 的 #strong[完全] 剩余系，则对任意与 $m_1$ 互质的 $a$ 均有：

$ Z_m = a Z_(m_1) + m_1 Z_(m_2) . $

为模 $m$ 的 #strong[完全] 剩余系。进而，若 $m = product_(i = 1)^k m_i , med 1 lt.eq m_1 , m_2 , dots.h , m_k$，令 $Z_(m_1) , dots.h , Z_(m_k)$ 分别为模 $m_1 , dots.h , m_k$ 的 #strong[完全] 剩余系，则：

$ Z_m = sum_(i = 1)^k (product_(j = 1)^(i - 1) m_j) Z_(m_i) . $

为模 $m$ 的 #strong[完全] 剩余系。

#strong[证明] 只需证明对任意满足 $a x + m_1 y equiv a x prime + m_1 y prime (mod m_1 m_2)$ 的 $x , x prime in Z_(m_1)$，$y , y prime in Z_(m_2)$，都有：

$ a x + m_1 y = a x prime + m_1 y prime . $

实际上，由 $m_1 divides m_1 m_2$，我们有 $a x + m_1 y equiv a x prime + m_1 y prime (mod m_1)$，进而 $a x equiv a x prime (mod m_1)$，由 $(a , m_1) = 1$ 可知 $x equiv x prime (mod m_1)$，进而有 $x = x prime$。

进一步，$m_1 y equiv m_1 y prime (mod m_1 m_2)$，则 $y equiv y prime (mod m_2)$，即 $y = y prime$。

因此，

$ a x + m_1 y = a x prime + m_1 y prime . $

- 若 $m = m_1 m_2 , med 1 lt.eq m_1 , m_2 , (m_1 , m_2) = 1$，令 $Z_(m_1)^(\*) , Z_(m_2)^(\*)$ 分别为模 $m_1 , m_2$ 的 #strong[既约] 剩余系，则：

$ Z_m^(\*) = m_2 Z_(m_1)^(\*) + m_1 Z_(m_2)^(\*) . $

为模 $m$ 的 #strong[既约] 剩余系。

#strong[Tip] 该定理等价于证明 Euler 函数为积性函数。

#strong[证明] 令 $Z_(m_1) , Z_(m_2)$ 分别为模 $m_1 , m_2$ 的完全剩余系，我们已经证明了

$ Z_m = m_2 Z_(m_1) + m_1 Z_(m_2) $

为模 $m$ 的完全剩余系。令 $M = { a in Z_m : (a , m) = 1 } subset.eq Z_m$，显然 $M$ 为模 $m$ 的既约剩余系，所以我们只需证明 $M = Z_m^(\*)$ 即可。

显然 $Z_m^(\*) subset.eq Z_m$。

任取 $m_2 x + m_1 y in M$，其中 $x in Z_(m_1)$ 且 $y in Z_(m_2)$，有 $(m_2 x + m_1 y , m_1 m_2) = 1$，由 $(m_1 , m_2) = 1$ 可得

$ 1 = (m_2 x + m_1 y , m_1) = (m_2 x , m_1) = (x , m_1) , $

$ 1 = (m_2 x + m_1 y , m_2) = (m_1 y , m_2) = (y , m_2) . $

因此可得 $x in Z_(m_1)^(\*)$ 且 $y in Z_(m_2)^(\*)$，即 $M subset.eq Z_m^(\*)$。

任取 $m_2 x + m_1 y in Z_m^(\*)$，其中 $x in Z_(m_1)^(\*)$ 且 $y in Z_(m_2)^(\*)$，有 $(x , m_1) = 1$ 且 $(y , m_2) = 1$，由 $(m_1 , m_2) = 1$ 可得

$ (m_2 x + m_1 y , m_1) = (m_2 x , m_1) = (x , m_1) = 1 , $

$ (m_2 x + m_1 y , m_2) = (m_1 y , m_2) = (x , m_2) = 1 , $

因此可得 $(m_2 x + m_1 y , m_1 m_2) = 1$，即 $Z_m^(\*) subset.eq M$。

综上所述，

$ Z_m^(\*) = m_2 Z_(m_1)^(\*) + m_1 Z_(m_2)^(\*) . $

为模 $m$ 的 #strong[既约] 剩余系。

== 数论函数
<数论函数>
数论函数（也称算术函数）指定义域为正整数的函数。数论函数也可以视作一个数列。

=== 积性函数
<积性函数>
#strong[定义] 在数论中，若函数 $f (n)$ 满足 $f (1) = 1$，且 $f (x y) = f (x) f (y)$ 对任意互质的 $x , y in bold(N)^(\*)$ 都成立，则 $f (n)$ 为 #strong[积性函数];。

在数论中，若函数 $f (n)$ 满足 $f (1) = 1$ 且 $f (x y) = f (x) f (y)$ 对任意的 $x , y in bold(N)^(\*)$ 都成立，则 $f (n)$ 为 #strong[完全积性函数];。

==== 性质
<性质>
若 $f (x)$ 和 $g (x)$ 均为积性函数，则以下函数也为积性函数：

$ h (x) & = f (x^p)\
h (x) & = f^p (x)\
h (x) & = f (x) g (x)\
h (x) & = sum_(d divides x) f (d) g (x / d) $

对正整数 $x$，设其唯一质因数分解为 $x = product p_i^(k_i)$，其中 $p_i$ 为质数。

若 $F (x)$ 为积性函数，则有 $F (x) = product F (p_i^(k_i))$。

若 $F (x)$ 为完全积性函数，则有 $F (x) = product F (p_i^(k_i)) = product F (p_i)^(k_i)$。

==== 例子
<例子>
- 单位函数：$epsilon (n) = [n = 1]$。（完全积性）
- 恒等函数：$"id"_k (n) = n^k$，$"id"_1 (n)$ 通常简记作 $"id" (n)$。（完全积性）
- 常数函数：$1 (n) = 1$。（完全积性）
- 除数函数：$sigma_k (n) = sum_(d divides n) d^k$。$sigma_0 (n)$ 通常简记作 $d (n)$ 或 $tau (n)$，$sigma_1 (n)$ 通常简记作 $sigma (n)$。
- 欧拉函数：$phi (n) = sum_(i = 1)^n [(i , n) = 1]$。
- 莫比乌斯函数：$mu (n) = cases(1 & n = 1, 0 & exists d > 1 , d^2 divides n, (- 1)^(omega (n)) & upright("otherwise"))$，其中 $omega (n)$ 表示 $n$ 的本质不同质因子个数。

=== 加性函数
<加性函数>
#strong[定义] 在数论中，若函数 $f (n)$ 满足 $f (1) = 0$ 且 $f (x y) = f (x) + f (y)$ 对任意互质的 $x , y in bold(N)^(\*)$ 都成立，则 $f (n)$ 为 #strong[加性函数];。

在数论中，若函数 $f (n)$ 满足 $f (1) = 0$ 且 $f (x y) = f (x) + f (y)$ 对任意的 $x , y in bold(N)^(\*)$ 都成立，则 $f (n)$ 为 #strong[完全加性函数];。

#strong[加性函数] 本节中的加性函数指数论上的加性函数 \(Additive function)，应与代数中的 Additive map 做区分。

==== 性质
<性质-1>
对正整数 $x$，设其唯一质因数分解为 $x = product p_i^(k_i)$，其中 $p_i$ 为质数。

若 $F (x)$ 为加性函数，则有 $F (x) = sum F (p_i^(k_i))$。

若 $F (x)$ 为完全加性函数，则有 $F (x) = sum F (p_i^(k_i)) = sum F (p_i) dot k_i$。

==== 例子
<例子-1>
为方便叙述，令所有质数组成的集合为 $bold(P)$.

- 素因数分解中 $p$ 的重数：$nu_p (n) = "max" { k in bold(N) : p^k divides n }$，其中，$p in bold(P)$。（完全加性）
- 所有质因子数目：$Omega (n) = sum_(p in bold(P)) nu_p (n)$。（完全加性）
- 相异质因子数目：$omega (n) = sum_(p in bold(P)) [p divides n]$。
- 所有质因子之和：$a_0 (n) = sum_(p in bold(P)) nu_p (n) dot p$。（完全加性）
- 相异质因子之和：$a_1 (n) = sum_(p in bold(P)) [p divides n] dot p$。

== 取整函数
<取整函数>
对于实数 $x$，定义 #strong[下取整函数];（floor function）和 #strong[上取整函数];（ceiling function）分别为

$ ⌊ x ⌋ = "max" { k in bold(Z) : k lt.eq x } , med ⌈ x ⌉ = "min" { k in bold(Z) : k gt.eq x } . $

利用下取整函数，一个实数可以分解为整数部分和小数部分：$x = ⌊ x ⌋ + { x }$。其中，${ x }$ 表示 $x$ 的小数部分。

取整函数有如下基本性质：（$x in bold(R) , med n in bold(Z)$）

- $x in bold(Z) arrow.l.r.double x = ⌊ x ⌋ = ⌈ x ⌉$。
- $⌈ x ⌉ - ⌊ x ⌋ = [x in.not bold(Z)]$。
- $x - 1 < ⌊ x ⌋ lt.eq x lt.eq ⌈ x ⌉ < x + 1$。
- $⌊ - x ⌋ = - ⌈ x ⌉ , med ⌈ - x ⌉ = - ⌊ x ⌋$。
- $⌊ x + n ⌋ = ⌊ x ⌋ + n , med ⌈ x + n ⌉ = ⌈ x ⌉ + n$。
- $⌊ x ⌋$ 和 $⌈ x ⌉$ 都是关于 $x$ 的单调弱增函数。

证明关于下（上）取整函数的等式经常用到如下等价形式：（$x in bold(R) , med n in bold(Z)$）

- $⌊ x ⌋ = n arrow.l.r.double n lt.eq x < n + 1 arrow.l.r.double x - 1 < n lt.eq x$。
- $⌈ x ⌉ = n arrow.l.r.double n - 1 < x lt.eq n arrow.l.r.double x lt.eq n < x + 1$。

证明关于下（上）取整函数的不等式经常用到如下等价形式：（$x in bold(R) , med n in bold(Z)$）

- $x < n arrow.l.r.double ⌊ x ⌋ < n$。
- $n < x arrow.l.r.double n < ⌈ x ⌉$。
- $x lt.eq n arrow.l.r.double ⌈ x ⌉ lt.eq n$。
- $n lt.eq x arrow.l.r.double n lt.eq ⌊ x ⌋$。

涉及和、差的性质如下：（$x , y in bold(R)$）

- $⌊ x ⌋ + ⌊ y ⌋ lt.eq ⌊ x + y ⌋ lt.eq ⌊ x ⌋ + ⌊ y ⌋ + 1$，且恰有一个等号成立。
- $⌈ x ⌉ + ⌈ y ⌉ - 1 lt.eq ⌈ x + y ⌉ lt.eq ⌈ x ⌉ + ⌈ y ⌉$，且恰有一个等号成立。
- $⌊ lr(|x - y|) ⌋ lt.eq lr(|⌊ x ⌋ - ⌊ y ⌋|) lt.eq ⌈ lr(|x - y|) ⌉$。
- $⌊ lr(|x - y|) ⌋ lt.eq lr(|⌈ x ⌉ - ⌈ y ⌉|) lt.eq ⌈ lr(|x - y|) ⌉$。

涉及商的性质如下：（$x in bold(R) , med n in bold(Z) , med m in bold(Z)_(+)$）

- $⌈n / m⌉ = ⌊frac(n + m - 1, m)⌋ , med ⌊n / m⌋ = ⌈frac(n - m + 1, m)⌉$。
- $⌊frac(x + n, m)⌋ = ⌊frac(⌊ x ⌋ + n, m)⌋ , med ⌈frac(x + n, m)⌉ = ⌈frac(⌈ x ⌉ + n, m)⌉$。
- $⌊frac(⌊ x \/ n ⌋, m)⌋ = ⌊frac(x, n m)⌋ , med ⌈frac(⌈ x \/ n ⌉, m)⌉ = ⌈frac(x, n m)⌉$。
- 对于 $x > 0$，有 $⌊x / m⌋ = sum_(k = 1)^(⌊ x ⌋) [m divides k]$。

其中，第二条和第三条性质都可以看作是如下结论的直接推论：

- 设 $f$ 为连续单增函数，且只要 $f (x) in bold(Z)$，就有 $x in bold(Z)$，那么

$ ⌊ f (x) ⌋ = ⌊ f (⌊ x ⌋) ⌋ , med ⌈ f (x) ⌉ = ⌈ f (⌈ x ⌉) ⌉ . $

#strong[证明] 由对称性，只需要证明第一个等式。如果 $x$ 是整数，那么命题显然。否则，$⌊ x ⌋ < x$。由 $f$ 和下取整函数的单调性可知，$⌊ f (x) ⌋ gt.eq ⌊ f (⌊ x ⌋) ⌋$。如果等号不成立，那么设 $y = ⌊ f (x) ⌋$，它满足 $⌊ f (⌊ x ⌋) ⌋ < y lt.eq ⌊ f (x) ⌋$，这等价于 $f (⌊ x ⌋) < y lt.eq f (x)$。由 $f$ 的连续性可知，存在 $⌊ x ⌋ < x_0 lt.eq x$ 使得 $f (x_0) = y$。因为 $y in bold(Z)$，所以 $x_0 in bold(Z)$，这与 $⌊ x ⌋$ 的定义矛盾。故而，等号成立，即 $⌊ f (x) ⌋ = ⌊ f (⌊ x ⌋) ⌋$。

最后是一组关于带有取整函数的求和式的结论：（$x in bold(R) , med n in bold(Z) , med m in bold(Z)_(+)$）

- $n = ⌊n / 2⌋ + ⌈n / 2⌉$。
- $n = ⌊n / m⌋ + ⌊frac(n + 1, m)⌋ + dots.h.c + ⌊frac(n + m - 1, m)⌋$。
- $n = ⌈n / m⌉ + ⌈frac(n - 1, m)⌉ + dots.h.c + ⌈frac(n - m + 1, m)⌉$。
- $⌊ m x ⌋ = ⌊ x ⌋ + ⌊x + 1 / m⌋ + dots.h.c + ⌊x + frac(m - 1, m)⌋$。
- $⌈ m x ⌉ = ⌈ x ⌉ + ⌈x - 1 / m⌉ + dots.h.c + ⌈x - frac(m - 1, m)⌉$。
- 当 $m tack.t n$ 时，$sum_(k = 1)^(m - 1) ⌊frac(k n, m)⌋ = 1 / 2 (n - 1) (m - 1)$。
- 当 $m tack.t n$ 时，$sum_(k = 1)^(m - 1) ⌈frac(k n, m)⌉ = 1 / 2 (n + 1) (m - 1)$。

== 常见数列
<常见数列>
赛场用的量级与近似，不是证明。调和级数估枚举倍数的时间；素数密度估筛到多少；高度合成数估因数个数上界。

=== 调和级数
<调和级数>
枚举 $1 dots.c N$ 的倍数（调和级数复杂度）：$sum_(k = 1)^N N / k approx N "ln" N$，误差量级在 $10 %$ 左右。常规评测机可以在 500ms 内完成 $10^8$ 量级的此类预处理计算。下表 N 的量级指 $10$ 的幂次数。

#figure(
align(center)[#table(
  columns: 10,
  align: (col, row) => (center,center,center,center,center,center,center,center,center,center,).at(col),
  inset: 6pt,
  [N 的量级], [1], [2], [3], [4], [5], [6], [7], [8], [9],
  [累加和],
  [27],
  [482],
  [7’069],
  [93‘668],
  [1’166‘750],
  [13‘970’034],
  [162‘725’364],
  [1‘857’511‘568],
  [20’877‘697’634],
)]
)

下方示例为求解 $1$ 到 $N$ 中各个数字的因数值。

#include-code("code/数论/调和级数.cpp")

=== 素数密度与分布
<素数密度与分布>
#figure(
align(center)[#table(
  columns: 10,
  align: (col, row) => (center,center,center,center,center,center,center,center,center,center,).at(col),
  inset: 6pt,
  [N 的量级], [1], [2], [3], [4], [5], [6], [7], [8], [9],
  [素数数量],
  [4],
  [25],
  [168],
  [1‘229],
  [9’592],
  [78‘498],
  [664’579],
  [5‘761’455],
  [50‘847’534],
)]
)

除此之外，对于任意两个相邻的素数 $p_1 , p_2 lt.eq 10^9$ ，有 $lr(|p_1 - p_2|) < 300$ 成立，更具体的说，最大的差值为 $282$ 。

=== 因数最多数字与其因数数量
<因数最多数字与其因数数量>
#figure(
align(center)[#table(
  columns: 8,
  align: (col, row) => (center,center,center,center,center,center,center,center,).at(col),
  inset: 6pt,
  [N 的量级], [1], [2], [3], [4], [5], [6], [7],
  [因数最多数字的因数数量],
  [4],
  [25],
  [32],
  [64],
  [128],
  [240],
  [448],
  [因数最多的数字],
  [-],
  [-],
  [-],
  [7560, 9240],
  [83160, 98280],
  [720720, 831600, 942480, 982800, 997920],
  [-],
)]
)

== 欧拉筛 \(线性筛)
<欧拉筛-线性筛>
#specline([#O($N$)（埃氏筛为 #O($N "log" "log" N$)，此处原写有误）])
每个合数只被它的#strong[最小质因子];筛掉一次。下面的写法同时把最小质因子记录在 `v`/`minp` 中，可用于分解质因数。

#include-code("code/数论/欧拉筛-线性筛.cpp")

=== 最小质因数
<最小质因数>
线性筛的副产品：`minp[x]` 为 $x$ 的最小质因子。分解 $x$ 只需反复除 `minp[x]`，单次 $cal(O)("log" x)$。先 `sieve(n)`。

#include-code("code/数论/最小质因数.cpp")

== 防爆模乘
<防爆模乘>
$10^18$ 量级的 `a * b % m` 直接乘会溢出，用二分拆开或 128 位中转。#strong[首选 int128 版];（简单、可移植）；浮点版不依赖 `__int128` 且常数小，但依赖平台 `long double` 的精度：x86 上 `long double` 为 80 位，`mul` 对 $< 10^18$ 正确。

#pitfall[ARM / MSVC 上 `long double` 退化为 64 位 double，浮点版#strong[会出错];——只能用 int128 版。]

=== 借助浮点数实现
<借助浮点数实现>
$cal(O)(1)$ 计算 $a dot b mod m$，常数比 int128 法小很多。其中 $1 lt.eq a , b , m lt.eq 10^18$。

```cpp
LL mul(LL a, LL b, LL m) {
    LL r = a * b - m * (LL)(1.L / m * a * b);
    return r - m * (r >= m) + m * (r < 0);
}
```

=== 借助 int128 实现
<借助-int128-实现>
`(__int128)a * b % m`，语义就是普通模乘。Linux / gcc 有 `__int128`，MSVC 没有。优先用这个。

```cpp
LL mul(LL a, LL b, LL m) {
    return (LL)((__int128)a * b % m);
}
```

== 威尔逊定理
<威尔逊定理>
+ 当且仅当 p 为素数时，$(p - 1) ! equiv - 1 (mod med p)$
+ 当且仅当 p 为素数时，$(p - 1) ! equiv p - 1 (mod med p)$
+ 若 p 为质数，则 p 能被$(p - 1) ! + 1$整除
+ 当且仅当 p 为素数时，$p divides (p - 1) ! + 1$

== 裴蜀定理
<裴蜀定理>
#quote(block: true)[
$a x + b y = c med (x in Z^* , y in Z^*)$ 成立的充要条件是 $"gcd"(a , b) divides c$（ $Z^(\*)$ 表示正整数集）。
]

=== 逆定理
<逆定理>
设 $a , b$ 是不全为零的整数，若 $d > 0$ 是 $a , b$ 的公因数，且存在整数 $x , y$, 使得 $a x + b y = d$，则 $d = "gcd" (a , b)$。

特殊地，设 $a , b$ 是不全为零的整数，若存在整数 $x , y$, 使得 $a x + b y = 1$，则 $a , b$ 互质。

=== 多个整数
<多个整数>
裴蜀定理可以推广到 $n$ 个整数的情形：设 $a_1 , a_2 , dots.h , a_n$ 是不全为零的整数，则存在整数 $x_1 , x_2 , dots.h , x_n$, 使得 $a_1 x_1 + a_2 x_2 + dots.h.c + a_n x_n = "gcd" (a_1 , a_2 , dots.h , a_n)$。其逆定理也成立：设 $a_1 , a_2 , dots.h , a_n$ 是不全为零的整数，$d > 0$ 是 $a_1 , a_2 , dots.h , a_n$ 的公因数，若存在整数 $x_1 , x_2 , dots.h , x_n$, 使得 $a_1 x_1 + a_2 x_2 + dots.h.c + a_n x_n = d$，则 $d = "gcd" (a_1 , a_2 , dots.h , a_n)$。

例题：给定一个序列 $a$，找到整数序列 $x$，使得 $sum_(i = 1)^n a_i x_i$ 为最小的#strong[正数];。答案就是 $"gcd" (a_1 , dots.h , a_n)$（裴蜀定理可加出的最小正值）。

#include-code("code/数论/多个整数.cpp")

== 逆元
<逆元>
#specline([费马 #O($"log"$) 模质数], [exgcd #O($"log"$) 模数任意], [线性递推 #O($N$) 求全体])
满足 $a x equiv 1 (mod m)$ 的 $x$，用来把除法变乘法。存在当且仅当 $"gcd" (a , m) = 1$。模质数用费马 $a^(p - 2)$；一般模用 exgcd；要 $1 dots.c n$ 全部逆元用线性递推。

=== 费马小定理解（借助快速幂）
<费马小定理解借助快速幂>
若 $p$ 为素数，$"gcd" (a , p) = 1$，则 $a^(p - 1) equiv 1 (mod p)$。

另一个形式：对于任意整数 $a$，有 $a^p equiv a (mod p)$。

单次计算的复杂度即为快速幂的复杂度 $cal(O)("log" X)$ 。限制：$"MOD"$ 必须是质数，且需要满足 $x$ 与 $"MOD"$ 互质。

```cpp
LL inv(LL x) { return mypow(x, mod - 2, mod);}
```

=== 扩展欧几里得解
<扩展欧几里得解>
此方法的 $"MOD"$ 没有限制，复杂度为 $cal(O)("log" X)$ ，但是比快速幂法常数大一些。

```cpp
int x, y;
int exgcd(int a, int b, int &x, int &y) {  //扩展欧几里得算法
    if (b == 0) {
        x = 1, y = 0;
        return a; //到达递归边界开始向上一层返回
    }
    int r = exgcd(b, a % b, x, y);
    int temp = y; //把x y变成上一层的
    y = x - (a / b) * y;
    x = temp;
    return r;  //得到a b的最大公因数
}
LL getInv(int a, int mod) {  //求a在mod下的逆元，不存在逆元返回-1
    LL x, y, d = exgcd(a, mod, x, y);
    return d == 1 ? (x % mod + mod) % mod : -1;
}
```

=== 离线求解：线性递推解
<离线求解线性递推解>
以 $cal(O)(N)$ 的复杂度完成 $1 - N$ 中全部逆元的计算。#strong[仅当 $p$ 为素数时成立。];由 $p = ⌊ p \/ i ⌋ dot i + (p mod i) equiv 0 (mod p)$ 解出 $"inv" [i] = - ⌊ p \/ i ⌋ dot "inv" [p mod i]$，代码里的 $p - p \/ i$ 是保持非负的等价写法。

```cpp
inv[1] = 1;
for (int i = 2; i <= n; i ++ )
    inv[i] = (p - p / i) * inv[p % i] % p;
```

== 扩展欧几里得 exgcd
<扩展欧几里得-exgcd>
#specline([#O($"log" max(a, b)$)])
与欧几里得同一递归，回溯时 $x prime = y , y prime = x - (a \/ b) y$ 还原系数。返回 $"gcd"$；$a x + b y = c$ 有解当且仅当 $"gcd" divides c$，通解 $x plus.minus b \/ d$、$y minus.plus a \/ d$。

#include-code("code/数论/扩展欧几里得-exgcd.cpp")

例题：求解二元一次不定方程 $A dot x + B dot y = C$ 的正整数解个数。

#include-code("code/数论/扩展欧几里得-exgcd-2.cpp")

== 类欧几里得
<类欧几里得>
#specline([#O($"log" "max" (a , c)$)])
计算 $sum_(i = 0)^n ⌊frac(a i + b, c)⌋$（可扩展求 $sum i^k ⌊ dot ⌋$ 的若干变体）。

$ e u c l i d e a n (a , b , c , n) = sum_(i = 0)^n ⌊frac(a i + b, c)⌋ $

#include-code("code/数论/类欧几里得.cpp")

== 离散对数 bsgs 与 exbsgs
<离散对数-bsgs-与-exbsgs>
#specline([#O($sqrt(P)$)])
求解 $a^x equiv b (mod P)$。

#pitfall[标准 BSGS 要求 $a$ 与模数#strong[互质];（原文漏"不"字写反了）；$a$ 与 $"MOD"$ 不互质时须用 exbsgs。]

#include-code("code/数论/离散对数-bsgs-与-exbsgs.cpp")

== 欧拉函数
<欧拉函数>
$phi (n)$：$1 dots.c n$ 中与 $n$ 互质的个数。$n = product p_i^(k_i)$ 则 $phi (n) = n product (1 - 1 \/ p_i)$。欧拉定理：$a^(phi (n)) equiv 1 (mod n)$（$"gcd" (a , n) = 1$），用来降幂。

=== 直接求解单个数的欧拉函数
<直接求解单个数的欧拉函数>
分解质因数后套公式，$cal(O)(sqrt(n))$。

#include-code("code/数论/直接求解单个数的欧拉函数.cpp")

=== 求解 1 到 N 所有数的欧拉函数
<求解-1-到-n-所有数的欧拉函数>
利用上述性质，我们可以快速递推出 $2 - N$ 中每个数的欧拉函数，复杂度 $cal(O)(N)$ ，而该算法#strong[即是线性筛的算法];。

$ phi (n) = (1 - 1 \/ p_1) (1 - 1 \/ p_2) (1 - 1 \/ p_3) (1 - 1 \/ p_4) dots.h.c (1 - 1 \/ p_n) ; $

```cpp
const int N = 1e5 + 7;
int v[N], prime[N], phi[N];
void euler(int n) {
    ms(v, 0);  //最小质因子
    int m = 0;  //质数数量
    for (int i = 2; i <= n; ++ i) {
        if (v[i] == 0) {  // i 是质数
            v[i] = i, prime[++ m] = i;
            phi[i] = i - 1;
        }
         //为当前的数 i 乘上一个质因子
        for (int j = 1; j <= m; ++ j) {
             //如 i 有比 prime[j] 更小的质因子，或超出 n ，停止
            if(prime[j] > v[i] || prime[j] > n / i) break;
             // prime[j] 是合数 i * prime[j] 的最小质因子
            v[i * prime[j]] = prime[j];
            phi[i * prime[j]] = phi[i] * (i % prime[j] ? prime[j] - 1 : prime[j]);
        }
    }
}
int main() {
    int n; cin >> n; euler(n);
    for (int i = 1; i <= n; ++ i) cout << phi[i] << endl;
    return 0;
}
```

```cpp
std::vector<int> pri, not_prime, phi;

void init(int n) {
    not_prime.assign(n + 1, 0);
    phi.assign(n + 1, 0);
    phi[1] = 1;
    for (int i = 2; i <= n; i++) {
        if (!not_prime[i]) {
            pri.push_back(i);
            phi[i] = i - 1;
        }
        for (int pri_j : pri) {
            if (i * pri_j > n) break;
            not_prime[i * pri_j] = true;
            if (i % pri_j == 0) {
                phi[i * pri_j] = phi[i] * pri_j;
                break;
            }
            phi[i * pri_j] = phi[i] * phi[pri_j];
        }
    }
}
```

=== 使用莫比乌斯反演求解欧拉函数
<使用莫比乌斯反演求解欧拉函数>
由恒等式 $sum_(d divides n) phi (d) = n$ 对 $n$ 容斥递推：$phi (n) = n - sum_(d divides n , d < n) phi (d)$。先用倍数法预处理每个数的约数，再 $O (N "log" N)$ 递推。

```cpp
int phi[N];
vector<int> fac[N];
void get_eulers() {
    for (int i = 1; i <= N - 10; i++) {
        for (int j = i; j <= N - 10; j += i) {
            fac[j].push_back(i);
        }
    }
    phi[1] = 1;
    for (int i = 2; i <= N - 10; i++) {
        phi[i] = i;
        for (auto j : fac[i]) {
            if (j == i) continue;
            phi[i] -= phi[j];
        }
    }
}
```

== 扩展欧拉定理
<扩展欧拉定理>
若正整数 $a$ 与 $m$ 互质，则

$ a^(phi (m)) equiv 1 (mod thin m) $

推论：

$ a^b equiv a^(b thin mod thin phi (m)) (mod thin m) $

当 $a , m$ 不互质时，扩展 Euler 定理表述如下：

$ a^b equiv a^(b thin mod thin phi (m) + phi (m)) (mod thin m) $

式子仅在 $phi (m) lt.eq b$ 时成立。

下面板子解决“指数 $b$ 以字符串给出（大到无法读入整数）”的场景：`read(MOD)` 边读边对 `MOD=φ(m)` 取模，同时用 `large_enough` 记录 $b gt.eq phi (m)$ 是否成立；最后按上式计算 $a^(b + phi (m)) mod m$。

```cpp
#include <bits/stdc++.h>
using namespace std;
bool large_enough = false;  // 判断是否有 b >= phi(m)
inline int read(int MOD = 1e9 + 7)  // 快速读入稍加修改即可以边读入边取模；不用扩展欧拉定理时直接模一个大数即可
{
    int ans = 0;
    char c = getchar();
    while (!isdigit(c))
        c = getchar();
    while (isdigit(c))
    {
        ans = ans * 10 + c - '0';
        if (ans >= MOD)
        {
            ans %= MOD;
            large_enough = true;
        }
        c = getchar();
    }
    return ans;
}
int phi(int n)  // 求欧拉函数
{
    int res = n;
    for (int i = 2; i * i <= n; i++)
    {
        if (n % i == 0)
            res = res / i * (i - 1);
        while (n % i == 0)
            n /= i;
    }
    if (n > 1)
        res = res / n * (n - 1);
    return res;
}
int qpow(int a, int n, int MOD)  // 快速幂
{
    int ans = 1;
    while (n)
    {
        if (n & 1)
            ans = 1LL * ans * a % MOD;  // 注意防止溢出
        n >>= 1;
        a = 1LL * a * a % MOD;
    }
    return ans;
}
int main()
{
    int a = read(), m = read(), phiM = phi(m), b = read(phiM);
    cout << qpow(a, b + (large_enough ? phiM : 0), m);
    return 0;
}
```

== 求解连续数字的正约数集合——倍数法
<求解连续数字的正约数集合倍数法>
使用规律递推优化，时间复杂度为 $cal(O)(N "log" N)$ ，如果不需要详细的输出集合，则直接将 `vector` 换为普通数组即可（时间更快） 。

#include-code("code/数论/求解连续数字的正约数集合——倍数法.cpp")

== 试除法判是否是质数
<试除法判是否是质数>
试到 $sqrt(n)$ 即可：有因数则必有一个 $lt.eq sqrt(n)$。$n < 2$ 不是质数。大批量改用筛。

=== 标准解
<标准解>
$cal(O)(sqrt(N))$。循环写 `i <= n / i` 防溢出。

#include-code("code/数论/标准解.cpp")

=== 常数优化法
<常数优化法>
常数优化，达到 $cal(O)(sqrt(N) / 3)$ 。

```cpp
bool is_prime(int n) {
    if (n < 2) return false;
    if (n == 2 || n == 3) return true;
    if (n % 6 != 1 && n % 6 != 5) return false;
    for (int i = 5, j = n / i; i <= j; i += 6) {
        if (n % i == 0 || n % (i + 2) == 0) {
            return false;
        }
    }
    return true;
}
```

== 同余方程组、拓展中国剩余定理 excrt
<同余方程组拓展中国剩余定理-excrt>
求解方程组 $x equiv a_i (mod b_i)$（代码变量：余数存 `ai[]`、模数存 `bi[]`，与洛谷 P4777 的读入命名相反，注意别抄混）。#strong[模数不要求两两互质];（互质时退化为普通 CRT）。做法是逐对合并：把已合并的方程 $x equiv "ans" (mod M)$ 与新方程 $x equiv a_i (mod b_i)$ 消元成 $M dot k equiv a_i - "ans" (mod b_i)$，用 exgcd 解出 $k$。复杂度 $cal(O)(n "log")$。

```cpp
int n; LL ai[maxn], bi[maxn];
inline int mypow(int n, int k, int p) {
    int r = 1;
    for (; k; k >>= 1, n = n * n % p)
        if (k & 1) r = r * n % p;
    return r;
}
LL exgcd(LL a, LL b, LL &x, LL &y) {
    if (b == 0) { x = 1, y = 0; return a; }
    LL gcd = exgcd(b, a % b, x, y), tp = x;
    x = y, y = tp - a / b * y;
    return gcd;
}
LL excrt() {
    // 方程形式为 x ≡ ai[i] (mod bi[i])，模数不要求互质；互质时就是 CRT 的特例
    LL x, y, k;
    LL M = bi[1], ans = ai[1];  // 当前合并后的模数与余数
    for (int i = 2; i <= n; ++ i) {
        LL a = M, b = bi[i], c = (ai[i] - ans % b + b) % b;  // 变成 exgcd 可解形式 ax ≡ c (mod b)
        LL gcd = exgcd(a, b, x, y), bg = b / gcd;
        if (c % gcd != 0) return -1;  // 无解判定
        x = mul(x, c / gcd, bg);
        ans += x * M;
        M *= bg;
        ans = (ans % M + M) % M;
    }
    return (ans % M + M) % M;
}
int main() {
    cin >> n;
    for (int i = 1; i <= n; ++ i) cin >> bi[i] >> ai[i];
    cout << excrt() << endl;
    return 0;
}
```

== 求解连续按位异或
<求解连续按位异或>
两段等价：$0 xor 1 xor dots.h xor n$ 按 $n mod 4$ 分类取 $n , 1 , n + 1 , 0$。复杂度 $cal(O)(1)$。第一版用位运算技巧，第二版直观。

```cpp
unsigned xor_n(unsigned n) {
    unsigned t = n & 3;
    if (t & 1) return t / 2u ^ 1;
    return t / 2u ^ n;
}
```

#include-code("code/数论/求解连续按位异或.cpp")

== 高斯消元求解线性方程组
<高斯消元求解线性方程组>
解 $N$ 元一次方程组（实数系数的板子；模意义下把除法换成逆元即可）。列主元选绝对值最大行防止除小数放大误差，复杂度 $cal(O)(N^3)$。返回值：$0$ \= 唯一解（解存在 `a[i][n]`），$1$ \= 无穷多解，$2$ \= 无解。

#include-code("code/数论/高斯消元求解线性方程组.cpp")

== Min25 筛
<min25-筛>
#specline([#O($N^(3 \/ 4) \/ "log" N$)，实测 $10^10$ 很快])
求 $1 dots.c N$ 的质数和（$N lt.eq 10^10$），板子对结果按 `mod` 取模。`id1/id2` 是两个 $cal(O)(sqrt(N))$ 数组，把 $⌊ N \/ x ⌋$ 的取值线形编号。`init` 在筛质数后对数论分块的值做 $cal(O)(frac(N^(3 \/ 4), "log" N))$ 的质数贡献筛，`solve` 返回 $2 dots.c N$ 质数和。求一般的积性函数前缀和需按题目改写 `calc` 与转移，具体参 oi-wiki 的 Min\_25 筛一节。

```cpp
namespace min25{
    const int N = 1000000 + 10;
    int prime[N], id1[N], id2[N], flag[N], ncnt, m;
    LL g[N], sum[N], a[N], T;
    LL n;
    LL mod;
    inline LL ps(LL n,LL k) {LL r=1;for(;k;k>>=1){if(k&1)r=r*n%mod;n=n*n%mod;}return r;}
    void finit(){  // 最开始清0
        memset(g, 0, sizeof(g));
        memset(a, 0, sizeof(a));
        memset(sum, 0, sizeof(sum));
        memset(prime, 0, sizeof(prime));
        memset(id1, 0, sizeof(id1));
        memset(id2, 0, sizeof(id2));
        memset(flag, 0, sizeof(flag));
        ncnt = m = 0;
    }
    int ID(LL x) {
        return x <= T ? id1[x] : id2[n / x];
    }

    LL calc(LL x) {
        return x * (x + 1) / 2 - 1;
    }

    LL init(LL x) {
        T = sqrt(x + 0.5);
        for (int i = 2; i <= T; i++) {
            if (!flag[i]) prime[++ncnt] = i, sum[ncnt] = sum[ncnt - 1] + i;
            for (int j = 1; j <= ncnt && i * prime[j] <= T; j++) {
                flag[i * prime[j]] = 1;
                if (i % prime[j] == 0) break;
            }
        }
        for (LL l = 1; l <= x; l = x / (x / l) + 1) {
            a[++m] = x / l;
            if (a[m] <= T) id1[a[m]] = m; else id2[x / a[m]] = m;
            g[m] = calc(a[m]);
        }
        for (int i = 1; i <= ncnt; i++)
            for (int j = 1; j <= m && (LL) prime[i] * prime[i] <= a[j]; j++)
                g[j] = g[j] - (LL) prime[i] * (g[ID(a[j] / prime[i])] - sum[i - 1]);
    }
    LL solve(LL x) {
        if (x <= 1) return x;
        return n = x, init(n), g[ID(n)];
    }
}

using namespace min25;

int main() {
    // while (1) {
    int tt;
    scanf("%d",&tt);
    while(tt--){
        finit();
        scanf("%lld%lld", &n, &mod);
        LL ans = (n + 3) % mod * n % mod  * ps(2 , mod - 2) % mod + solve(n + 1) - 4;
        // cout << solve(n) << endl;
        // ans = (ans + mod) % mod;
        ans = (ans + mod) % mod;
        printf("%lld\n", ans);
    }

    // }
}
```

== 矩阵四则运算
<矩阵四则运算>
#link("https://ac.nowcoder.com/acm/contest/view-submission?submissionId=48594258")[封装来自] 。矩阵乘法复杂度 $cal(O)(N^3)$ 。#strong[`SIZE` 按题目改];；`getinv` 用高斯-约当法在素模数下求逆（依赖 `mod` 为素数），失败时置全局 `ok = 0`。

#include-code("code/数论/矩阵四则运算.cpp")

== 矩阵快速幂
<矩阵快速幂>
把转移写成矩阵乘法，指数倍增。`MatPow(A,b)` 得 $A^b$；`N` 为阶、`mod` 按题改，下标从 $1$。复杂度 $cal(O)(N^3 "log" M)$。线性递推见下一节矩阵加速。

#include-code("code/数论/矩阵快速幂.cpp")

== 矩阵加速
<矩阵加速>
矩阵快速幂优化线性递推的示例：递推式 $f (n) = f (n - 1) + f (n - 3)$（初值 $f (1) = f (2) = f (3) = 1$）。转移矩阵为

$ mat(1, 0, 1; 1, 0, 0; 0, 1, 0) , #h(2em) vec(f (n), f (n - 1), f (n - 2)) = mat(1, 0, 1; 1, 0, 0; 0, 1, 0)^(n - 3) vec(1, 1, 1) $

复杂度 $cal(O)(k^3 "log" n)$，$k$ 为状态数（此处 3）。

#include-code("code/数论/矩阵加速.cpp")

== 莫比乌斯函数/反演
<莫比乌斯函数反演>
莫比乌斯函数定义：$mu (n) = cases(1 & n = 1, (- 1)^k & n upright(" 为 ") k upright(" 个互异素数之积"), 0 & upright("else"))$ 。（原文“$p_i$ 互质”意为 $p_i$ 两两不同）

#quote(block: true)[
莫比乌斯函数性质：对于任意正整数 $n$ 满足 $sum_(d \| n) mu (d) = cases(1 & n = 1, 0 & n eq.not 1)$ ；$sum_(d \| n) frac(mu (d), d) = frac(phi (n), n)$ 。
]

莫比乌斯反演定义：$F (n)$ 和 $f (n)$ 是定义在非负整数集合上的两个函数，并且满足 $F (n) = sum_(d \| n) f (d)$ ，可得 $f (n) = sum_(d \| n) mu (d) F (⌊n / d⌋)$ 。用于“已知 $F$ 求 $f$”的莫反类题；也可以理解为 $F = f \* 1 arrow.l.r.double f = F \* mu$。

```cpp
const int N = 5e4 + 10;  // 按题目改
bool st[N];
int mu[N], prime[N], cnt, sum[N];
void getMu() {  // 线性筛 mu，再前缀和，O(N)
    mu[1] = 1;
    for (int i = 2; i <= N - 10; i++) {
        if (!st[i]) {
            prime[++cnt] = i;
            mu[i] = -1;
        }
        for (int j = 1; j <= cnt && i * prime[j] <= N - 10; j++) {
            st[i * prime[j]] = true;
            if (i % prime[j] == 0) {
                mu[i * prime[j]] = 0;
                break;
            }
            mu[i * prime[j]] = -mu[i];
        }
    }
    for (int i = 1; i <= N - 10; i++) {
        sum[i] = sum[i - 1] + mu[i];
    }
}
void solve() {
    int n, m, k; cin >> n >> m >> k;
    n = n / k, m = m / k;
    if (n < m) swap(n, m);
    LL ans = 0;
    for (int i = 1, j = 0; i <= m; i = j + 1) {
        j = min(n / (n / i), m / (m / i));
        ans += (LL)(sum[j] - sum[i - 1]) * (n / i) * (m / i);
    }
    cout << ans << "\n";
}
int main() {
    getMu();
    int T; cin >> T;
    while (T--) solve();
}
```

== 整除 \(数论) 分块
<整除-数论-分块>
把 $⌊ n \/ i ⌋$ 相同的 $i$ 并为一块：$j = ⌊ n \/ ⌊ n \/ i ⌋ ⌋$ 是右端点，块内个数 $j - i + 1$，块数 $cal(O)(sqrt(n))$。莫反、杜教筛、前缀和题里”枚举 $⌊ n \/ i ⌋$“都用它。

$⌊n / l⌋ = ⌊frac(n, l + 1)⌋ = dots.c = ⌊n / r⌋ arrow.l.r.double ⌊n / l⌋ lt.eq n / r < ⌊n / l⌋ + 1$ ，根据不等式左侧，得到 $r lt.eq ⌊frac(n, ⌊ n / l ⌋)⌋$ 。

#include-code("code/数论/整除-数论-分块.cpp")

== Miller - Rabin 素数测试
<miller---rabin-素数测试>
#specline([平均 #O($"log"^3 X$)（常数极小，可视作 #O($1$)）])
#strong[确定性结论];：底数表 `B = {2,3,5,7,11,13,17,19,23}` 对 $< 3.8 times 10^18$ 的数判定#strong[完全确定无误];；如果题目给到 long long 全域（上限 $9.2 times 10^18$），把底表扩到前 12 个素数 $2 dots.c 37$ 即确定覆盖。

#include-code("code/数论/Miller---Rabin-素数测试.cpp")

== Pollard - Rho 因式分解
<pollard---rho-因式分解>
以单个因子 $cal(O)("log" X)$ 的复杂度输出数字 $X$ 的全部质因数，由于需要结合素数测试，总复杂度会略高一些。如果遇到超时的情况，可能需要考虑进一步优化，例如检查题目是否强制要求枚举全部质因数等等。此外，还有一个#link("https://www.luogu.com.cn/record/114757731")[较长的模板];可供参考，比这里记录的版本常数小约五倍。

#include-code("code/数论/Pollard---Rho-因式分解.cpp")

== 常见结论和定理
<常见结论和定理>
构造与存在性的速查，不是算法。用前确认条件（互质、奇偶、上下界）。

=== 麦乐鸡定理
<麦乐鸡定理>
给定两个互质的数 $n , m$ ，定义 $x = a \* n + b \* m （ a gt.eq 0 , b gt.eq 0 ）$，当 $x > n \* m - n - m$ 时，该式子恒成立。

=== 抽屉原理（鸽巢原理）
<抽屉原理鸽巢原理>
将 $n + 1$ 个物体，划分为 $n$ 组，那么有至少一组有两个（或以上）的物体。

=== 哥德巴赫猜想
<哥德巴赫猜想>
任何一个大于 $5$ 的整数都可写成三个质数之和；任何一个大于 $2$ 的偶数都可写成两个素数之和。

=== 除法、取模运算的本质
<除法取模运算的本质>
有公式：$x div i = ⌊x / i⌋ + x - i dot ⌊x / i⌋$ ，$x mod med i = x - i dot ⌊x / i⌋$ 。

=== 与、或、异或
<与或异或>
#figure(
align(center)[#table(
  columns: 3,
  align: (col, row) => (center,center,center,).at(col),
  inset: 6pt,
  [运算], [运算符、数学符号表示], [解释],
  [与],
  [`&`、`and`],
  [同 1 出 1],
  [或],
  [`\|`、`or`],
  [有 1 出 1],
  [异或],
  [`^`、$xor.big$、`xor`],
  [不同出 1],
)]
)

一些结论：

#quote(block: true)[
对于给定的 $X$ 和序列 $[a_1 , a_2 , dots.h , a_n]$ ，有：$bold(X = (X & a_1) o r (X & a_2) o r dots.h o r (X & a_n))$ 。 原理是 $a n d$ 意味着取交集，$o r$ 意味着取子集。#link("https://ac.nowcoder.com/acm/contest/11226/C")[来源 - 牛客小白月赛 49C]
]

=== 调和级数近似公式
<调和级数近似公式>
$H_n approx "ln" n + gamma + 1 \/ (2 n)$，$gamma approx 0.5772156649$。估 $sum ⌊ n \/ i ⌋$ 的量级。

```cpp
log(n) + 0.5772156649 + 1.0 / (2 * n)
```

=== 欧拉函数常见性质
<欧拉函数常见性质>
- $1 - n$ 中与 $n$ 互质的数之和为 $n \* phi (n) \/ 2$ 。

- 若 $a ， b$ 互质，则 $phi (a \* b) = phi (a) \* phi (b)$ 。实际上，所有满足这一条件的函数统称为积性函数。

- 若 $f$ 是积性函数，且有 $n = product_(i = 1)^m p_i^(c_i)$ ，那么 $f (n) = product_(i = 1)^m f (p_i^(c_i))$ 。

- 若 $p$ 为质数，且满足 $p divides n$ ，

  - $p^2 divides n$ ，那么 $phi (n) = phi (n \/ p) \* p$ 。
  - $p^2 divides.not n$，那么 $phi (n) = phi (n \/ p) \* (p - 1)$ 。

- $sum_(d divides n) phi (d) = n$ 。

  #quote(block: true)[
  如 $n = 10$ ，则 $d = 10 \/ 5 \/ 2 \/ 1$ ，那么 $10 = phi (10) + phi (5) + phi (2) + phi (1)$ 。
  ]

- $sum_(i = 1)^n "gcd" (i , n) = sum_(d \| n) ⌊n / d⌋ phi (d)$ （欧拉反演）。

=== 狄利克雷卷积
<狄利克雷卷积>
$sum_(d \| n) phi (d) = n$ ，$sum_(d \| n) mu (d) n / d = phi (n)$ 。

=== 斐波那契数列
<斐波那契数列>
通项公式：$F_n = 1 / sqrt(5) \* #scale(x: 180%, y: 180%)[\[] #scale(x: 180%, y: 180%)[\(] frac(1 + sqrt(5), 2) #scale(x: 180%, y: 180%)[\)]^n - #scale(x: 180%, y: 180%)[\(] frac(1 - sqrt(5), 2) #scale(x: 180%, y: 180%)[\)]^n #scale(x: 180%, y: 180%)[\]]$ 。

直接结论：

- 卡西尼性质：$F_(n - 1) \* F_(n + 1) - F_n^2 = (- 1)^n$ ；
- $F_n^2 + F_(n + 1)^2 = F_(2 n + 1)$ ；
- $F_(n + 1)^2 - F_(n - 1)^2 = F_(2 n)$ （由上一条写两遍相减得到）；
- 若存在序列 $a_0 = 1 , a_n = a_(n - 1) + a_(n - 3) + a_(n - 5) + dots.c (n gt.eq 1)$ 则 $a_n = F_n (n gt.eq 1)$ ；
- 齐肯多夫定理：任何正整数都可以表示成若干个不连续的斐波那契数（ $F_2$ 开始）可以用贪心实现。

求和公式结论：

- 奇数项求和：$F_1 + F_3 + F_5 + dots.c + F_(2 n - 1) = F_(2 n)$ ；
- 偶数项求和：$F_2 + F_4 + F_6 + dots.c + F_(2 n) = F_(2 n + 1) - 1$ ；
- 平方和：$F_1^2 + F_2^2 + F_3^2 + dots.c + F_n^2 = F_n \* F_(n + 1)$ ；
- $F_1 + 2 F_2 + 3 F_3 + dots.c + n F_n = n F_(n + 2) - F_(n + 3) + 2$ ；
- $- F_1 + F_2 - F_3 + dots.c + (- 1)^n F_n = (- 1)^n (F_(n + 1) - F_n) + 1$ ；
- $F_(2 n - 2 m - 2) (F_(2 n) + F_(2 n + 2)) = F_(2 m + 2) + F_(4 n - 2 m)$ 。

数论结论：

- $F_a divides F_b arrow.l.r.double a divides b$ ；
- $"gcd" (F_a , F_b) = F_("gcd" (a , b))$ ；
- 当 $p$ 为 $5 k plus.minus 1$ 型素数时，${F_(p - 1) equiv 0 (mod p)\
  F_p equiv 1 (mod p)\
  F_(p + 1) equiv 1 (mod p)$ ；
- 当 $p$ 为 $5 k plus.minus 2$ 型素数时，${F_(p - 1) equiv 1 (mod p)\
  F_p equiv - 1 (mod p)\
  F_(p + 1) equiv 0 (mod p)$ ；
- $F (n) % m$ 的周期 $lt.eq 6 m$ （ $m = 2 times 5^k$ 时取到等号）；
- 既是斐波那契数又是平方数的有且仅有 $1 , 144$ 。

=== 杂
<杂>
- 负数取模得到的是负数，如果要用 $0 \/ 1$ 判断的话请取绝对值；

- 辗转相除法原式为 $"gcd" (x , y) = "gcd" (x , y - x)$ ，推广到 $N$ 项为 $"gcd" (a_1 , a_2 , dots.h , a_N) = "gcd" (a_1 , a_2 - a_1 , dots.h , a_N - a_(N - 1))$ ，

  - 该推论在“四则运算后 $"gcd"$ ”这类题中有特殊意义，如求解 $"gcd" (a_1 + X , a_2 + X , dots.h , a_N + X)$ 时#link("https://codeforces.com/problemset/problem/1458/A")[See];；

- 以下式子成立： $"gcd" (a , m) = "gcd" (a + x , m) arrow.l.r.double "gcd" (a , m) = "gcd" (x , m)$ 。求解上式满足条件的 $x$ 的数量即为求比 $frac(m, "gcd" (a , m))$ 小且与其互质的数的个数，即用欧拉函数求解 $phi #scale(x: 180%, y: 180%)[\(] frac(m, "gcd" (a , m)) #scale(x: 180%, y: 180%)[\)]$ 。

- 已知序列 $a$ ，定义集合 $S = { a_i dot a_j med \| med i < j }$ ，现在要求解 $"gcd" (S)$ ，即为求解 $"gcd" (a_j , "gcd" (a_i med \| med i < j))$ ，换句话说，即为求解后缀 $"gcd"$ 。

- 连续四个数互质的情况如下，当 $n$ 为奇数时，$n , n - 1 , n - 2$ 一定互质；而当 $n$ 为偶数时，${n , n - 1 , n - 3 upright("互质") & "gcd" (n , n - 3) = 1 upright("时")\
  n - 1 , n - 2 , n - 3 upright("互质") & "gcd" (n , n - 3) eq.not 1 upright("时")$ #link("https://codeforces.com/problemset/problem/235/A")[See];；

- 由 $a mod med b = (b + a) mod med b = (2 dot b + a) mod med b = dots.h = (K dot b + a) mod med b$ 可以推广得到 $(a mod med b) mod med c = ((K dot b c + a) mod med b) mod med c$ ，由此可以得到一个 $b c$ 的答案周期#link("https://codeforces.com/problemset/problem/1342/C")[See];；

- 对于长度为 $2 dot N$ 的数列 $a$ ，将其任意均分为两个长度为 $N$ 的数列 $p , q$ ，随后对 $p$ 非递减排序、对 $q$ 非递增排序，定义 $f (p , q) = sum_(i = 1)^n lr(|p_i - q_i|)$ ，那么答案为 $a$ 数列前 $N$ 大的数之和减去前 $N$ 小的数之和#link("https://codeforces.com/problemset/problem/1444/B")[See];。

- 令 ${X = a + b\
  Y = a xor b$ ，#strong[如果];该式子#strong[有解];，那么存在前提条件 ${X gt.eq Y\
  X , Y upright("同奇偶")$ ；进一步，此时最小的 $a$ 的取值为 $frac(X - Y, 2)$ #link("https://codeforces.com/problemset/problem/76/D")[See];。

  然而，上方方程并不总是有解的，只有当变量增加到三个时，才#strong[一定有解];，即：#strong[在保证上方前提条件成立的情况下];，求解 ${X = a + b + c\
  Y = a xor b xor c$ ，则一定存在一组解 ${ frac(X - Y, 2) , frac(X - Y, 2) , Y }$ #link("https://codeforces.com/problemset/problem/1325/D")[See];。

- 已知序列 $p$ 是由序列 $a_1$ 、序列 $a_2$ 、……、序列 $a_n$ 合并而成，且合并过程中各序列内元素相对顺序不变，记 $T (p)$ 是 $p$ 序列的最大前缀和，则 $T (p) = sum_(i = 1)^n T (a_i)$ #link("https://codeforces.com/problemset/problem/1469/B")[See] 。

- $x + y = x \| y + x & y$ ，对于两个数字 $x$ 和 $y$ ，如果将 $x$ 变为 $x \| y$ ，同时将 $y$ 变为 $x & y$ ，那么在本质上即将 $x$ 二进制模式下的全部 $1$ 移动到了 $y$ 的对应的位置上 #link("https://codeforces.com/contest/1368/problem/D")[See] 。

- 一个正整数 $x$ 异或、加上另一个正整数 $y$ 后奇偶性不发生变化：$a + b equiv a xor b (mod 2)$ #link("https://codeforces.com/contest/1634/problem/B")[See] 。

== 常见例题
<常见例题>
题意：将 $1$ 至 $N$ 的每个数字分组，使得每一组的数字之和均为质数。输出每一个数字所在的组别，且要求分出的组数最少 #link("https://codeforces.com/contest/45/problem/G")[See] 。

考察哥德巴赫猜想，记全部数字之和为 $S$ ，分类讨论如下：

- 为 $S$ 质数时，只需要分入同一组；
- 当 $S$ 为偶数时，由猜想可知一定能分成两个质数，可以证明其中较小的那个一定小于 $N$ ，暴力枚举分组；
- 当 $S - 2$ 为质数时，特殊判断出答案；
- 其余情况一定能被分成三组，其中 $3$ 单独成组，$S - 3$ 后成为偶数，重复讨论二的过程即可。

#line(length: 100%)

题意：给定一个长度为 $n$ 的数组，定义这个数组是 $B A D$ 的，当且仅当可以把数组分成两个子序列，这两个子序列的元素之和相等。现在你需要删除#strong[最少的];元素，使得删除后的数组不是 $B A D$ 的。

#strong[最少删除一个元素];——如果原数组存在奇数，则直接删除这个奇数即可；反之，我们发现，对数列同除以一个数不影响计算，故我们只需要找到最大的满足 $2^k divides a_i$ 成立的 $2^k$ ，随后将全部的 $a_i$ 变为 $a_i / 2^k$ ，此时一定有一个奇数（换句话说，我们可以对原数列的每一个元素不断的除以 $2$ 直到出现奇数为止），删除这个奇数即可 #link("https://codeforces.com/contest/1516/problem/C")[See] 。

#line(length: 100%)

题意：设当前有一个数字为 $x$ ，减去、加上最少的数字使得其能被 $k$ 整除。

最少减去 $x mod k$ 这个很好想；最少加上 $(⌈x / k⌉ \* k) mod k$ 也比较好想，但是更简便的方法为加上 $k - x mod k$ ，这个式子等价于前面这一坨。

#line(length: 100%)

题意：给定一个整数 $n$ ，用恰好 $k$ 个 $2$ 的幂次数之和表示它。例如：$n = 9 , k = 4$ ，答案为 $1 + 2 + 2 + 4$ 。

结论 1：$k$ 合法当且仅当 `__builtin_popcountll(n) <= k && k <= n` ，显然。

结论 2：$2^(k + 1) = 2 dot 2^k$ ，所以我们可以将二进制位看作是数组，然后从高位向低位推，一个高位等于两个低位，直到数组之和恰好等于 $k$ ，随后依次输出即可。举例说明，${ 1 , 0 , 0 , 1 } arrow.r { 0 , 2 , 0 , 1 } arrow.r { 0 , 1 , 2 , 1 }$ ，即答案为 $0$ 个 $2^3$ 、$1$ 个 $2^2$ 、……。

#include-code("code/数论/常见例题.cpp")

#line(length: 100%)

题意：$n$ 个取值在 $\[ 0 , k \)$ 之间的数之和为 $m$ 的方案数

答案为 $sum_(i = 0)^n - 1^i dot binom(n, i) dot binom(m - i dot k + n - 1, n - 1)$ #link("http://acm.hdu.edu.cn/showproblem.php?pid=6397")[See1] #link("https://codeforces.com/gym/103428/problem/M")[See2];。

```cpp
 Z clac(int n, int k, int m) {
    Z ans = 0;
    for(int i = 0; i <= n; ++i) {
        ans += C(n, i) * C(m - i * k + n - 1, n - 1) * pow(-1, i);
    }
    return ans;
}
```

① 先考虑没有 $k$ 的限制，那么即球盒模型：$m$ 个球放入 $n$ 个盒子，球同、盒子不同、能空。使用隔板法得到公式：`C(m + n - 1, n - 1)` ；② 下面加上取值范围后进一步考虑：假设现在 $n$ 个数之和为 $m - k$ ，运用上述隔板法可得公式：`C(m - k + n - 1, n - 1)` ；③ 随后，选择任意一个数字，将其加上 $k$ ，这样，这个数字一定不满足条件，选法为：`C(n, 1)` ；④ 此时，至少有一个数字是不满足条件的，按照一般流程，到这里，`C(m + n - 1, n - 1) - C(n, 1) * C(m - k + n - 1, n - 1)` 即是答案；但是，这样的操作会导致重复的部分，所以这里要使用容斥原理将重复部分去除（关于为什么会重复，试比较概率论中的加法公式）。

== 约瑟夫问题
<约瑟夫问题>
#specline([线性 #O($N$) 任意 $k$], [#O($K "log" N$) $K$ 小], [#O($sqrt(N)$) 单次大询问])
$n$ 个人编号 $0 , 1 , 2 dots.h , n - 1$ ，每次数到 $k$ 出局，求最后剩下的人的编号。`repeat(i,a,b)` 是 i 从 a 到 b-1 的宏，可等价写成 `for (int i = a; i < b; ++i)`。

```cpp
int jos(int n,int k){
    int res=0;
    repeat(i,1,n+1)res=(res+k)%i;
    return res;  // res+1，如果编号从1开始
}
```

$cal(O)(K "log" N)$ ，适用于 $K$ 较小的情况。

#include-code("code/数论/约瑟夫问题.cpp")

$cal(O)(sqrt(N))$

#include-code("code/数论/约瑟夫问题-2.cpp")
