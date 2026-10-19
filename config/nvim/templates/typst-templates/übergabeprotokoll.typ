#let datum = [{{INPUT:DATUM}}]
#let mieter = [{{INPUT:MIETER}}]

#set page(
  paper: "a4",
  margin: (left: 1.5cm, right: 1.5cm, top: 1.4cm, bottom: 1.6cm),
  footer: context [
    #line(length: 100%, stroke: 0.4pt)
    #grid(
      columns: (2fr, 1fr),
      [Übergabeprotokoll „An der Krücke 36“, 1. OG links · G. Haarmeyer],
      align(right)[#datum · S. #counter(page).display()],
    )
  ],
)
#set text(lang: "de", font: "Libertinus Serif", size: 10pt)
#set par(first-line-indent: 0pt, spacing: 0.35em)
#set heading(numbering: none)

#align(center)[
  #text(size: 18pt, weight: "bold")[Übergabeprotokoll]
  #v(2mm)
  #text(size: 12pt)[– bei Einzug –]
]

#v(4mm)
Zwischen

Golo-Sung Haarmeyer\
Blütenstraße 22\
90480 Nürnberg

#align(right)[– im Folgenden Vermieter genannt –]

und

#mieter\
geboren am: {{INPUT:GEBURTSDATUM}}\
derzeitiger Wohnsitz: {{INPUT:WOHNSITZ}}

#align(right)[– im Folgenden Mieter:in genannt –]

#v(4mm)
*Objekt: Mietwohnung 1. OG links in „An der Krücke 36“*

Hiermit bestätige ich, dass mir die Mieträume entsprechend § 8 des Mietvertrages vom {{INPUT:VERTRAGSDATUM}} übergeben wurden.

= Zählerstände

#table(
  columns: (1.8fr, 1.5fr, 1fr),
  stroke: 0.5pt,
  inset: 3pt,
  [Ort], [Zählerstand], [Zählernummer],
  [Küche (Wasser, m³)], text(size: 8pt)[{{INPUT:KUECHE_WASSER}}], [2 412 501],
  [Bad (Wasser, m³)], text(size: 8pt)[{{INPUT:BAD_WASSER}}], [2 412 499],
  [Waschkeller (Wasser, m³, 3. Anschluss von links)], text(size: 8pt)[{{INPUT:WASCHKELLER_WASSER}}], [08 358 847],
  [Gas (m³)], text(size: 8pt)[{{INPUT:GAS}}], [162 832],
  [Strom (kWh)], text(size: 8pt)[{{INPUT:STROM}}], [457 024],
)

= Schlüssel

Folgende Schlüssel wurden ausgehändigt:

#table(
  columns: (1.1fr, 1fr),
  stroke: 0.5pt,
  inset: 3pt,
  [Beschreibung], [Anzahl],
  [Wohnungstür], text(size: 8pt)[{{INPUT:SCHLUESSEL_WOHNUNG}}],
  [Briefkasten], text(size: 8pt)[{{INPUT:SCHLUESSEL_BRIEFKASTEN}}],
  [Haustür], text(size: 8pt)[{{INPUT:SCHLUESSEL_HAUS}}],
  [Haushintertür], text(size: 8pt)[{{INPUT:SCHLUESSEL_HINTERTUER}}],
  [Schloss Keller], text(size: 8pt)[{{INPUT:SCHLUESSEL_KELLER}}],
)

= Bemerkungen

1. {{INPUT:BEMERKUNG_1}}
2. {{INPUT:BEMERKUNG_2}}
3. {{INPUT:BEMERKUNG_3}}
4. {{INPUT:BEMERKUNG_4}}

#v(5mm)
Bielefeld, #datum

#v(5mm)
#grid(
  columns: (1fr, 1fr),
  gutter: 12mm,
  [
    #line(length: 7cm, stroke: 0.3pt)
    Ort, Datum
  ],
  [],
)

#v(8mm)
#grid(
  columns: (1fr, 1fr),
  gutter: 12mm,
  [
    #line(length: 7cm, stroke: 0.3pt)
    Unterschrift Mieter:in
  ],
  [
    #line(length: 7cm, stroke: 0.3pt)
    Unterschrift Vermieter
  ],
)


