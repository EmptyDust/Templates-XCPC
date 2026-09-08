// prelude.typ — 内容层共享定义：各章共用的宏与辅助函数
// 章文件首行 #import "../prelude.typ": * 后可用。
// 宏随章节迁移逐步收编，不为假设的需求预写。

// 复杂度记号：#O($N log N$) → 𝒪(N log N)
#let O(x) = $cal(O)(#x)$

// ---- 版式词汇（灰阶，mono 声部）----

// 元信息行：节的规格头。复杂度/例题范围等以 mono 小字灰阶排成一行，
// 与叙述段拉开密度差——扫读时先停在这里。全节只用一行，不堆叠。
// 用法：#specline([最坏 #O($N^2 M$)], [例题 $N = 1200$])，项间自动留空。
#let specline(..items) = block(above: 0.6em, below: 0.8em,
  text(font: ("JetBrains Mono", "Noto Sans Mono CJK SC"), size: 8pt, fill: luma(90),
    items.pos().join(h(1.4em))))

// 坑点条：踩了就把结果做错的注意点。左近黑粗条——引用块是左浅细条，
// 重 = 危险。只放"错了才知道"级别的内容，写法细节留在正文。
#let pitfall(body) = block(
  stroke: (left: 2.5pt + luma(60)),
  inset: (left: 0.9em, y: 0.25em),
  above: 0.7em, below: 0.8em,
  body)

// 从独立 C++ 源文件读取板子并渲染。
// 约定：// @book-begin 与 // @book-end 之间的行为书中展示内容；
// 之外是让文件可独立编译的脚手架（includes、宏、main），不展示。
// 区域内统一的缩进（如内容包在 main 里）会被剥掉。
// path 相对本文件（仓库根）解析，各章调用时与章位置无关。
// lang：语法高亮语言，默认 cpp。
#let include-code(path, lang: "cpp") = {
  let lines = read(path).split("\n")
  let from = lines.position(l => l.contains("@book-begin")) + 1
  let to = lines.position(l => l.contains("@book-end"))
  let body = lines.slice(from, to)
  let indents = body.filter(l => l.trim() != "").map(l => {
    let m = l.match(regex("^ +"))
    if m == none { 0 } else { m.text.len() }
  })
  let min-indent = if indents.len() == 0 { 0 } else { calc.min(..indents) }
  let stripped = body.map(l => l.slice(calc.min(min-indent, l.len())))
  raw(stripped.join("\n"), lang: lang, block: true)
}
