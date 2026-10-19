// KN-Beamer-Vorlage als Typst/Touying-Dokument.
// Aus dem Projektordner bauen: typst compile --root / touying-typst/vorlage-template.typ
// Die Platzhalter {{INPUT:...}} entsprechen denen in vorlage-tex.tex.

// Aktuelle KN-Präambel und Quellenbaustein einbinden.
#import "/Users/g/Library/Mobile Documents/com~apple~CloudDocs/!Docs iCloud/typst-icloud/1-vorlagen-typst-touying/kn-beamer-preamble.typ": kn-vorlage, kn-folie, kn-titelfolie
#import "/Users/g/Library/Mobile Documents/com~apple~CloudDocs/!Docs iCloud/typst-icloud/1-vorlagen-typst-touying/_kn-bausteine.typ": kn-quelle, kn-dunkelblau
#import "@preview/touying:0.8.0": pause, uncover, alert

// Titel, Autor und Footer: Hier die Platzhalter durch eigene Angaben ersetzen.
#let titel = "{{INPUT:TITLE}}"
#let untertitel = "{{INPUT:SUBTITLE}}"
#let autor = [G. Haarmeyer]
#let datum = "{{INPUT:DATE}}"
#let bereich = "{{INPUT:FOOTER}}"
#let veranstaltung = "{{INPUT:EVENT}}"
#let minuten = "{{INPUT:MINUTEN}}"
#let thema = "{{INPUT:THEMA}}"

// Die Präambel setzt 16:9, KN-Farben, Fira Sans und den Footer.
// Für ein Handout handout: true ergänzen; dann bleibt nur die letzte
// Einblendung jeder Folie übrig.
#show: kn-vorlage.with(
  titel: titel,
  untertitel: untertitel,
  autor: autor,
  datum: datum,
  bereich: bereich,
  rechts: veranstaltung,
)

// Titelfolie: Die KN-Präambel blendet hier den Footer aus.
#kn-titelfolie()

// Einstiegsfolie wie in der TeX-Vorlage: links ein Bild, rechts vier Punkte.
// Den Bildplatzhalter durch #image("name.png", width: 100%) ersetzen, sobald
// die Bilddatei neben dieser .typ-Datei liegt.
#kn-folie(title: [Was Sie in den nächsten #minuten Minuten erwartet])[
  #grid(
    columns: (54%, 42%),
    gutter: 4%,
    align: top,
    rect(
      width: 100%,
      height: 70mm,
      fill: rgb("#f7f7f7"),
      stroke: 0.7pt + kn-dunkelblau,
      align(center + horizon)[Bild: name.png],
    ),
    [
      - #thema
      #pause
      - Zweiter Punkt
      #pause
      - Dritter Punkt
      #pause
      - Vierter Punkt
    ],
  )
  // Quellenangabe am unteren Rand der Folie.
  #uncover("1-")[#kn-quelle[Quellenangabe]]
]

// Zusammenfassung: Jeder Punkt erscheint auf einer weiteren Einblendung.
// Der Merksatz erscheint wie in Beamer erst nach dem fünften Punkt.
#kn-folie(title: [Zusammenfassung])[
  + Erster Punkt
  #pause
  + Zweiter Punkt
  #pause
  + Dritter Punkt
  #pause
  + Vierter Punkt
  #pause
  + Fünfter Punkt

  #v(1fr)
  #pause
  #align(center)[#text(size: 25pt, weight: "regular")[#alert[Key Message]]]
]

