-- Keep LaTeX math as LaTeX; Typst renders it via mitex.
local function wrap(tex, cmd)
  if tex:find("`", 1, true) then
    local q = tex:gsub("\\", "\\\\"):gsub('"', '\\"')
    return cmd .. '("' .. q .. '")'
  end
  return cmd .. "(`" .. tex .. "`)"
end

function Math(el)
  if el.mathtype == "InlineMath" then
    return pandoc.RawInline("typst", wrap(el.text, "#mi"))
  end
  return pandoc.RawInline("typst", wrap(el.text, "#mitex"))
end

function RawBlock(el)
  if el.format:match("html") and el.text:match("page%-break%-after") then
    return pandoc.RawBlock("typst", "#pagebreak(weak: true)")
  end
end

function Image(el)
  local src = el.src or ""
  if src:match("^https?://") then
    return {
      pandoc.Strong{pandoc.Str("[图]")},
      pandoc.Space(),
      pandoc.Code(src),
    }
  end
end
