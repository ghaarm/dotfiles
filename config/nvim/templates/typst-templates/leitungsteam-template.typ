// Gemeinsame Seitengestaltung für die Artikelvorlagen.
#let heute = datetime.today().display("[day].[month].[year]")

#let artikel(
  titel,
  fuss,
  inhalt,
  untertitel: none,
  datum: none,
  inhaltsverzeichnis: false,
  abbildungsverzeichnisse: false,
  zweispaltig: false,
  schrift: "Libertinus Serif",
  autor: [G. Haarmeyer],
  literatur: none,
) = {
  set page(
    paper: "a4",
    margin: (left: 1.5cm, right: 1.5cm, top: 1.8cm, bottom: 2cm),
    footer: context [
      #line(length: 100%, stroke: 0.4pt)
      #grid(
        columns: (1fr, 2fr),
        if inhaltsverzeichnis { link(<toc>)[Zurück zum Inhaltsverzeichnis] } else { [] },
        align(right)[#fuss, #autor, Stand: #heute, S. #counter(page).display()],
      )
    ],
  )
  set text(lang: "de", font: schrift, size: 11pt)
  set par(first-line-indent: 0pt, spacing: 1em)
  set heading(numbering: "1.")

  align(center)[
    #text(size: 18pt, weight: "bold")[#titel]
    #if untertitel != none { [\ #text(size: 12pt)[#untertitel]] }
    #if datum != none { [\ #datum] }
  ]
  v(8mm)

  if inhaltsverzeichnis {
    [#outline() <toc>]
    if abbildungsverzeichnisse {
      outline(title: [Tabellenverzeichnis], target: figure.where(kind: table))
      outline(title: [Abbildungsverzeichnis], target: figure.where(kind: image))
    }
    v(6mm)
  }

  if zweispaltig { columns(2, gutter: 8mm, inhalt) } else { inhalt }

  if literatur != none {
    v(12mm)
    bibliography(literatur, title: [Literatur])
  }
}


// Für Literaturangaben eine vorhandene .bib-Datei bei literatur: eintragen.
#artikel(
  [{{INPUT:TITLE}}],
  [{{MIRROR:TITLE}}],
  autor: [{{INPUT:AUTHOR}}],
  untertitel: [{{INPUT:SUBTITLE}}],
  datum: [#heute],
  schrift: "Calibri",
  inhaltsverzeichnis: true,
  zweispaltig: true,
  // literatur: "../research/literatur.bib",
)[
  = Kernpunkte

  - {{INPUT:KEY_POINT_1}}
  - {{INPUT:KEY_POINT_2}}
  - {{INPUT:KEY_POINT_3}}
  - {{INPUT:KEY_POINT_4}}

  = Anliegen und Begründung

  {{INPUT:OBJECTIVE}}

  {{INPUT:CURRENT_SITUATION}}

  {{INPUT:RATIONALE}}

  {{INPUT:OPTIONAL_CALCULATION_OR_LOCAL_CONTEXT}}

  = Gesetzliche Anforderungen, Evidenz und lokale Situation

  {{INPUT:LEGAL_REQUIREMENTS}}

  {{INPUT:EVIDENCE}}

  {{INPUT:LOCAL_SITUATION}}

  = Rahmenbedingungen

  - {{INPUT:FRAMEWORK_1}}
  - {{INPUT:FRAMEWORK_2}}
  - {{INPUT:FRAMEWORK_3}}
  - {{INPUT:FRAMEWORK_4}}
  - {{INPUT:FRAMEWORK_5}}

  = Praktischer Ablauf

  {{INPUT:PRACTICAL_WORKFLOW}}

  = Erwartbare Einwände

  - „{{INPUT:OBJECTION_1}}“ {{INPUT:RESPONSE_1}}
  - „{{INPUT:OBJECTION_2}}“ {{INPUT:RESPONSE_2}}
  - „{{INPUT:OBJECTION_3}}“ {{INPUT:RESPONSE_3}}

  = Vorschlag für das Leitungsteam

  {{INPUT:DECISION_PROPOSAL}}

  {{INPUT:OPTIONAL_FINAL_NOTE}}
]
