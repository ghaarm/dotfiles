// ============================================================
// DOKUMENTINFORMATIONEN
// ============================================================
//
// Typst-Version bei Erstellung: 0.15.1
//
// Versionshistorie:
// - 2026-10-11 | Typst 0.15.1 | Vorlage erstellt
// - 2026-10-21 | Typst 0.15.1 | Standard-Folienmodell in Präambel ausgelagert
//
// Aktuelle Version prüfen: typst --version
// Die Versionsangabe ist Dokumentation, keine Versionsbindung.


// ============================================================
// PRÄAMBEL UND TOUYING
// ============================================================

#import "/Users/g/Library/Mobile Documents/com~apple~CloudDocs/!Docs iCloud/typst-icloud/1-vorlagen-typst-touying/kn-touying-preamble.typ": kn-vorlage, kn-folie, kn-titelfolie, folie, inhaltsfolie

// Touying-Funktionen für Sonderfolien.
#import "@preview/touying:0.8.0": pause, uncover, alert


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
#let minuten = "{{INPUT:MINUTEN}}"
#let thema = "{{INPUT:THEMA}}"

// Projektbezogener Bildordner.
// Beispiel: "bilder/" oder "ernaehrung-png/"
// Leer lassen, wenn die Bilder neben der .typ-Datei liegen.
#let bildpfad = "{{INPUT:ORDNER MIT BILDERN}}"

#let bild(name) = image(
  bildpfad + name,
  width: 100%,
  height: 100%,
  fit: "contain",

)// ============================================================
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
  transparent: sys.inputs.at("transparent", default: "false") == "true",)

  // ============================================================
  // TITELFOLIE
  // ============================================================

  #kn-titelfolie()


  // ============================================================
  // FOLIEN
  // ============================================================

  #let folien = (

    // 01 – Einstieg
    folie(
      [Was Sie in den nächsten #minuten Minuten erwartet],
      punkte: (
        [#thema],
        [Zweiter Punkt],
        [Dritter Punkt],
        [Vierter Punkt],
      ),
    ),

    // Weitere Folien hier einfügen.

  )


  // ============================================================
  // FOLIEN AUSGEBEN
  // ============================================================

  #for f in folien {
    inhaltsfolie(f, bild: bild)
  }


  // ============================================================
  // ZUSAMMENFASSUNG
  // ============================================================

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
    #align(center)[
      #text(size: 25pt, weight: "regular")[
        #alert[Key Message]
      ]
    ]
  ]
