// prelude.typ — 内容层共享定义：各章共用的宏与辅助函数
// 章文件首行 #import "../prelude.typ": * 后可用。
// 宏随章节迁移逐步收编，不为假设的需求预写。

// 复杂度记号：#O($N log N$) → 𝒪(N log N)
#let O(x) = $cal(O)(#x)$

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
