// prelude.typ — 内容层共享定义：各章共用的宏与辅助函数
// 章文件首行 #import "../prelude.typ": * 后可用。
// 宏随章节迁移逐步收编，不为假设的需求预写。

// 复杂度记号：#O($N log N$) → 𝒪(N log N)
#let O(x) = $cal(O)(#x)$
