// ============================================================
// DOKUMENTINFORMATIONEN
// ============================================================
//
// Typst-Version bei Erstellung: 0.15.1
//
// Versionshistorie:
// - 2026-10-11 | Typst 0.15.1 | Vorlage erstellt
// - 2026-10-21 | Typst 0.15.1 | Standard-Folienmodell in Präambel ausgelagert
// - 2026-10-22 | Typst 0.15.1 | Umstellung auf direkte Touying-Folien
//
// Aktuelle Version prüfen: typst --version
// Die Versionsangabe ist Dokumentation, keine Versionsbindung.


// ============================================================
// PRÄAMBEL UND TOUYING
// ============================================================

#import "/Users/g/Library/Mobile Documents/com~apple~CloudDocs/!Docs iCloud/typst-icloud/1-vorlagen-typst-touying/kn-touying-preamble.typ": kn-vorlage, kn-titelfolie, pause

#import "/Users/g/Library/Mobile Documents/com~apple~CloudDocs/!Docs iCloud/typst-icloud/1-vorlagen-typst-touying/_kn-bausteine.typ": quelle, kn-rot

// Touying-Funktionen für Einblendungen und Hervorhebungen.
#import "@preview/touying:0.8.0": slide, pause, uncover, alert, item-by-item

// KN-Bausteine bei Bedarf direkt importieren.
#import "/Users/g/Library/Mobile Documents/com~apple~CloudDocs/!Docs iCloud/typst-icloud/1-vorlagen-typst-touying/_kn-bausteine.typ": quelle, kn-merksatz


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
// PRÄSENTATIONSDATEN
// ============================================================

#let titel = "{{INPUT:TITLE}}"
#let untertitel = "{{INPUT:SUBTITLE}}"
#let autor = [G. Haarmeyer]
#let datum = "{{INPUT:DATE}}"
#let bereich = "{{INPUT:FOOTER}}"
#let veranstaltung = "{{INPUT:EVENT}}"


// ============================================================
// PRÄSENTATION
// ============================================================

#show: kn-vorlage.with(
  titel: titel,
  untertitel: untertitel,
  autor: autor,
  datum: datum,
  bereich: bereich,
  rechts: veranstaltung,
  handout: sys.inputs.at("handout", default: "false") == "true",
  transparent: sys.inputs.at("transparent", default: "false") == "true",
)


// ============================================================
// TITELFOLIE
// ============================================================

#kn-titelfolie()


// ============================================================
// FOLIEN
// ============================================================

// 01 – Einstieg
#slide(title: [Einführung])[
  #item-by-item[
    - Erster Punkt
    - Zweiter Punkt
    - Dritter Punkt
    - Vierter Punkt
  ]
]


// 02 – Folie mit nummerierter Liste
#slide(title: [Vorgehen])[
  + Erster Schritt
  + Zweiter Schritt
  + Dritter Schritt
]


// 03 – Folie mit Bild
#slide(title: [Abbildung])[
  #grid(
    columns: (57%, 39%),
    gutter: 4%,
    [
      - Erster Punkt
      - Zweiter Punkt
    ],
    [
      #image("bilder/beispiel.png", width: 100%)
    ],
  )

  #kn-quelle[Quellenangabe]
]


// ============================================================
// ZUSAMMENFASSUNG
// ============================================================

#slide(title: [Zusammenfassung])[
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
  #align(center)[
    #text(size: 25pt, weight: "regular")[
      #alert[Key Message]
    ]
  ]
]


// ============================================================
// Danke und versteckte Bibliografie
// ============================================================

// 56 – Abschluss
#slide(title: text(size: 22pt, weight: "regular", [Vielen Dank für die Aufmerksamkeit!]))[
  #set text(size: 18pt)
  #place(top + left, dx: 60mm, dy: 0mm, rotate(0deg, reflow: false, 
  image(bildpfad + "{{INPUT:BILD ABSCHLUSS}}",

  width: 180mm, height: 100mm, fit: "contain")))
  #place(top + left, dx: 0mm, dy: 102mm, box(width: 275mm, height: 18mm)[
    #align(center)[
      #v(1em)

    golo-sung.haarmeyer\@klinikum-nuernberg.de

  ]
  ])

  #hide(
    bibliography(
      "/Users/g/Library/texmf/bibtex/bib/Zotero.bib",
      style: "/Users/g/Library/Mobile Documents/com~apple~CloudDocs/!Docs iCloud/typst-icloud/1-vorlagen-typst-touying/touying-cite.csl",
      full: false,
    )
  )

  #quelle([Quelle: #link("{{INPUT:QUELLE ABSCHLUSS}}") (Stand {{INPUT:DATUM QUELLE ABSCHLUSS}})])
]

