// main.typ — 编排层：全书入口
// 构建：typst compile --root . --font-path export/vendor/jetbrains-mono main.typ build/book.pdf
#import "theme.typ": *
#import "prelude.typ": *

#show: theme
#set document(title: "风铃的模板库")

// ---- 封面并入目录页，无页脚 ----
#[
  #set page(footer: none)
  #text(17pt, weight: "bold")[风铃的模板库]
  #v(1.2em)
  #text(13pt, weight: "bold")[目录]
  #v(0.6em)
  #columns(2, gutter: 18pt)[
    #outline(title: none, depth: 2, indent: 1em)
  ]
]

// ---- 正文：页码从 1 起算，页脚居中 ----
#pagebreak()
#counter(page).update(1)
#set page(footer: context {
  let n = counter(page).get().first()
  if n >= 1 { align(center, text(8.5pt)[#n]) }
})

#include "chapters/STL与库函数.typ"
#include "chapters/三维几何及常见例题.typ"
#include "chapters/串.typ"
#include "chapters/二维几何.typ"
#include "chapters/动态规划.typ"
#include "chapters/博弈论.typ"
#include "chapters/图论.typ"
#include "chapters/基础算法.typ"
#include "chapters/多边形相关.typ"
#include "chapters/多项式.typ"
#include "chapters/常见例题.typ"
#include "chapters/数据结构A.typ"
#include "chapters/数据结构B.typ"
#include "chapters/数论.typ"
#include "chapters/杂项.typ"
#include "chapters/树上问题.typ"
#include "chapters/线性代数.typ"
#include "chapters/组合数学.typ"
#include "chapters/网络流.typ"
