// Gegenstück zu preamble-book.tex: gemeinsame Regeln für Buchdokumente.
// Im Hauptdokument: #import "preamble-book.typ": praembel, literatur, ...
//                  #show: praembel

// GRAPHIKEN, PDFS UND QUERFORMAT
#let bild(pfad, breite: 100%, beschriftung: none) = {
  let grafik = image(pfad, width: breite)
  if beschriftung == none { grafik }
  else { figure(grafik, caption: beschriftung) }
}
#let pdfseite(pfad, seite: 1, breite: 100%) = image(pfad, page: seite, width: breite)
// Ein neues Querformat-Kapitel kann im Hauptdokument mit #set page(flipped: true)
// vor einem Seitenumbruch beginnen; anschließend flipped: false setzen.

// TEXT UND MATHEMATIK
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
#let zweispaltig(body) = columns(2, gutter: 7mm, body)
// Typst setzt Formeln direkt mit $...$ und Fußnoten mit #footnote[...].
// Textformatierungen: #underline[...], #strike[...], #emph[...].

// VERZEICHNISSE
#let inhaltsverzeichnis() = outline(title: "Inhaltsverzeichnis")
#let tabellenverzeichnis() = outline(
  target: figure.where(kind: table), title: "Tabellenverzeichnis",
)
#let abbildungsverzeichnis() = outline(
  target: figure.where(kind: image), title: "Abbildungsverzeichnis",
)

// LITERATUR UND LINKS
#let literatur(datei: "Zotero.bib") = bibliography(
  datei, title: [Literatur], style: "chicago-author-date",
)
#let url(adresse) = text(fill: blue, link(adresse))

// SATZSPIEGEL UND KAPITEL: 18 × 26 cm, deutsche Bezeichnungen.
#let praembel(body) = {
  set page(
    paper: "a4",
    margin: (left: 1.5cm, right: 1.5cm,
      top: (29.7cm - 26cm) / 2, bottom: (29.7cm - 26cm) / 2),
  )
  set text(font: "New Computer Modern", size: 11pt, lang: "de")
  set par(first-line-indent: 0pt, spacing: 0.65em, justify: true)
  set heading(numbering: "1.1.1")
  show heading.where(level: 1): set block(above: 1.25em, below: 0.65em)
  show link: it => text(
    fill: if type(it.dest) == str { blue } else { rgb("a32121") }, it,
  )
  body
}
