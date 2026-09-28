local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta -- fmta für latex snippets

return {
  -- Autosnippets
  --
  --
  s({ trig = "g%", wordTrig = false, desr = "~\\% geschütztes Prozent", snippetType = "autosnippet" }, {
    t([[~\%]]),
  }),
  s({ trig = "reff", wordTrig = true, dscr = "referenz latex", snippetType = "autosnippet" }, {
    t("\\ref{"),
    i(1),
    t("}"),
  }),
  -- normale snippets
  --
  --
  -- s({
  --   trig = "g%",
  --   wordTrig = false, -- cmtsub, O2tsub, ...
  --   dscr = "~\\% geschütztes Prozent",
  -- }, {
  --   t("~\\%"),
  --   i(1),
  -- }),
  s({
    trig = "tsup",
    wordTrig = false, -- darf mitten im Wort stehen (cmtsup, O2tsup, ...)
    dscr = "Text superscript",
  }, {
    t("\\textsuperscript{"),
    i(1),
    t("}"),
    i(0),
  }),

  -- tsub: Subscript hinter bereits getipptem Text
  s({
    trig = "tsub",
    wordTrig = false, -- cmtsub, O2tsub, ...
    dscr = "Text subscript",
  }, {
    t("\\textsubscript{"),
    i(1),
    t("}"),
    i(0),
  }),
  s(
    {
      trig = "citef",
      name = "Zitat foot",
      wordTrig = false,
      dscr = "Zitat als Fußnote: \\footcite + Seite",
    },
    fmta([[\footcite[S.~<>]{<>}]], {
      i(1, "Seite"),
      i(2, "name"),
    })
  ),
  -- andere Snippets
  s("OR", {
    t("OR "),
    i(1, "or"),
    t(" (95~\\%-CI "),
    i(2, "wert-1"),
    t("--"),
    i(3, "wert-2"),
    t("; p $"),
    c(4, {
      t("="),
      t("<"),
      t(">"),
    }),
    t("$ "),
    i(5, "p-wert"),
    t(")"),
    i(0),
  }),
  s(
    {
      trig = "link-name-datum-heute",
      name = "Link mit Name und Datum heute",
      wordTrig = false,
    },
    fmta([[\href{<>}{<> (Stand <>)}]], {
      i(1),
      i(2, "beschreibung"),
      f(function()
        return os.date("%d.%m.%Y")
      end),
    })
  ),
}
