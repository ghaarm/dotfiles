// Eigenständige Typst-Präsentation im 16:9-Format.
#set page(
  width: 33.867cm,
  height: 19.05cm,
  margin: (left: 2cm, right: 2cm, top: 1.5cm, bottom: 1.4cm),
  footer: context [
    #line(length: 100%, stroke: 0.5pt + rgb("214b72"))
    #grid(
      columns: (1fr, 1fr),
      [{{INPUT:FOOTER}}],
      align(right)[{{INPUT:EVENT}} · #counter(page).display()],
    )
  ],
)
#set text(lang: "de", font: "Calibri", size: 20pt, fill: rgb("173a5c"))

#let folientitel(titel) = [
  #text(size: 28pt, weight: "bold")[#titel]
  #v(4mm)
  #line(length: 100%, stroke: 1pt + rgb("214b72"))
  #v(8mm)
]

#align(center + horizon)[
  #text(size: 38pt, weight: "bold")[{{INPUT:TITLE}}]
  #v(5mm)
  #text(size: 25pt)[{{INPUT:SUBTITLE}}]
  #v(12mm)
  G. Haarmeyer
  #v(3mm)
  {{INPUT:DATE}}
]

#pagebreak()
#folientitel[Was Sie in den nächsten {{INPUT:MINUTEN}} erwartet]
#grid(
  columns: (1.25fr, 1fr),
  gutter: 15mm,
  rect(width: 100%, height: 8cm, fill: rgb("eef3f7"), stroke: rgb("bccbd8"))[
    #align(center + horizon)[Bild einfügen: name.png]
  ],
  [
    - {{INPUT:THEMA}}
    - Weiterer Punkt
    - Weiterer Punkt
    - Weiterer Punkt
  ],
)
#v(1fr)
#text(size: 12pt)[Quelle: quellen-angabe]

#pagebreak()
#folientitel[Zusammenfassung]
+ Kernaussage 1
+ Kernaussage 2
+ Kernaussage 3
+ Kernaussage 4
+ Kernaussage 5

#v(1fr)
#align(center)[#text(size: 28pt, weight: "bold", fill: rgb("b02b2b"))[Key Message]]
