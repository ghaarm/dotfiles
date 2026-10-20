// Hauptdokument zu article-template-toc.tex: Titel, Fußzeile und Text hier bearbeiten.
#let titel = "{{INPUT:TITLE}}"
#let fusszeile = "{{INPUT:FOOTER}}, G. Haarmeyer"
#set page(
  paper: "a4",
  margin: (left: 1.5cm, right: 1.5cm, top: 1.85cm, bottom: 1.85cm),
  footer: context {
    line(length: 100%, stroke: 0.4pt)
    v(2pt)
    link(<inhaltsverzeichnis>)[Zurück zum Inhaltsverzeichnis]
    h(1fr)
    [#fusszeile, Stand: #datetime.today().display("[day].[month].[year]"), S. #counter(page).display()]
  },
)
#set text(font: "New Computer Modern", size: 11pt, lang: "de")
#set par(first-line-indent: 0pt, spacing: 0.65em, justify: true)
#set heading(numbering: "1.1.1")
#show heading.where(level: 1): set block(above: 2.5em, below: 1.3em)
#show link: set text(fill: rgb("a32121"))

#align(center)[
  #text(size: 17pt, weight: "bold", titel)

]
#v(1em)

#outline(title: "Inhaltsverzeichnis") <inhaltsverzeichnis>
#outline(target: figure.where(kind: table), title: "Tabellenverzeichnis")
#outline(target: figure.where(kind: image), title: "Abbildungsverzeichnis")

{{INPUT:BEGINN}}
