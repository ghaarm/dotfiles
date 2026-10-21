// ============================================================
// DOKUMENTINFORMATIONEN
// ============================================================
//
// Typst-Version bei Erstellung: 0.15.1
//
// Versionshistorie:
// - 2026-10-11 | Typst 0.15.1 | Vorlage erstellt
//
// Aktuelle Version prüfen: typst --version
// Die Versionsangabe ist Dokumentation, keine Versionsbindung.


// ============================================================
// PRÄAMBEL
// ============================================================

#import "/Users/g/Library/Mobile Documents/com~apple~CloudDocs/!Docs iCloud/typst-icloud/1-vorlagen-typst/preamble-footnotes-bibliographie-neu.typ": praembel


// ============================================================
// OPTIONALE PAKETE
// ============================================================
//
// Nur bei Bedarf aktivieren.
// Vor Aktivierung aktuelle Versionsnummer prüfen.
//
// Grafiken und technische Zeichnungen (CeTZ)
// #import "@preview/cetz:0.5.2": canvas, draw

// Flussdiagramme und Entscheidungsbäume (Fletcher)
// #import "@preview/fletcher:VERSION": diagram, node, edge

// Wissenschaftliche Plots und Datenvisualisierung (Lilaq)
// #import "@preview/lilaq:VERSION": *

// Abkürzungs- und Glossarverwaltung (Glossarium)
// #import "@preview/glossarium:VERSION": *

// SI-Einheiten und Zahlenformatierung (Unify)
// #import "@preview/unify:VERSION": *

// Hinweis- und Merkkästen (Showybox)
// #import "@preview/showybox:VERSION": *

// Formatierte Codeblöcke (Codly)
// #import "@preview/codly:VERSION": *

// Zeitachsen (Timeliney)
// #import "@preview/timeliney:VERSION": *

// Präsentationen (Touying)
// Besser in eigener Präsentationsvorlage verwenden.
// #import "@preview/touying:VERSION": *


// ============================================================
// DOKUMENTLAYOUT
// ============================================================

#show: praembel

#let linkrot = rgb("a32121")

#show link: set text(fill: linkrot)
#show link.where(dest: str): set text(fill: blue)
#show footnote: set text(fill: linkrot)

#show heading.where(level: 1): set block(
  above: 1.25em,
  below: 0.65em,
)
#let titel = "{{INPUT:TITLE}}"

#let fusszeile = "{{INPUT:FOOTER}}, G. Haarmeyer"

#let untertitel = "- nur für den persönlichen Gebrauch -"

// #let datum = datetime.today().display("[day].[month].[year]")

#let datum = datetime.today().display("[year]-[month]-[day]")

#set page(footer: context {
  line(length: 100%, stroke: 0.4pt)
  v(2pt)
  link(<inhaltsverzeichnis>)[Zurück zum Inhaltsverzeichnis]
  h(1fr)
  // [#fusszeile, Stand: #datetime.today().display("[day].[month].[year]"), S. #counter(page).display()]
  [#fusszeile, Stand: #datetime.today().display("[year]-[month]-[day]"), S. #counter(page).display()]
})

#align(center)[
  #text(size: 17pt, weight: "regular", titel)

  #if untertitel != none {
    parbreak()
    text(size: 12pt, untertitel)
  }

  #if datum != none {
    v(4mm)
    parbreak()
    datum
  }
]
#v(1em) // Abstand zum Inhaltsverzeichnis

#[
  #show outline.entry: set text(fill: linkrot)
  #show outline.entry.where(level: 1): set text(weight: "bold")
  #show outline.entry.where(level: 1): set outline.entry(fill: none)
  #show outline.entry.where(level: 1): set block(above: 1em)

  #outline(title: "Inhaltsverzeichnis") <inhaltsverzeichnis>
]

#outline(target: figure.where(kind: table), title: "Tabellenverzeichnis")
#outline(target: figure.where(kind: image), title: "Abbildungsverzeichnis")


// ============================================================
// BEGINN DOCUMENT
// ============================================================


= Kernpunkte (TL;DR)

+ Key Point 1
+ Key Point 2
+ Key Point 3

#columns(2, gutter: 7mm)[
  {{INPUT:BEGINN}}

  = Name <sec-name>
  == Name <sub-name>
  // Fußnoten: #footnote[Anmerkung]; Zitate: @Schluessel.

#set list(marker: [–])
  - Erster Punkt
  - Zweiter Punkt
]

#v(20mm)
#bibliography(
  "/Users/g/Library/Mobile Documents/com~apple~CloudDocs/!Docs iCloud/typst-icloud/1-vorlagen-typst/Zotero.bib",
  title: [Literatur],
  style: "/Users/g/Library/Mobile Documents/com~apple~CloudDocs/!Docs iCloud/typst-icloud/1-vorlagen-typst/chicago-autojahr-nummeriert.csl",
)
