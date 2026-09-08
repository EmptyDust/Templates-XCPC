// theme.typ — 视觉层：全书的字体、版面、代码、目录样式
// 与 export/template.typ 同一套设计，差异只在标题层级：
// 原生结构里章 = level 1（pandoc 管线里章 = level 2）。
// 用法：#import "theme.typ": * 然后 #show: theme

#let theme(doc) = {
  set page(
    paper: "a4",
    margin: (x: 36pt, top: 40pt, bottom: 44pt),
    // 页眉 running head：偶数页书名、奇数页当前章名；起章页与首章之前无页眉。
    // 起章页不放页眉——页眉取的是 here() 之前最后一个章标题，章首会顶着上一章的章名。
    header: context {
      let heads = query(heading.where(level: 1))
      if heads.any(h => h.location().page() == here().page()) { return }
      let past = query(heading.where(level: 1).before(here()))
      if past.len() == 0 { return }
      let even = calc.even(counter(page).get().first())
      align(if even { left } else { right }, text(8.5pt, fill: luma(90), if even {
        [风铃的模板库]
      } else {
        past.last().body
      }))
    },
  )
  set text(
    font: ("Noto Serif", "Noto Serif CJK SC"),
    size: 9.5pt,
    lang: "zh",
    region: "cn",
  )
  set par(justify: true, leading: 0.45em)

  // 公式：TeX Gyre Termes Math，笔画粗细与正文一致
  show math.equation: set text(font: "TeX Gyre Termes Math")

  // ---- 标题层级：章 level 1（另起一页），节 level 2，小节 level 3 ----
  // 必须保留 `it`（heading 元素），只改 set text 的话目录/书签才能挂上 PDF 目的地。
  // 写成 text(it.body) 会丢掉 heading，outline 点了跳不过去。
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    v(0.4em)
    // 章号：place 到页面右上角，不占流式高度——行盒自带下降部空隙，进流排版
    // 会让数字底边悬在细线上方、顶边也够不高。底边压到标题细线附近，
    // 顶边伸进起章页空置的页眉带（页眉规则见上）。dy 按渲染实测微调。
    // 字体 Jost 900（Futura 复刻，vendor 于 export/vendor/jost）：几何无衬线巨号
    // 是书籍 folio 正典；粗字重墨面积大，灰度提到 luma(230) 做光学补偿。
    // 勿换回 mono——代码字体（JBM）放大是平的，URW Gothic 只有 regular 一档。
    // before(here()) 在标题自身的 show 规则里会把它自己也数进去，恰为章序，勿 +1；
    // counter(heading) 则会被 ==/=== 一起步进，不可用。
    context {
      let pri = query(heading.where(level: 1).before(here())).len()
      // numbering("01", n) 的 "0" 是字面前缀不是补零（10→"010"），手动补零
      let num = str(pri)
      if num.len() < 2 { num = "0" + num }
      place(top + right, dy: -11pt,
        text(font: "Jost", size: 64pt, weight: 900, fill: luma(230), num))
    }
    // 间距显式接管（绝对 pt）：线的落位以 protoA/B 版为基准——纸顶 29.0mm。
    // block 的 above 在页首会塌缩，页首间距必须用强 v()。
    v(7.5pt)
    block(below: 6pt, {
      set text(17pt, weight: "bold")
      it
    })
    line(length: 100%, stroke: 0.6pt + luma(213))
    v(0.6em)
  }
  show heading.where(level: 2): it => {
    v(0.9em)
    set text(11.8pt, weight: "bold")
    it
    v(0.25em)
  }
  show heading.where(level: 3): it => {
    v(0.7em)
    set text(10.6pt, weight: "bold")
    it
    v(0.2em)
  }

  // ---- 代码 ----
  set raw(theme: "export/book-mono.tmTheme")
  // 内置语法集不含 powershell，vendor 一份极简定义
  set raw(syntaxes: "export/powershell.sublime-syntax")
  // JetBrains Mono 有连字（<= → ≤）。syntect 高亮分段会绕过 ligatures: false，
  // 必须关 OpenType 特性本身
  show raw: set text(ligatures: false, features: (liga: 0, clig: 0, calt: 0, dlig: 0))
  // 代码块：不写 size，沿用 raw 内置的 0.8em（相对正文）
  show raw.where(block: true): set text(
    font: ("JetBrains Mono", "Noto Sans Mono CJK SC", "Noto Serif CJK SC"),
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
  // raw 默认自带 0.8em 缩小；1.125 × 0.8 = 0.9，与旧版 wida `code { font-size: 0.9em }` 一致
  show raw.where(block: false): set text(font: ("JetBrains Mono", "Noto Sans Mono CJK SC", "Noto Serif CJK SC"), size: 1.125em)
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

  // 表格：booktabs 三线（顶线、栏头线、底线），无竖线
  set table(
    stroke: (x, y) => (
      top: if y == 0 { 0.7pt + luma(30) }
           else if y == 1 { 0.4pt + luma(90) }
           else { none },
      left: none,
      right: none,
      bottom: none,
    ),
    inset: 0.45em,
  )
  show table: it => block(stroke: (bottom: 0.7pt + luma(30)), inset: 0pt, it)
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
