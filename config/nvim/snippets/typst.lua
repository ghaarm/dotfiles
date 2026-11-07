local ls = require("luasnip")

local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local fmt = require("luasnip.extras.fmt").fmt
local line_begin = require("luasnip.extras.expand_conditions").line_begin
local events = require("luasnip.util.events")

-- Überschrift in einen gültigen Label-Namen umwandeln.
local function slugify(text)
  local replacements = {
    ["Ä"] = "Ae",
    ["Ö"] = "Oe",
    ["Ü"] = "Ue",
    ["ä"] = "ae",
    ["ö"] = "oe",
    ["ü"] = "ue",
    ["ß"] = "ss",
    ["ẞ"] = "SS",
  }

  for from, to in pairs(replacements) do
    text = text:gsub(from, to)
  end

  text = text:lower()

  -- Sonderzeichen entfernen, Leerzeichen durch Bindestriche ersetzen.
  text = text:gsub("[^%w%s%-]", "")
  text = text:gsub("%s+", "-")
  text = text:gsub("%-+", "-")
  text = text:gsub("^%-", ""):gsub("%-$", "")

  return text
end

-- Label dynamisch aus dem eingegebenen Titel erzeugen.
local function make_label(prefix)
  return function(args)
    local title = args[1][1] or ""
    local namespace = prefix ~= "" and prefix .. ":" or ""
    return "<" .. namespace .. slugify(title) .. ">"
  end
end

-- Snippet für eine Überschriftenebene erzeugen.
local function heading_snippet(trigger, level)
  return s(trigger, {
    t(string.rep("=", level) .. " "),
    i(1, "Titel"),
    t(" "),
    f(make_label(trigger), { 1 }),
    i(0),
  })
end

local snippets = {
  heading_snippet("sec", 1),
  heading_snippet("sub", 2),
  heading_snippet("ssub", 3),
  heading_snippet("sssub", 4),
  s({ trig = "lab", dscr = "Label" }, {
    t("<"),
    i(1, "label", {
      node_callbacks = {
        [events.leave] = function(node)
          node:set_text({ slugify(table.concat(node:get_text(), " ")) })
        end,
      },
    }),
    t(">"),
    i(0),
  }),
}

-- Snippets mit Labels, deren Namen aus der jeweiligen Beschriftung entstehen.
local labeled_snippets = {
  s({ trig = "chapter", dscr = "Kapitel mit Label", condition = line_begin }, fmt([[= {} {}

#outline(title: [In diesem Kapitel], target: heading.where(level: 2))

{}
]], {
    i(1, 'Kapitel'),
    f(make_label("chap"), { 1 }),
    i(0),
  })),
  s({ trig = "nossub", dscr = "Unterunterabschnitt ohne Inhaltsverzeichnis", condition = line_begin }, fmt([[#heading(level: 3, outlined: false)[{}] {}
{}
]], {
    i(1, 'Titel'),
    f(make_label("sub"), { 1 }),
    i(0),
  })),
  s({ trig = "hsec", dscr = "Abschnitt mit Label", condition = line_begin }, fmt([[= {} {}
{}
]], {
    i(1, 'Titel'),
    f(make_label("sec"), { 1 }),
    i(0),
  })),
  s({ trig = "hsub", dscr = "Unterabschnitt mit Label", condition = line_begin }, fmt([[== {} {}
{}
]], {
    i(1, 'Titel'),
    f(make_label("sub"), { 1 }),
    i(0),
  })),
  s({ trig = "hssub", dscr = "Unterunterabschnitt mit Label", condition = line_begin }, fmt([[=== {} {}
{}
]], {
    i(1, 'Titel'),
    f(make_label("sub"), { 1 }),
    i(0),
  })),
  s({ trig = "ilabelcom", dscr = "Aufzählungspunkt mit Label", condition = line_begin }, fmt([[- {} {}{}
]], {
    i(1, 'Text'),
    f(make_label(""), { 1 }),
    i(0),
  })),
  s({ trig = "factoidbox", dscr = "Merkkasten mit Label", condition = line_begin }, fmt([[#rect(width: 100%, inset: 8pt, stroke: 0.5pt)[
  *{}* {}
] {}{}
]], {
    i(1, 'Name'),
    i(2, 'Text'),
    f(make_label("rule"), { 1 }),
    i(0),
  })),
  s({ trig = "customthm", dscr = "Aussage mit Antwort", condition = line_begin }, fmt([[#block[
  *{}.* {}
] {}

*Antwort.* {}
]], {
    i(1, 'Name'),
    i(2, 'Aussage'),
    f(make_label("thm"), { 1 }),
    i(0),
  })),
  s({ trig = "rule", dscr = "Regel mit Label", condition = line_begin }, fmt([[#block[*{}.* {}] {}{}
]], {
    i(1, 'Regel'),
    i(2, 'Text'),
    f(make_label("rule"), { 1 }),
    i(0),
  })),
  s({ trig = "lemma", dscr = "Lemma mit Label", condition = line_begin }, fmt([[#block[*Lemma.* {}] {}{}
]], {
    i(1, 'Text'),
    f(make_label("lemma"), { 1 }),
    i(0),
  })),
  s({ trig = "prop", dscr = "Proposition mit Label", condition = line_begin }, fmt([[#block[*Proposition.* {}] {}{}
]], {
    i(1, 'Text'),
    f(make_label("prop"), { 1 }),
    i(0),
  })),
  s({ trig = "thrm", dscr = "Satz mit Label", condition = line_begin }, fmt([[#block[*Satz.* {}] {}{}
]], {
    i(1, 'Text'),
    f(make_label("thm"), { 1 }),
    i(0),
  })),
  s({ trig = "def", dscr = "Definition", condition = line_begin }, fmt([[#block[*Definition {}.* {}] {}{}
]], {
    i(1, 'Name'),
    i(2, 'Text'),
    f(make_label("def"), { 1 }),
    i(0),
  })),
  s({ trig = "prob", dscr = "Problem", condition = line_begin }, fmt([[#block[*Problem {}.* {}] {}{}
]], {
    i(1, 'Name'),
    i(2, 'Text'),
    f(make_label("prob"), { 1 }),
    i(0),
  })),
  s({ trig = "corl", dscr = "Korollar", condition = line_begin }, fmt([[#block[*Korollar {}.* {}] {}{}
]], {
    i(1, 'Name'),
    i(2, 'Text'),
    f(make_label("cor"), { 1 }),
    i(0),
  })),
  s({ trig = "example", dscr = "Beispiel", condition = line_begin }, fmt([[#block[*Beispiel {}.* {}] {}{}
]], {
    i(1, 'Name'),
    i(2, 'Text'),
    f(make_label("ex"), { 1 }),
    i(0),
  })),
  s({ trig = "align", dscr = "Mehrzeilige Formel", condition = line_begin }, fmt([[$
  {} &= {} \\
  {} &= {}
$ {}{}
]], {
    i(1, 'a'),
    i(2, 'b'),
    i(3, 'c'),
    i(4, 'd'),
    f(make_label("eq"), { 1 }),
    i(0),
  })),
  s({ trig = "equation", dscr = "Nummerierte Formel", condition = line_begin }, fmt([[$
  {}
$ {}{}
]], {
    i(1, 'a + b'),
    f(make_label("eq"), { 1 }),
    i(0),
  })),
  s({ trig = "equation-simple-label", dscr = "Einfache Formel mit Label", condition = line_begin }, fmt([[$ {} = {} dot {} $ {}{}
]], {
    i(1, 'y'),
    i(2, 'a'),
    i(3, 'b'),
    f(make_label("eq"), { 1 }),
    i(0),
  })),
  s({ trig = "equation-multi-label", dscr = "Mehrzeilige Formel mit Label", condition = line_begin }, fmt([[$ {} &= {} $ {}{}
]], {
    i(1, 'y'),
    i(2, 'a + b'),
    f(make_label("eq"), { 1 }),
    i(0),
  })),
  s({ trig = "fig", dscr = "Abbildung mit Beschriftung und Label", condition = line_begin }, fmt([[#figure(
  image("{}", width: {}),
  caption: [{}],
) {}
{}
]], {
    i(1, 'bilder/datei.png'),
    i(2, '100%'),
    i(3, 'Bildunterschrift'),
    f(make_label("fig"), { 3 }),
    i(0),
  })),
  s({ trig = "pngfig", dscr = "PNG-Abbildung mit Quelle", condition = line_begin }, fmt([[#figure(
  image("./bilder-latex/{}", width: 100%),
  caption: [{}],
) {}
#text(size: 8pt)[Quelle: #cite(<{}>, supplement: [S. {}])]
{}
]], {
    i(1, 'datei.png'),
    i(2, 'Bildunterschrift'),
    f(make_label("fig"), { 2 }),
    i(3, 'key'),
    i(4, 'seite'),
    i(0),
  })),
  s({ trig = "pngfigup", dscr = "PNG-Abbildung mit Quelle", condition = line_begin }, fmt([[#figure(
  image("./bilder-latex/{}", width: 100%),
  caption: [{}],
) {}
#text(size: 8pt)[Quelle: #cite(<{}>, supplement: [S. {}])]
{}
]], {
    i(1, 'datei.png'),
    i(2, 'Bildunterschrift'),
    f(make_label("fig"), { 2 }),
    i(3, 'key'),
    i(4, 'seite'),
    i(0),
  })),
  s({ trig = "pngfigdown", dscr = "PNG-Abbildung mit Quelle", condition = line_begin }, fmt([[#figure(
  image("./bilder-latex/{}", width: 100%),
  caption: [{}],
) {}
#text(size: 8pt)[Quelle: #cite(<{}>, supplement: [S. {}])]
{}
]], {
    i(1, 'datei.png'),
    i(2, 'Bildunterschrift'),
    f(make_label("fig"), { 2 }),
    i(3, 'key'),
    i(4, 'seite'),
    i(0),
  })),
  s({ trig = "pngsame", dscr = "PNG-Abbildung im gleichen Ordner", condition = line_begin }, fmt([[#figure(image("{}", width: 100%), caption: [{}]) {}{}
]], {
    i(1, 'datei.png'),
    i(2, 'Titel'),
    f(make_label("fig"), { 2 }),
    i(0),
  })),
  s({ trig = "pppsame", dscr = "PNG-Abbildung im gleichen Ordner", condition = line_begin }, fmt([[#figure(image("{}", width: 100%), caption: [{}]) {}{}
]], {
    i(1, 'datei.png'),
    i(2, 'Titel'),
    f(make_label("fig"), { 2 }),
    i(0),
  })),
  s({ trig = "pngfigcenter", dscr = "Zentrierte Abbildung", condition = line_begin }, fmt([[#align(center)[
  #figure(image("{}", width: 100%), caption: [{}]) {}
]{}
]], {
    i(1, 'datei.png'),
    i(2, 'Titel'),
    f(make_label("fig"), { 2 }),
    i(0),
  })),
  s({ trig = "pngcenterFIG", dscr = "Abbildung in einer Spalte", condition = line_begin }, fmt([[#figure(image("{}", width: 100%), caption: [{}]) {}{}
]], {
    i(1, 'datei.png'),
    i(2, 'Titel'),
    f(make_label("fig"), { 2 }),
    i(0),
  })),
  s({ trig = "pngtab", dscr = "Bild als Tabelle", condition = line_begin }, fmt([[#figure(
  image("./bilder-latex/{}", width: 100%),
  kind: table,
  caption: [{}],
) {}
#text(size: 8pt)[Quelle: #cite(<{}>, supplement: [S. {}])]
{}
]], {
    i(1, 'datei.png'),
    i(2, 'Tabellentitel'),
    f(make_label("tab"), { 2 }),
    i(3, 'key'),
    i(4, 'seite'),
    i(0),
  })),
  s({ trig = "pngtabup", dscr = "Bild als Tabelle", condition = line_begin }, fmt([[#figure(image("./bilder-latex/{}", width: 100%), kind: table, caption: [{}]) {}{}
]], {
    i(1, 'datei.png'),
    i(2, 'Titel'),
    f(make_label("tab"), { 2 }),
    i(0),
  })),
  s({ trig = "pngtabdown", dscr = "Bild als Tabelle", condition = line_begin }, fmt([[#figure(image("./bilder-latex/{}", width: 100%), kind: table, caption: [{}]) {}{}
]], {
    i(1, 'datei.png'),
    i(2, 'Titel'),
    f(make_label("tab"), { 2 }),
    i(0),
  })),
  s({ trig = "pngtabcenter", dscr = "Zentriertes Bild als Tabelle", condition = line_begin }, fmt([[#align(center)[
  #figure(image("./bilder-latex/{}", width: 100%), kind: table, caption: [{}]) {}
]{}
]], {
    i(1, 'datei.png'),
    i(2, 'Titel'),
    f(make_label("tab"), { 2 }),
    i(0),
  })),
  s({ trig = "pngcenterTAB", dscr = "Bild als Tabelle in einer Spalte", condition = line_begin }, fmt([[#figure(image("{}", width: 100%), kind: table, caption: [{}]) {}{}
]], {
    i(1, 'datei.png'),
    i(2, 'Titel'),
    f(make_label("tab"), { 2 }),
    i(0),
  })),
  s({ trig = "ecmopng", dscr = "ECMO-PNG", condition = line_begin }, fmt([[#figure(image("./ECMO-latex-png/{}", width: 100%), caption: [{}]) {}{}
]], {
    i(1, 'datei.png'),
    i(2, 'Titel'),
    f(make_label("fig"), { 2 }),
    i(0),
  })),
  s({ trig = "ecmopdf", dscr = "ECMO-PDF als Bild", condition = line_begin }, fmt([[#figure(image("./ECMO-latex-png/{}", width: 100%), caption: [{}]) {}{}
]], {
    i(1, 'datei.pdf'),
    i(2, 'Titel'),
    f(make_label("fig"), { 2 }),
    i(0),
  })),
  s({ trig = "ecmotbl", dscr = "ECMO-Bild als Tabelle", condition = line_begin }, fmt([[#figure(image("./ECMO-latex-png/{}", width: 100%), kind: table, caption: [{}]) {}{}
]], {
    i(1, 'datei.png'),
    i(2, 'Titel'),
    f(make_label("tab"), { 2 }),
    i(0),
  })),
  s({ trig = "pdfi", dscr = "PDF als Abbildung", condition = line_begin }, fmt([[#figure(image("{}", width: 50%), caption: [{}]) {}{}
]], {
    i(1, 'datei.pdf'),
    i(2, 'Titel'),
    f(make_label("fig"), { 2 }),
    i(0),
  })),
  s({ trig = "tabelle3x3", dscr = "Tabelle mit drei Spalten", condition = line_begin }, fmt([[#figure(
  table(
    columns: 3,
    [{}], [{}], [{}],
    [{}], [{}], [{}],
    [{}], [{}], [{}],
  ),
  caption: [{}],
) {}{}
]], {
    i(1, 'Spalte 1'),
    i(2, 'Spalte 2'),
    i(3, 'Spalte 3'),
    i(4, 'Zelle'),
    i(5, 'Zelle'),
    i(6, 'Zelle'),
    i(7, 'Zelle'),
    i(8, 'Zelle'),
    i(9, 'Zelle'),
    i(10, 'Titel'),
    f(make_label("tab"), { 10 }),
    i(0),
  })),
  s({ trig = "tabelle2x3", dscr = "Tabelle mit zwei Spalten", condition = line_begin }, fmt([[#figure(
  table(
    columns: 2,
    [{}], [{}],
    [{}], [{}],
    [{}], [{}],
  ),
  caption: [{}],
) {}{}
]], {
    i(1, 'Spalte 1'),
    i(2, 'Spalte 2'),
    i(3, 'Zelle'),
    i(4, 'Zelle'),
    i(5, 'Zelle'),
    i(6, 'Zelle'),
    i(7, 'Titel'),
    f(make_label("tab"), { 7 }),
    i(0),
  })),
  s({ trig = "pngmulti", dscr = "Zwei Bilder nebeneinander", condition = line_begin }, fmt([[#grid(
  columns: (1fr, 1fr),
  gutter: 8mm,
  [#figure(image("{}", width: 100%), caption: [{}]) {}],
  [#figure(image("{}", width: 100%), caption: [{}]) {}],
){}
]], {
    i(1, 'links.png'),
    i(2, 'Titel links'),
    f(make_label("fig"), { 2 }),
    i(3, 'rechts.png'),
    i(4, 'Titel rechts'),
    f(make_label("fig"), { 4 }),
    i(0),
  })),
  s({ trig = "pppmulti", dscr = "Bild mit Beschriftung", condition = line_begin }, fmt([[#figure(image("{}", width: 100%), caption: [{}]) {}{}
]], {
    i(1, 'datei.png'),
    i(2, 'Titel'),
    f(make_label("fig"), { 2 }),
    i(0),
  })),
}

for _, snippet in ipairs(labeled_snippets) do
  table.insert(snippets, snippet)
end

return snippets
