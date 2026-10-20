// Hauptdokument zu footer-footnotes-bibliography.tex.
#import "/Users/g/Library/Mobile Documents/com~apple~CloudDocs/!Docs iCloud/typst-icloud/1-vorlagen-typst/preamble-footnotes-bibliographie-neu.typ": praembel
#show: praembel
// \titlespacing aus dem TeX-Hauptdokument, nicht aus der Präambel.
#show heading.where(level: 1): set block(above: 1.25em, below: 0.65em)

#let titel = "{{INPUT:TITLE}}"
#let fusszeile = "{{INPUT:FOOTER}}, G. Haarmeyer"
#let untertitel = "- nur für den persönlichen Gebrauch -"
#let datum = datetime.today().display("[day].[month].[year]")
#set page(footer: context {
  line(length: 100%, stroke: 0.4pt)
  v(2pt)
  link(<inhaltsverzeichnis>)[Zurück zum Inhaltsverzeichnis]
  h(1fr)
  [#fusszeile, Stand: #datetime.today().display("[day].[month].[year]"), S. #counter(page).display()]
})

#align(center)[
  #text(size: 17pt, weight: "bold", titel)
  #if untertitel != none { parbreak(); text(size: 12pt, untertitel) }
  #if datum != none { parbreak(); datum }
]
#v(1em)

#[
  #show outline.entry.where(level: 1): set outline.entry(fill: none)
  #show outline.entry.where(level: 1): set block(above: 1em)
  #outline(title: "Inhaltsverzeichnis") <inhaltsverzeichnis>
]
#outline(target: figure.where(kind: table), title: "Tabellenverzeichnis")
#outline(target: figure.where(kind: image), title: "Abbildungsverzeichnis")

= Kernpunkte (TL;DR)

+ Key Point 1
+ Key Point 2
+ Key Point 3

#columns(2, gutter: 7mm)[
  {{INPUT:BEGINN}}

  = Name <sec-name>
  == Name <sub-name>
  // Fußnoten: #footnote[Anmerkung]; Zitate: @Schluessel.
  - Erster Punkt
  - Zweiter Punkt
]

#v(20mm)
#bibliography(
  "/Users/g/Library/Mobile Documents/com~apple~CloudDocs/!Docs iCloud/typst-icloud/1-vorlagen-typst/Zotero.bib",
  title: [Literatur],
  style: "/Users/g/Library/Mobile Documents/com~apple~CloudDocs/!Docs iCloud/typst-icloud/1-vorlagen-typst/chicago-autojahr-nummeriert.csl",
)
