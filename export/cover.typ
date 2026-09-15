// 单独封面：打印另张纸，不进正文页码。
#let stamp = sys.inputs.at("stamp", default: datetime.today().display("[year]-[month]-[day]"))
#let rev = sys.inputs.at("rev", default: "")

#set page(margin: 36pt)
#set text(font: ("Noto Serif", "Noto Serif CJK SC"))

#align(center + horizon,
  stack(
    spacing: 24pt,
    text(36pt, weight: "bold")[风铃的模板库],
    text(font: "Montserrat", size: 14pt)[#stamp#if rev != "" [ #rev]],
  )
)
