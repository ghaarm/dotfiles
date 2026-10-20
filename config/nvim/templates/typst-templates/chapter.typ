// Kapitelbaustein zu chapter.tex; book.typ ruft ihn auf.
// Die Standardwerte bewahren die Platzhalter des ursprünglichen Kapitels.
#let kapitel(
  titel: "{{INPUT:CHAPTER}}",
  kapitelinhalt: none,
  literaturdatei: "Zotero.bib",
  body: [{{INPUT:BEGINN}}],
) = [
  #heading(level: 1)[#titel]
  #if kapitelinhalt != none [
    *Inhalt dieses Kapitels*
    #kapitelinhalt
  ]
  #body
  #bibliography(literaturdatei, title: [Literatur für #titel], style: "chicago-author-date")
]
