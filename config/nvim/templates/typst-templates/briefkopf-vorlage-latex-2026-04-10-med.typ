// Eigenständige Briefvorlage: Angaben und Layout direkt hier bearbeiten.
#let name = "Dr. med. Golo-Sung Haarmeyer, MHBA"
#let absender = "Blütenstrasse 22 · 90480 Nürnberg"
#let empfaenger = [{{INPUT:EMPFÄNGER}} \ {{INPUT:STRASSE}} \ {{INPUT:STADT}}]
#let betreff = "{{INPUT:BETREFF}}"
#set page(paper: "a4", margin: (left: 25mm, right: 25mm, top: 25mm, bottom: 25mm))
#set text(font: "New Computer Modern", size: 11pt, lang: "de")
#set par(first-line-indent: 0pt, spacing: 0.8em)

#for y in (105mm, 210mm) {
  place(top + left, dx: -25mm, dy: y - 25mm, line(length: 5mm, stroke: 0.2pt))
  place(top + right, dx: 25mm, dy: y - 25mm, line(length: 5mm, stroke: 0.2pt))
}
// Briefkopf und Fensterumschlag-Adressfeld.
#place(top + left, dx: 115mm, dy: 0mm, block(width: 55mm)[
  #text(size: 6pt)[
    #name \
    #v(3mm)
    Blütenstrasse 22 \
    90480 Nürnberg \
    Tel.: 0911 - 1332 6377 \
    Mobil: 0176 - 22 66 04 06 \
    E-Mail: golo-sung.haarmeyer\@gmx.de
  ]
])
#place(top + left, dx: 0mm, dy: 40mm, block(width: 80mm)[
  #text(size: 6.5pt)[#name \ #absender]
  #line(length: 80mm, stroke: 0.4pt)
  #v(4mm)
  #empfaenger
])

#v(65mm)
#align(right)[Nürnberg, #datetime.today().display("[day].[month].[year]")]
#v(5mm)
*Betreff: #betreff*
#v(5mm)

Sehr geehrte Damen und Herren,
Sehr geehrter Herr {{INPUT:NAME}},
Sehr geehrte Frau {{MIRROR:NAME}},

{{INPUT:TEXT}}

#v(10mm)
Mit freundlichen Grüßen
#v(2mm)
#image("signature_latex.png", width: 45mm)
#v(8mm)
#name
