// Hauptdokument zu footer-footnotes-bibliography-knn.tex.
#import "/Users/g/Library/Mobile Documents/com~apple~CloudDocs/!Docs iCloud/typst-icloud/1-vorlagen-typst/preamble-footnotes-bibliographie-neu.typ": praembel, inhaltsverzeichnis, tabellenverzeichnis, abbildungsverzeichnis, literatur, zweispaltig
#show: praembel
// \titlespacing aus dem TeX-Hauptdokument, nicht aus der Präambel.
#show heading.where(level: 1): set block(above: 1.25em, below: 0.65em)

#let titel = "{{INPUT:FOOTER}}"
#let fusszeile = "{{INPUT:FOOTER}}, G. Haarmeyer"
#let untertitel = none
#let datum = datetime.today().display("[day].[month].[year]")
#set page(footer: context {
  line(length: 100%, stroke: 0.4pt)
  v(2pt)

  h(1fr)
  [#fusszeile, Stand: #datetime.today().display("[day].[month].[year]"), S. #counter(page).display()]
})
#set text(font: "Calibri")
#align(center)[
  #text(size: 17pt, weight: "bold", titel)
  #if untertitel != none { parbreak(); text(size: 12pt, untertitel) }
  #if datum != none { parbreak(); datum }
]
#v(1em)

#inhaltsverzeichnis()
#tabellenverzeichnis()
#abbildungsverzeichnis()

#zweispaltig[
  {{INPUT:BEGINN}}

  = Name <sec-name>
  == Name <sub-name>
  // Fußnoten: #footnote[Anmerkung]; Zitate: @Schluessel.
  - Erster Punkt
  - Zweiter Punkt
]

#v(20mm)
#literatur()
