// Eigenständiges Hauptdokument zu übergabeprotokoll.tex.
#let datum = "replace-date"
#let mieter = "{{INPUT:MIETER}}"
#set page(
  paper: "a4",
  margin: (left: 1.5cm, right: 1.5cm, top: 1.85cm, bottom: 1.85cm),
  footer: context [
    Übergabeprotokoll „An der Krücke 36“ 1. OG links, G. Haarmeyer, Stand: 07/2024
    #h(1fr)
    #datum, S. #counter(page).display()
  ],
)
#set text(font: "New Computer Modern", size: 11pt, lang: "de")
#set par(first-line-indent: 0pt, spacing: 0.65em)
#set heading(numbering: "1.")

#align(center)[
  #text(size: 17pt, weight: "bold")[Übergabeprotokoll]
  #parbreak()
  #text(size: 12pt, "- bei Einzug -")
  #parbreak()
  #datum
]
#v(1em)

Zwischen

Golo-Sung Haarmeyer \
Blütenstraße 22 \
90480 Nürnberg

#align(right, text("- folgend Vermieter genannt -"))

und

#mieter \
geboren am: {{INPUT:GEBURTSDATUM}} \
derzeitiger Wohnsitz: {{INPUT:WOHNSITZ}}

#align(right, text("- folgend Mieter:in genannt -"))
#v(1cm)
*Objekt: Mietwohnung 1. OG links in „An der Krücke 36“*

Hiermit bestätige ich, dass mir die Mieträume, entsprechend § 8 des Mietvertrages vom replace-vertrag, übergeben wurden.

= Zählerstände <sec-zaehlerstaende>
#table(
  columns: (1fr, 30mm, 30mm),
  stroke: 0.4pt,
  [Ort], [Zählerstand], [Zählernummer],
  [Küche (Wasser, m³)], [Zelle], [2 412 501],
  [Bad (Wasser, m³)], [Zelle], [2 412 499],
  [Waschkeller (Wasser, m³, 3. Anschluss von links)], [Zelle], [08 358 847],
  [Gas (m³)], [Zelle], [162 832],
  [Strom (kW/h)], [Zelle], [457 024],
)

= Schlüssel <sec-schluessel>
Folgende Schlüssel wurden ausgehändigt:

#table(
  columns: (1fr, 30mm),
  stroke: 0.4pt,
  [Beschreibung], [Anzahl],
  [Wohnungstür], [2],
  [Briefkasten], [2],
  [Haustür], [2],
  [Haushintertür], [2],
  [Schloss Keller], [2],
)

= Bemerkungen <sec-bemerkungen>
+ {{INPUT:BEMERKUNG_1}}
+ {{INPUT:BEMERKUNG_2}}
+ {{INPUT:BEMERKUNG_3}}
+ {{INPUT:BEMERKUNG_4}}

#v(3cm)
Bielefeld, #datum

#line(length: 5cm, stroke: 0.3mm) \
Ort, Datum

#v(1.5cm)
#grid(
  columns: (1fr, 1fr),
  gutter: 15mm,
  [Unterschrift #v(2cm) #line(length: 5cm, stroke: 0.2mm) \ Mieter:in],
  [Unterschrift #v(2cm) #line(length: 5cm, stroke: 0.2mm) \ Vermieter],
)
