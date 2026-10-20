// Hauptdokument zu leitungsteam-template.tex.
#import "preamble-footnotes-bibliographie-neu.typ": praembel, heute-deutsch, inhaltsverzeichnis, literatur, zweispaltig
#show: praembel
// \titlespacing aus dem TeX-Hauptdokument, nicht aus der Präambel.
#show heading.where(level: 1): set block(above: 1.25em, below: 0.65em)

#let titel = "{{INPUT:TITLE}}"
#let untertitel = "{{INPUT:SUBTITLE}}"
#let autor = "{{INPUT:AUTHOR}}"
#set text(font: "Calibri")
#set page(footer: context {
  line(length: 100%, stroke: 0.4pt)
  v(2pt)
  h(1fr)
  [#titel, #autor, Stand: #datetime.today().display("[day].[month].[year]"), S. #counter(page).display()]
})

#align(center)[
  #text(size: 17pt, weight: "bold", titel)
  #parbreak()
  #text(size: 12pt, untertitel)
  #parbreak()
  #heute-deutsch()
]
#v(1em)
#inhaltsverzeichnis()

#zweispaltig[
= Kernpunkte <sec-kernpunkte>
- {{INPUT:KEY_POINT_1}}
- {{INPUT:KEY_POINT_2}}
- {{INPUT:KEY_POINT_3}}
- {{INPUT:KEY_POINT_4}}

= Anliegen und Begründung <sec-anliegen>
{{INPUT:OBJECTIVE}}

{{INPUT:CURRENT_SITUATION}}

{{INPUT:RATIONALE}}

{{INPUT:OPTIONAL_CALCULATION_OR_LOCAL_CONTEXT}}

= Gesetzliche Anforderungen, Evidenz und lokale Situation <sec-evidenz>
{{INPUT:LEGAL_REQUIREMENTS}}

{{INPUT:EVIDENCE}}

{{INPUT:LOCAL_SITUATION}}

= Rahmenbedingungen <sec-rahmenbedingungen>
- {{INPUT:FRAMEWORK_1}}
- {{INPUT:FRAMEWORK_2}}
- {{INPUT:FRAMEWORK_3}}
- {{INPUT:FRAMEWORK_4}}
- {{INPUT:FRAMEWORK_5}}

= Praktischer Ablauf <sec-ablauf>
{{INPUT:PRACTICAL_WORKFLOW}}

= Erwartbare Einwände <sec-einwaende>
- „{{INPUT:OBJECTION_1}}“ {{INPUT:RESPONSE_1}}
- „{{INPUT:OBJECTION_2}}“ {{INPUT:RESPONSE_2}}
- „{{INPUT:OBJECTION_3}}“ {{INPUT:RESPONSE_3}}

= Vorschlag für das Leitungsteam <sec-vorschlag>
{{INPUT:DECISION_PROPOSAL}}

{{INPUT:OPTIONAL_FINAL_NOTE}}
]

#v(2mm)
#literatur()
