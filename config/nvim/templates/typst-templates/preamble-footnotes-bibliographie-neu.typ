// Gegenstück zu preamble-footnotes-bibliographie-neu.tex.
// Im Hauptdokument mit #import und #show: praembel verwenden.

// BILDER UND PDFS
// #image("bild.png", width: 80%)
// #figure(image("bild.png", width: 80%), caption: [Beschriftung])
// #image("datei.pdf", page: 1, width: 100%)
// Querformat: #set page(flipped: true), anschließend #pagebreak().

// ANNOTIERTE BILDER: KNRed (#E62249) steht im TeX nur für diese Markierungen.
// Koordinaten 0 bis 1, Ursprung links unten wie in TikZ.
// Beispiel: #annotatedimage("bild.png", breite: 12cm, hoehe: 8cm,
//   markierungen: (imagecircle(0.5, 0.6, 0.08), imagelabel(0.7, 0.8, "Sensor")))
// Breite und Höhe bestimmen gemeinsam das Seitenverhältnis des Bildes.
#let _sx(x) = str(x * 1000)
#let _sy(y) = str((1 - y) * 1000)
#let _xml(wert) = str(wert).replace("&", "&amp;").replace("<", "&lt;")
  .replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&apos;")
#let imagecircle(x, y, radius) = (
  "<circle cx='" + _sx(x) + "' cy='" + _sy(y)
    + "' r='" + _sx(radius) + "' fill='none' stroke='#E62249' stroke-width='5'/>"
)
#let imagerect(x1, y1, x2, y2) = (
  "<rect x='" + _sx(calc.min(x1, x2))
    + "' y='" + _sy(calc.max(y1, y2)) + "' width='" + _sx(calc.abs(x2 - x1))
    + "' height='" + _sx(calc.abs(y2 - y1))
    + "' fill='none' stroke='#E62249' stroke-width='5'/>"
)
#let imagearrow(x1, y1, x2, y2) = (
  "<line x1='" + _sx(x1) + "' y1='" + _sy(y1)
    + "' x2='" + _sx(x2) + "' y2='" + _sy(y2)
    + "' stroke='#E62249' stroke-width='5' marker-end='url(#pfeil)'/>"
)
#let imagelabel(x, y, inhalt) = (
  "<text x='" + _sx(x) + "' y='" + _sy(y)
    + "' fill='#E62249' font-size='30' font-weight='bold' text-anchor='middle'"
    + " dominant-baseline='middle'>" + _xml(inhalt) + "</text>"
)
#let imagegrid() = {
  let linien = ""
  for i in range(1, 20) {
    let p = str(i * 50)
    let zahl = str(i / 20)
    linien += ("<path d='M" + p + " 0V1000 M0 " + p
      + "H1000' stroke='#999999' stroke-opacity='.35' stroke-width='1'/>")
    linien += ("<text x='" + p + "' y='990' fill='#777777' font-size='16'"
      + " text-anchor='middle'>" + zahl + "</text>")
    linien += ("<text x='2' y='" + str(1000 - i * 50)
      + "' fill='#777777' font-size='16'>" + zahl + "</text>")
  }
  linien
}
#let annotatedimage(pfad, breite: 15cm, hoehe: 8cm, markierungen: (), raster: false) = {
  let svg = ("<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 1000 1000'"
    + " preserveAspectRatio='none'><defs><marker id='pfeil' viewBox='0 0 10 10'"
    + " refX='9' refY='5' markerWidth='7' markerHeight='7' orient='auto'>"
    + "<path d='M0 0L10 5L0 10z' fill='#E62249'/></marker></defs>"
    + (if raster { imagegrid() } else { "" })
    + markierungen.join("") + "</svg>")
  block(width: breite, height: hoehe, clip: true, {
    place(top + left, image(pfad, width: breite, height: hoehe, fit: "stretch"))
    place(top + left, image(bytes(svg), format: "svg",
      width: breite, height: hoehe, fit: "stretch"))
  })
}

// DATUM, TEXT, MATHEMATIK UND CHEMIE
#let _monate = (
  "Januar", "Februar", "März", "April", "Mai", "Juni",
  "Juli", "August", "September", "Oktober", "November", "Dezember",
)
#let heute-deutsch() = {
  let tag = datetime.today()
  str(tag.day()) + ". " + _monate.at(tag.month() - 1) + " " + str(tag.year())
}
#let heute-iso() = datetime.today().display("[year]-[month]-[day]")
#let enquote(body) = [„#body“]
#let ignorieren(body) = []
#let wert-einheit(wert, einheit) = [#wert~#einheit]
// ≙ und $H_2 O$ können direkt eingegeben werden; Formeln fett: $bold(x)$.
// Unterstreichen, Streichen: #underline[Text], #strike[Text].
// Aufzählung ohne Zeichen: #list(marker: none)[...].

// TABELLEN UND TEXTBOXEN
// Tabellen: #table(columns: (1fr, 2fr), stroke: none, ...)
// Horizontale Regeln: #table.hline(stroke: 0.8pt).
#let tabelle-mit-anmerkung(tabelle, titel, anmerkung) = figure(
  [#tabelle #v(3pt) #text(size: 9pt, anmerkung)],
  caption: titel, kind: table,
)
#let hinweisbox(body) = block(
  width: 100%, fill: white, stroke: 0.6pt + black,
  inset: 8pt, radius: 3pt, body,
)
#let nicht-im-verzeichnis(titel, stufe: 3) = heading(
  level: stufe, outlined: false, titel,
)

// LITERATUR UND FUSSNOTEN
// Die Hauptvorlage setzt den Pfad zu Zotero.bib und den CSL-Stil direkt.
#let url(adresse) = text(fill: blue, link(adresse))
// Fußnote: #footnote[Text]. Für Tabellen mit Anmerkungen #figure(...) nutzen.

// SATZSPIEGEL: A4, 18 × 25,5 cm, deutsche Silbentrennung, linksbündige Captions.
#let praembel(body) = {
  set page(
    paper: "a4",
    margin: (left: 1.5cm, right: 1.5cm,
      top: (29.7cm - 25.5cm) / 2, bottom: (29.7cm - 25.5cm) / 2),
  )
  set text(font: "New Computer Modern", size: 11pt, lang: "de")
  set par(first-line-indent: 0pt, spacing: 0.65em, justify: true)
  set heading(numbering: "1.1.1")
  show link: it => text(
    fill: if type(it.dest) == str { blue } else { rgb("a32121") }, it,
  )
  show figure.caption: it => block(width: 100%, align(left, it))
  body
}
