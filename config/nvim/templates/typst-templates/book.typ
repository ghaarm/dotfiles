#set page(paper: "a4", margin: 2.5cm)
#set text(lang: "de", font: "Libertinus Serif", size: 11pt)
#set heading(numbering: "1.")

#align(center)[
  #v(5cm)
  #text(size: 24pt, weight: "bold")[{{INPUT:TITLE}}]
  #v(1cm)
  G. Haarmeyer
  #v(5mm)
  #datetime.today().display("[day].[month].[year]")
]

#pagebreak()
#outline(title: [Inhaltsverzeichnis])
#pagebreak()

// Weiteres Kapitelmuster: chapter.typ
= {{INPUT:CHAPTER}}

#outline(title: [In diesem Kapitel], target: heading.where(level: 2))

{{INPUT:BEGINN}}

== Name

// Für Zitate eine .bib-Datei am Dokumentende mit #bibliography("literatur.bib") einbinden.
