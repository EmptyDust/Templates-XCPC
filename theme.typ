// theme.typ — 视觉层：全书的字体、版面、代码、目录样式
// 与 export/template.typ 同一套设计，差异只在标题层级：
// 原生结构里章 = level 1（pandoc 管线里章 = level 2）。
// 用法：#import "theme.typ": * 然后 #show: theme

#let theme(doc) = {
  set page(
    paper: "a4",
    margin: (x: 36pt, top: 40pt, bottom: 44pt),
  )
  set text(
    font: ("Noto Serif", "Noto Serif CJK SC"),
    size: 9.5pt,
    lang: "zh",
    region: "cn",
  )
  set par(justify: true, leading: 0.66em)

  // 公式：TeX Gyre Termes Math，笔画粗细与正文一致
  show math.equation: set text(font: "TeX Gyre Termes Math")

  // ---- 标题层级：章 level 1（另起一页），节 level 2，小节 level 3 ----
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    v(0.2em)
    text(15pt, weight: "bold", it.body)
    v(0.3em)
    line(length: 100%, stroke: 0.6pt + luma(213))
    v(0.6em)
  }
  show heading.where(level: 2): it => {
    v(0.9em)
    text(11.8pt, weight: "bold", it.body)
    v(0.25em)
  }
  show heading.where(level: 3): it => {
    v(0.7em)
    text(10.6pt, weight: "bold", it.body)
    v(0.2em)
  }

  // ---- 代码 ----
  set raw(theme: "export/book-mono.tmTheme")
  // JetBrains Mono 有连字（<= → ≤）。syntect 高亮分段会绕过 ligatures: false，
  // 必须关 OpenType 特性本身
  show raw: set text(ligatures: false, features: (liga: 0, clig: 0, calt: 0, dlig: 0))
  show raw.where(block: true): set text(
    font: ("JetBrains Mono", "Noto Sans Mono CJK SC", "Noto Serif CJK SC"),
    // raw 默认自带 0.8em 缩小且相对值与之叠乘；0.9375 × 0.8 = 0.75
    size: 0.9375em,
  )
  show raw.where(block: true): it => block(
    fill: luma(245),
    radius: 2pt,
    inset: (x: 8pt, y: 7pt),
    width: 100%,
    breakable: true,
    {
      set par(justify: false, leading: 0.5em)
      it
    },
  )
  // 行内代码：等宽 + 浅色下划线，extent 原生延伸
  // raw 默认自带 0.8em 缩小；1.25 × 0.8 = 1，与正文等大
  show raw.where(block: false): set text(font: ("JetBrains Mono", "Noto Sans Mono CJK SC", "Noto Serif CJK SC"), size: 1.25em)
  show raw.where(block: false): it => underline(
    offset: 2.2pt,
    extent: 0.8pt,
    stroke: 0.8pt + luma(206),
    it,
  )

  // 引用块：左边条
  show quote.where(block: true): it => {
    v(0.2em)
    block(
      stroke: (left: 1.6pt + luma(195)),
      inset: (left: 0.9em, y: 0.1em),
      it.body,
    )
    v(0.2em)
  }

  // 表格
  set table(stroke: 0.4pt + luma(204), inset: 0.45em)
  show table.cell.where(y: 0): strong

  // 链接不染色，只保留继承色
  show link: it => text(fill: luma(17), it)

  // 图片：比栏宽 80% 大的缩到 80%，小图保持原始尺寸
  show image: it => layout(size => {
    let w = measure(it).width
    if w > size.width * 0.8 { set image(width: 80%); it } else { it }
  })

  // 目录条目：章加粗
  show outline.entry.where(level: 1): set text(weight: "bold")

  doc
}
