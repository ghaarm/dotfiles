// Hauptdokument zu book.tex. Weitere Kapitel mit #kapitel ergänzen.
#import "/Users/g/Library/Mobile Documents/com~apple~CloudDocs/!Docs iCloud/typst-icloud/1-vorlagen-typst/preamble-book.typ": praembel, inhaltsverzeichnis
#import "chapter.typ": kapitel
#show: praembel

#let titel = "{{INPUT:TITLE}}"
#align(center)[
  #text(size: 24pt, weight: "bold", titel)
  #parbreak()
  G. Haarmeyer
  #parbreak()
  #datetime.today().display("[day].[month].[year]")
]
#pagebreak()
#inhaltsverzeichnis()
#pagebreak()

#kapitel(titel: "Kapitel 1", kapitelinhalt: [Name], body: [
  {{INPUT:BEGINN}}
  == Name
  Hier beginnt das erste Kapitel.
])
#pagebreak()
#kapitel(titel: "Kapitel 2", kapitelinhalt: [Weiteres Thema], body: [
  Hier beginnt das zweite Kapitel.
])

