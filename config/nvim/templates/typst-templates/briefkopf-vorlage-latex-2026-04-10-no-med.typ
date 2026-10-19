#let heute = datetime.today().display("[day].[month].[year]")

#let brief(absender, empfaenger, strasse, stadt, betreff, name, inhalt) = {
  set page(
    paper: "a4",
    margin: (left: 25mm, right: 25mm, top: 25mm, bottom: 25mm),
    foreground: [
      // Falzmarken, gemessen vom oberen Papierrand.
      #place(top + left, dx: 0mm, dy: 105mm)[#line(length: 5mm, stroke: 0.2pt)]
      #place(top + left, dx: 205mm, dy: 105mm)[#line(length: 5mm, stroke: 0.2pt)]
      #place(top + left, dx: 0mm, dy: 210mm)[#line(length: 5mm, stroke: 0.2pt)]
      #place(top + left, dx: 205mm, dy: 210mm)[#line(length: 5mm, stroke: 0.2pt)]
    ],
  )
  set text(lang: "de", font: "Libertinus Serif", size: 11pt)
  set par(first-line-indent: 0pt, spacing: 0.8em)

  place(top + left, dx: 115mm, dy: 0mm)[
    #block(width: 65mm)[
      #text(size: 7pt)[
        #absender\
        #v(3mm)
        Blütenstrasse 22\
        90480 Nürnberg\
        Tel.: 0911 - 1332 6377\
        Mobil: 0176 - 22 66 04 06\
        E-Mail: golo-sung.haarmeyer\@gmx.de
      ]
    ]
  ]

  place(top + left, dx: 0mm, dy: 40mm)[
    #block(width: 80mm)[
      #text(size: 7pt)[
        #absender\
        Blütenstrasse 22 · 90480 Nürnberg
      ]
      #line(length: 100%, stroke: 0.4pt)
      #v(3mm)
      #empfaenger\
      #strasse\
      #stadt
    ]
  ]

  v(68mm)
  align(right)[Nürnberg, #heute]
  v(5mm)

  strong[Betreff: #betreff]
  v(5mm)

  [Guten Tag #name,]
  parbreak()

  inhalt

  v(10mm)
  [Mit freundlichen Grüßen]
  parbreak()

  v(18mm)
  // Signaturgrafik bei Bedarf ergänzen: #image("signatur.png", width: 35mm)
  absender
}


#brief(
  [Golo-Sung Haarmeyer],
  [{{INPUT:EMPFÄNGER}}],
  [{{INPUT:STRASSE}}],
  [{{INPUT:STADT}}],
  [{{INPUT:BETREFF}}],
  [{{INPUT:NAME}}],
)[
  {{INPUT:TEXT}}
]
