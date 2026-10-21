// ============================================================
// DOKUMENTINFORMATIONEN
// ============================================================
//
// Eigenständige Typst-Präsentation ohne Touying.
// Format: 16:9
//
// Typst-Version bei Erstellung: 0.15.1
//
// Versionshistorie:
// - 2026-10-11 | Typst 0.15.1 | Vorlage erstellt
//
// Aktuelle Version prüfen: typst --version
// Die Versionsangabe ist Dokumentation, keine Versionsbindung.


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

// Formatierte Codeblöcke (Codly)
// #import "@preview/codly:VERSION": *

// Zeitachsen (Timeliney)
// #import "@preview/timeliney:VERSION": *


// ============================================================
// DOKUMENTDATEN
// ============================================================

#let titel = "{{INPUT:TITLE}}"
#let untertitel = "{{INPUT:SUBTITLE}}"
#let autor = "G. Haarmeyer"
#let datum = "{{INPUT:DATE}}"
#let bereich = "{{INPUT:FOOTER}}"
#let veranstaltung = "{{INPUT:EVENT}}"
#let minuten = "{{INPUT:MINUTEN}}"
#let thema = "{{INPUT:THEMA}}"


// ============================================================
// FARBEN
// ============================================================

#let dunkelblau = rgb("214b72")
#let textblau = rgb("173a5c")
#let hellblau = rgb("eef3f7")
#let rahmenblau = rgb("bccbd8")
#let rot = rgb("b02b2b")


// ============================================================
// SEITENLAYOUT
// ============================================================

#set page(
  width: 33.867cm,
  height: 19.05cm,
  margin: (
    left: 2cm,
    right: 2cm,
    top: 1.5cm,
    bottom: 1.4cm,
  ),
  footer: context [
    #line(length: 100%, stroke: 0.5pt + dunkelblau)
    #grid(
      columns: (1fr, 1fr),
      [#bereich],
      align(right)[#veranstaltung · #counter(page).display()],
    )
  ],
)

#set text(
  lang: "de",
  font: "Calibri",
  size: 20pt,
  fill: textblau,
)


// ============================================================
// FOLIENBAUSTEINE
// ============================================================

#let folientitel(titel) = [
  #text(size: 28pt, weight: "bold")[#titel]
  #v(4mm)
  #line(length: 100%, stroke: 1pt + dunkelblau)
  #v(8mm)
]


// ============================================================
// TITELFOLIE
// ============================================================

#align(center + horizon)[
  #text(size: 38pt, weight: "bold")[#titel]

  #v(5mm)
  #text(size: 25pt)[#untertitel]

  #v(12mm)
  #autor

  #v(3mm)
  #datum
]


// ============================================================
// EINSTIEG
// ============================================================

#pagebreak()

#folientitel[Was Sie in den nächsten #minuten Minuten erwartet]

#grid(
  columns: (1.25fr, 1fr),
  gutter: 15mm,

  rect(
    width: 100%,
    height: 8cm,
    fill: hellblau,
    stroke: rahmenblau,
  )[
    #align(center + horizon)[Bild einfügen: name.png]
  ],

  [
    - #thema
    - Weiterer Punkt
    - Weiterer Punkt
    - Weiterer Punkt
  ],
)

#v(1fr)
#text(size: 12pt)[Quelle: quellen-angabe]


// ============================================================
// ZUSAMMENFASSUNG
// ============================================================

#pagebreak()

#folientitel[Zusammenfassung]

+ Kernaussage 1
+ Kernaussage 2
+ Kernaussage 3
+ Kernaussage 4
+ Kernaussage 5

#v(1fr)

#align(center)[
  #text(
    size: 28pt,
    weight: "bold",
    fill: rot,
  )[Key Message]
]
