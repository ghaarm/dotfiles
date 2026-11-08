// ============================================================
// DOKUMENTINFORMATIONEN
// ============================================================
//
// Typst-Version bei Erstellung: 0.15.1
//
// Versionshistorie:
// - 2026-09-07 | Typst 0.15.1 | Präsentation erstellt
// - 2026-10-21 | Typst 0.15.1 | Auf zentrale KN-Touying-Präambel umgestellt
//
// Aktuelle Version prüfen: typst --version
// Die Versionsangabe ist Dokumentation, keine Versionsbindung.


// ============================================================
// PRÄAMBEL UND TOUYING
// ============================================================

// KN-Präambel
#import "/Users/g/Library/Mobile Documents/com~apple~CloudDocs/!Docs iCloud/typst-icloud/1-vorlagen-typst-touying/kn-touying-preamble.typ": *

// KN-Bausteine einschließlich Farben
#import "/Users/g/Library/Mobile Documents/com~apple~CloudDocs/!Docs iCloud/typst-icloud/1-vorlagen-typst-touying/_kn-bausteine.typ": *

// Touying
#import "@preview/touying:0.8.0": *
#import themes.metropolis: slide

// ============================================================
// OPTIONALE PAKETE
// ============================================================
//
// Nur Pakete aktivieren, die diese Präsentation tatsächlich benötigt.
//
// Grafiken und technische Zeichnungen (CeTZ)
// #import "@preview/cetz:0.5.2": canvas, draw

// Flussdiagramme und Entscheidungsbäume (Fletcher)
// #import "@preview/fletcher:VERSION": diagram, node, edge

// Wissenschaftliche Plots und Datenvisualisierung (Lilaq)
// #import "@preview/lilaq:VERSION": *

// Abkürzungs- und Glossarverwaltung (Glossarium)
// #import "@preview/glossarium:VERSION": *

// SI-Einheiten und Zahlenformatierung (Unify)
// #import "@preview/unify:VERSION": *

// Formatierte Codeblöcke (Codly)
// #import "@preview/codly:VERSION": *

// Zeitachsen (Timeliney)
// #import "@preview/timeliney:VERSION": *


// ============================================================
// PRÄSENTATIONSDATEN
// ============================================================

// #let titel = [Atmungstherapie 2026]
// #let titel = [Intensivpflege 2026]
#let titel = [Fortbildungszirkel 2026]
#let untertitel = [Du bist was Du isst - Ernährung auf der Intensivstation]
#let autor = [G. Haarmeyer]
#let datum = [09.11.2026]
#let bereich = [Pneumologie / Intensivmedizin / Ernährung ICU]
#let veranstaltung = [ITS 2026]

// Bildordner dieser Präsentation.
#let bildpfad = "ernaehrung-png/"
#let kennyQuelle = link("https://3.bp.blogspot.com/-U6EvkA68GsU/Wejo092AymI/AAAAAAAABKI/ojKBBOQFYJQONYVG8J8v1vEUUjWuLN3_QCLcBGAs/s1600/poor_me__s_by_pedro4ba.jpg")[Kenny-Fanzeichnung: Pedro4ba, Bildkopie auf Blogspot]
#let bild(name) = image(
  bildpfad + name,
  width: 100%,
  height: 100%,
  fit: "contain",
)

// Textfläche. Die Bullets bleiben für die Lesbarkeit linksbündig.
#let centered-items(body, height: none) = {
  if height == none {
    align(left + horizon, body)
  } else {
    box(
      width: 100%,
      height: height,
      align(left + horizon, body),
    )
  }
}
// Die zentrale Präambel erwartet für den Überdeckungseffekt derzeit eine
// Touying-Funktion mit `self`-Parameter; ihre Einstellung `transparent: false`
// verwendet stattdessen die native Typst-Funktion `hide` und kompiliert nicht.
#show: kn-vorlage.with(
  titel: titel,
  untertitel: untertitel,
  autor: autor,
  datum: datum,
  bereich: bereich,
  rechts: veranstaltung,
  handout: sys.inputs.at("handout", default: "false") == "true",
  transparent: sys.inputs.at("transparent", default: "false") == "true",
)

#kn-titelfolie()


// 02 – Überblick
#slide(title: text(size: 22pt, weight: "regular", [Was Sie in den nächsten 75 Minuten erwartet]))[
  #set text(size: 16pt)
  #box(width: 100%, height: 105mm, align(left + horizon, grid(
    columns: (1fr, 1fr),
    gutter: 8mm,
    [
      #enum(start: 1,
        [Warum Ernährung wichtig ist],
        [Energieziel: Leitlinien, BMI, Formeln und V̇CO₂],
        [Erkrankungsphasen und Rekonvaleszenz],
      )
    ],
    [
      #enum(start: 4,
        [Energie und Protein praktisch zuführen],
        [Enterale Intoleranz erkennen und behandeln],
        [Zufuhr täglich anhand von Phosphat und Blutzucker prüfen],
      )
    ],
  )))
]
//

#slide(title: text(size: 22pt, weight: "regular", [Was Sie in den nächsten 90 Minuten erwartet]))[
  #set text(size: 16pt)

  #align(left + horizon)[
    #grid(
      columns: (55%, 41%),
      gutter: 4%,
      align: top + left,
      [
        #set enum(spacing: 1.2em)

        + Überblick über Ernährung und Berechnung der Zielkalorien pro Tag
        + Ernährungsziele mit Beispielrechnungen
        + Ernährungsziele nach Erkrankungsphase
        + Nicht ernährungsbedingte Kalorien
        + Hypernatriämie und freies Wasser
        + Beutelernährung und Ernährung mit Einzelkomponenten
        + Ernährung in den Erkrankungsphasen und bei Organersatzverfahren
        + respiratorische Quotienten und V̇CO₂ als Ersatz für indirekte Kalorimetrie
        + Ernährung bei Bauchlage
        + Gastrales Residualvolumen (GRV ≈ Reflux )
        + metabolische Intoleranz (viel Insulin)
        + Hypophosphatämie
        + Mikronährstoffe (Spurenelemente, Vitamine, Thiamin)
      ],
      [
        #underline[Was wir nicht behandeln:]
        #v(3mm)

        - „Refeeding“
      ],
    )
  ]
]
// TODO: [USER] am Ende überarbeiten

#slide(title: text(size: 22pt, weight: "regular", [Was wissen wir über Ernährung?]))[
  #set text(size: 18pt)
#place(
  top + left,
  dx: 0mm,
  dy: 8mm,
  rotate(
    0deg,
    reflow: false,
    stack(
      dir: ttb,
      spacing: 2mm,
      image(
        bildpfad + "slide-004-ludwig-feuerbach-portraet.png",
        width: 90mm,
        height: 100mm,
        fit: "contain",
      ),
      align(
        center,
      )[
        #text(size: 16pt)[Ludwig Feuerbach (1804–1872)]
      ],
    ),
  ),
)
  #place(
    top + left,
    dx: 185mm,
    dy: 8mm,
    rotate(
      0deg,
      reflow: false,
      stack(
        dir: ttb,
        spacing: 2mm,
        image(
          bildpfad + "slide-004-james-nachtwey-portraet.png",
          width: 75mm,
          height: 100mm,
          fit: "contain",
        ),
        block(
          width: 75mm,
        )[
          #align(center)[
            #text(size: 16pt)[
              James Nachtwey
            ]
          ]
        ],
      ),
    ),
  )

  #place(
    top + left,
    dx: 80mm,
    dy: 25mm,
    box(
      width: 105mm,
      height: 78mm,
      centered-items(
        item-by-item([
          - Ludwig Feuerbach: „Der Mensch ist, was er isst.“
          - James Nachtwey: „Hunger ist die älteste Massenvernichtungswaffe der Menschheit.“
        ]),
      ),
    ),
  )
  #quelle([#link("https://www.pinterest.com/pin/460915343096209725/")[James Nachtwey / Pinterest],
    #linebreak()
    #link("https://www.epikur-journal.at/de/ausgabe/detail.asp?id=159&art=Artikel&tit=%E2%80%9EDer%2520Mensch%2520ist%2C%2520was%2520er%2520isst.%E2%80%9C%2520")[Ludwig Feuerbach / Epikur-Journal] (Stand 12.03.2023)])
]

// 45 – U-Kurve
#slide(title: text(size: 22pt, weight: "regular", [Kalorienzufuhr und Sterblichkeit: Beobachtungsdaten]))[
  #set text(size: 16pt)
  #grid(
    columns: (57%, 39%),
    gutter: 4%,
    [
      #centered-items[
        - retrospektive Kohorte (n = 1.171)
        - das Verhältnis von Kalorienzufuhr zu gemessenem Energieumsatz ist U-förmig mit der 60-Tage-Mortalität assoziiert.
        - Kurvenminimum ca. bei 70 % des gemessenen Ruheenergieumsatzes (indirekte Kalorimetrie).
      ]
    ],
    [
      #grid(
        columns: (1fr,),
        gutter: 2mm,
        row-gutter: 2mm,
        box(
          width: 100%,
          height: 120mm,
          align(
            center + horizon,
            bild(
              "slide-045-kalorienzufuhr-und-sterblichkeit.png",
            ),
          ),
        ),
      )
    ],
  )
  #quelle([#cite(<zusman2016RestingEnergyExpenditure>, supplement: [Abb. 2, S. 6]).])
]
// Zusatzfolie – vollständige Abbildung aus dem VCO₂-Vortrag
#slide(
  title: text(
    size: 22pt,
    weight: "regular",
    [Zusman 2016: Kalorien und Protein im Vergleich],
  ),
)[
  #set text(size: 15pt)

  #place(
    top + center,
    dy: 0mm,
    image(
      "bilder-latex/zusman-2016-u-kurve-ernaehrung-s-2-no-notes.png",
      width: 275mm,
      height: 98mm,
      fit: "contain",
    ),
  )

  #place(
    top + center,
    dy: 102mm,
    box(width: 260mm)[
      #set align(left)
      #set text(size: 13pt)

      - Je zusätzlichem g Protein/Tag war die adjustierte Hazard der 60-Tage-Mortalität etwa 1 % niedriger (HR 0,99).
      - 1,3 g Protein = 1,56 g AS (entspricht der ESPEN 2023 Empfehlung)
    ],
  )

  #quelle([
    #cite(
      <zusman2016RestingEnergyExpenditure>,
      supplement: [S. 3, S. 6, Abb. 2],
    ).
  ])
]

// 05 – Minnesota
#slide(title: text(size: 22pt, weight: "regular", [Minnesota Starvation Experiment (1944–1945)]))[
  #set text(size: 16pt)
  #place(
    top + left,
    dx: 0mm,
    dy: 0mm,
    rotate(
      0deg,
      reflow: false,
      image(
        bildpfad + "slide-005-minnesota-starvation-werbeplakat.png",
        width: 75mm,
        height: 105mm,
        fit: "contain",
      ),
    ),
  )
  #place(
    top + left,
    dx: 75mm,
    dy: 10mm,
    rotate(
      0deg,
      reflow: false,
      image(
        bildpfad + "slide-005-minnesota-starvation-teilnehmer.png",
        width: 85mm,
        height: 80mm,
        fit: "contain",
      ),
    ),
  )
#place(
  top + left,
  dx: 163mm,
  dy: 3mm,
  box(
    width: 113mm,
    height: 112mm,
  )[
    - 3 Monate Standardernährung: 3.200 kcal/Tag
    - 6 Monate „Halbhungern“: 1.800 kcal/Tag

    #pause

    - Danach 3 Monate Rehabilitation
    - 36 junge Kriegsdienstverweigerer verloren mehr als 25 % ihres Gewichts.
    - Bis zur Rückkehr zum Ausgangsgewicht vergingen teils zwei Jahre.
  ],
)
  #quelle([#cite(<kalm2005TheyStarvedThat>, supplement: [S. 1347–1352])#text[;]\  #cite(<pieper2014USWWIIMinnesota>) (Stand 12.03.2023).])
]

// 06 – Leitfragen
// #slide(title: text(size: 22pt, weight: "regular", [Ernährung: relevante Fragen]))[
//   #set text(size: 18pt)
//   #place(top + left, dx: 92mm, dy: 3mm, rotate(0deg, reflow: false, image(bildpfad + "slide-006-homer-simpson-denkt.png", width: 92mm, height: 110mm, fit: "contain")))
//   #place(top + left, dx: 0mm, dy: 16mm, box(width: 90mm, height: 93mm, item-by-item([
//     - Wann?
//     - Wie?
//     - Wie viel?
//     - Womit?
//   ])))
//   #quelle([Bild: #link("https://noahsturm.deviantart.com/art/Thinking-Homer-399877668")[Noah Sturm / DeviantArt] (Stand 14.03.2023).])
// ]
//
// 07 – nutritionDay
#slide(title: text(size: 22pt, weight: "regular", [Ernährungspraxis auf Intensivstationen]))[
  #set text(size: 18pt)
  #place(
    top + left,
    dx: 120mm,
    dy: 0mm,
    rotate(
      0deg,
      reflow: false,
      image(
        bildpfad + "slide-007-nutritionday-studie-titel.png",
        width: 140mm,
        height: 25mm,
        fit: "contain",
      ),
    ),
  )
  #place(
    top + left,
    dx: 5mm,
    dy: 30mm,
    rotate(
      0deg,
      reflow: false,
      image(
        bildpfad + "slide-007-nutritionday-studie-methodik.png",
        width: 250mm,
        height: 40mm,
        fit: "contain",
      ),
    ),
  )
  #place(
    top + left,
    dx: 10mm,
    dy: 70mm,
    rotate(
      0deg,
      reflow: false,
      image(
        bildpfad + "slide-007-nutritionday-studie-patienten.png",
        width: 245mm,
        height: 20mm,
        fit: "contain",
      ),
    ),
  )
  #place(
    top + left,
    dx: 40mm,
    dy: 90mm,
    rotate(
      0deg,
      reflow: false,
      image(
        bildpfad + "slide-007-nutritionday-studie-energiezufuhr.png",
        width: 200mm,
        height: 30mm,
        fit: "contain",
      ),
    ),
  )
  // Die beiden roten Markierungen der PowerPoint erscheinen nacheinander.
  #place(top + left, dx: 166mm, dy: 94mm, uncover("2-", ellipse(width: 75mm, height: 13mm, stroke: 1.2pt + rgb("#c00000"))))
  #place(top + left, dx: 45mm, dy: 105mm, uncover("3-", ellipse(width: 125mm, height: 13mm, stroke: 1.2pt + rgb("#c00000"))))
  #quelle[
    #cite( 
      <hiesmayr2023ErnahrungspraxisAufIntensivstationen>,
      supplement: [S. 89–90, 95],
    )
  ]
]

// 08 – Vergleich nutritionDay/Minnesota
#slide(title: text(size: 22pt, weight: "regular", [Ernährung: Wo stehen wir?]))[
  #set text(size: 18pt)
  #place(
    top + left,
    dx: 0mm,
    dy: 8mm,
    rotate(
      0deg,
      reflow: false,
      image(
        bildpfad + "slide-008-nutritionday-studie-titel.png",
        width: 138mm,
        height: 35mm,
        fit: "contain",
      ),
    ),
  )
  // #place(top + left, dx: 143mm, dy: 8mm, rotate(0deg, reflow: false, image(bildpfad + "slide-008-minnesota-starvation-vorher-nachher.png", width: 125mm, height: 95mm, fit: "contain")))
  // Bild
  #place(
    top + left,
    dx: 143mm,
    dy: 8mm,
    image(
      bildpfad + "slide-008-minnesota-starvation-vorher-nachher.png",
      width: 125mm,
      height: 95mm,
      fit: "contain",
    ),
  )

  // Erste Beschriftung
  #place(
    top + left,
    dx: 147mm,
    dy: 75mm,
    stack(
      dir: ttb,
      spacing: 8mm,
      text(
        size: 24pt,
        weight: "bold",
        fill: gelb,
      )[1944],
      text(
        size: 24pt,
        weight: "bold",
        fill: gelb,
      )[1.800 kcal/Tag],
    ),
  )
  #place(
    top + left,
    dx: 3mm,
    dy: 50mm,
    box(
      width: 132mm,
      height: 65mm,
    )[
      #v(4.5em)
      #align(center)[#text(size: 24pt, weight: "bold")[
        Median 1.500 kcal/Tag\ #text(fill: kn-rot, [(keine Assoziation zum Gewicht)])]
      ]
    ],
  )

#quelle([
  #cite(<hiesmayr2023ErnahrungspraxisAufIntensivstationen>, supplement: [S. 95]);
  #linebreak()
  #cite(<kalm2005TheyStarvedThat>, supplement: [S. 1347–1352]);
  #linebreak()
  Bild: #cite(<pieper2014USWWIIMinnesota>) (Stand 12.03.2023).
])
]

// 09 – Leitlinien
// Abschnittsfolie: vom Problem zur Energiebedarfsermittlung.
#slide(title: text(size: 22pt, weight: "regular", [Energiebedarf]))[
  #box(width: 100%, height: 108mm)[
    #align(center + horizon)[#text(size: 29pt, weight: "bold")[Wie viel Energie braucht ein Mensch auf der Intensivstation?]]
  ]
]
// NOTE: Die rote Notiz der PowerPoint „Keine Empfehlung zu Ernährung bei
// Adipositas“ wird nicht übernommen: ESPEN 2023 enthält Empfehlungen 51/52
// für adipöse Intensivpatient:innen (S. 1684–1685).
#slide(title: text(size: 22pt, weight: "regular", [Leitlinien zur Ernährung auf der Intensivstation]))[
  #set text(size: 18pt)
  #place(
    top + left,
    dx: 95mm,
    dy: 0mm,
    rotate(
      0deg,
      reflow: false,
      image(
        bildpfad + "slide-009-espen-leitlinie-intensivmedizin.png",
        width: 150mm,
        height: 55mm,
        fit: "contain",
      ),
    ),
  )
  #place(
    top + left,
    dx: 5mm,
    dy: 58mm,
    rotate(
      0deg,
      reflow: false,
      image(
        bildpfad + "slide-009-aspen-leitlinie-ernaehrungstherapie.png",
        width: 145mm,
        height: 35mm,
        fit: "contain",
      ),
    ),
  )
  #place(
    top + left,
    dx: 152mm,
    dy: 62mm,
    rotate(
      0deg,
      reflow: false,
      image(
        bildpfad + "slide-009-dgem-leitlinie-intensivmedizin.png",
        width: 120mm,
        height: 35mm,
        fit: "contain",
      ),
    ),
  )
  #quelle([#cite(<singer2023ESPENPracticalPartially>, supplement: [S. 1671–1689]);
    #linebreak()
    #cite(<compher2022GuidelinesProvisionNutrition>, supplement: [S. 12–41]);
    #linebreak()
    #cite(<elke2019DGEMS2kLeitlinieKlinische>, supplement: [S. 341–408]) – Fassung der Ausgangspräsentation.])
]


// 11 – Methoden
#slide(title: text(size: 22pt, weight: "regular", [Ernährung: Wie berechnen?]))[
  #set text(size: 16pt)
  #box(width: 100%, height: 105mm, align(center + horizon, grid(
    columns: (57%, 39%),
    gutter: 4%,
    [
      #centered-items(height: 87mm)[#item-by-item[
        #set list(
          spacing: 2em,
          tight: false,
        )
        // MEMO: list spacing macht mir die Abstände zwischen den Bullets; tight false verhindert manchmal das spacing bei Listen mit -
        - Statische Formeln verwenden Größe, Gewicht, Alter und Geschlecht; teils auch einen Stressfaktor.
        - Dynamische Verfahren berücksichtigen veränderliche physiologische Parameter.
        - Die indirekte Kalorimetrie (IC) misst Sauerstoffverbrauch und CO₂-Produktion.
        - Wenn IC nicht vorhanden: V̇CO₂ schätzt den Energieverbrauch besser als Formeln.
      ]]
    ],
    [
      #grid(
        columns: (1fr,),
        gutter: 2mm,
        row-gutter: 2mm,
        box(
          width: 100%,
          height: 87mm,
          align(
            center + horizon,
            bild(
              "slide-011-indirektes-kalorimeter.png",
            ),
          ),
        ),
      )
    ],
  )))
  #quelle([#cite(<dewaele2015MeasuredCalculatedResting>, supplement: [S. 273, 279])#text[;]
    #linebreak()
    #cite(<singer2023ESPENPracticalPartially>, supplement: [S. 1678, Aussage 21])#text[;]
    #linebreak()
    Kalorimeterbild: #link("http://www.medicopes.com/product_images/o/858/MedGraphics_CCM_Express_Indirect_Calorimeter_-_Certified_Pre-Owned__46309_zoom.jpg")[Medicopes] (Stand 12.03.2023).])
]

// 10 – Diskussionsstand
#slide(title: text(size: 22pt, weight: "regular", [Ernährung: einfach oder kompliziert?]))[
  #set text(size: 16pt)
  #place(
    top + left,
    dx: 0mm,
    dy: 0mm,
    rotate(
      0deg,
      reflow: false,
      image(
        bildpfad + "slide-010-energie-protein-editorial-stoppe.png",
        width: 120mm,
        height: 38mm,
        fit: "contain",
      ),
    ),
  )
  #place(
    top + left,
    dx: 140mm,
    dy: 0mm,
    rotate(
      0deg,
      reflow: false,
      image(
        bildpfad + "slide-010-praezisions-ernaehrungstherapie-stoppe.png",
        width: 135mm,
        height: 85mm,
        fit: "contain",
      ),
    ),
  )
  #place(top + left, dx: 100mm, dy: 20mm, uncover("2-", text(size: 15pt, fill: rgb("#c00000"))[4 Seiten]))
  #place(top + left, dx: 245mm, dy: 10mm, uncover("3-", text(size: 15pt, fill: rgb("#c00000"))[12 Seiten]))
  #place(
    top + left,
    dx: 0mm,
    dy: 42mm,
    box(
      width: 135mm,
      height: 73mm,
      centered-items(
        item-by-item([
          - Tag 1–4: 5–10 kcal/kg und 0,2–0,6 g Protein/kg
          - Tag 5–7: schrittweise auf 15–20 kcal/kg und 0,8–1,0 g Protein/kg
          - Nach Tag 7: 20–25 kcal/kg und 1,0–1,2 g Protein/kg
          - Offen: Ernährung bei Adipositas?
        ]),
      ),
    ),
  )
  #quelle([#cite(<stoppe2025RethinkingEnergyProtein>, supplement: [S. 168]);
    #linebreak()
    #cite(<stoppe2025PrecisionNutritionTherapy>, supplement: [S. e429–e440]).])
]

// 12 – Formelübersicht
#slide(title: text(size: 22pt, weight: "regular", [Statische und dynamische Berechnungsverfahren]))[
  #set text(size: 18pt)

  #place(
    top + center,
    dy: 5mm,
    image(
      bildpfad + "slide-012-energieumsatz-formeln-vergleich.png",
      width: 270mm,
      height: 110mm,
      fit: "contain",
    ),
  )
  #place(top + left, dx: 239mm, dy: 22mm, uncover("2-", rect(width: 4mm, height: 1pt, fill: rgb("#c00000"), stroke: none)))
  #place(top + left, dx: 243mm, dy: 22mm, uncover("2-", rect(width: 1pt, height: 38mm, fill: rgb("#c00000"), stroke: none)))
  #place(top + left, dx: 239mm, dy: 60mm, uncover("2-", rect(width: 4mm, height: 1pt, fill: rgb("#c00000"), stroke: none)))
  #place(top + left, dx: 245mm, dy: 39mm, uncover("2-", text(size: 13pt, fill: rgb("#c00000"))[statisch]))
  #place(top + left, dx: 239mm, dy: 62mm, uncover("3-", rect(width: 4mm, height: 1pt, fill: rgb("#c00000"), stroke: none)))
  #place(top + left, dx: 243mm, dy: 62mm, uncover("3-", rect(width: 1pt, height: 32mm, fill: rgb("#c00000"), stroke: none)))
  #place(top + left, dx: 239mm, dy: 94mm, uncover("3-", rect(width: 4mm, height: 1pt, fill: rgb("#c00000"), stroke: none)))
  #place(top + left, dx: 245mm, dy: 76mm, uncover("3-", text(size: 13pt, fill: rgb("#c00000"))[dynamisch]))

  #quelle([
    #cite(<dewaele2015MeasuredCalculatedResting>, supplement: [S. 274]).
  ])
]
// 13 – historische Quelle
// #slide(title: text(size: 22pt, weight: "regular", [Harris und Benedict (1918)]))[
//   #set text(size: 15pt)
//   #place(
//     top + left,
//     dx: 0mm,
//     dy: 0mm,
//     image(
//       bildpfad + "slide-013-harris-benedict-originalstudie-titel.png",
//       width: 145mm,
//       height: 24mm,
//       fit: "contain",
//     ),
//   )
//   #place(
//     top + left,
//     dx: 0mm,
//     dy: 24mm,
//     image(
//       bildpfad + "slide-013-harris-benedict-originalstudie-stichprobe.png",
//       width: 145mm,
//       height: 24mm,
//       fit: "contain",
//     ),
//   )
//   #place(
//     top + left,
//     dx: 160mm,
//     dy: 0mm,
//     image(
//       bildpfad + "slide-013-james-arthur-harris-portraet.png",
//       width: 54mm,
//       height: 48mm,
//       fit: "contain",
//     ),
//   )
//   #place(
//     top + left,
//     dx: 220mm,
//     dy: 0mm,
//     image(
//       bildpfad + "slide-013-francis-gano-benedict-portraet.png",
//       width: 54mm,
//       height: 48mm,
//       fit: "contain",
//     ),
//   )
//   #place(
//     top + center,
//     dy: 51mm,
//     image(
//       bildpfad + "slide-013-harris-benedict-originalstudie-formel.png",
//       width: 220mm,
//       height: 63mm,
//       fit: "contain",
//     ),
//   )
//   #quelle([#cite(<harris1918BiometricStudyHuman>, supplement: [S. 371, 373])#text[;]
//     #linebreak()
//     Porträts: #link("https://prabook.com/web/james.harris/3771027")[James Harris / Prabook] und #link("https://en.wikipedia.org/wiki/Francis_Gano_Benedict")[Francis Benedict / Wikipedia] (Stand 12.03.2023).])
// ]
//
// 16 – 18: Vergleich mit Messung
#slide(title: text(size: 22pt, weight: "regular", [Formeln gegenüber indirekter Kalorimetrie]))[
  #set text(size: 18pt)
  #place(
    top + center,
    dx: 0mm,
    dy: -2mm,
    image(
      bildpfad + "slide-016-energieumsatz-formeln-korrelation.png",
      width: 280mm,
      height: 105mm,
      fit: "contain",
    ),
  )
  #place(
    top + center,
    dx: 0mm,
    dy: 107mm,
    // MEMO: R² und AUC sind unterschiedliche statistische Gütemaße. Den
    // vorhandenen Vergleich inhaltlich vor dem Vortrag prüfen; dieser Auftrag
    // verlangt nur die Zentrierung und belässt den Wortlaut unverändert.
    box(
      width: 280mm,
align(center)[Bei einem R#super[2] von 0,43 werden *57 % der beobachteten Varianz* durch das Modell nicht erklärt.]
    ),
  )
  #place(top + center, dy: 63mm, only("2-", rect(width: 250mm, height: 7mm, stroke: 1.5pt + rgb("#c00000"), fill: none)))
  #place(top + center, dy: 40mm, only("3-", rotate(-12deg, reflow: false, text(size: 28pt, weight: "bold", fill: rgb("#c00000"))[Formeln gar nicht gut!])))
  #quelle([#cite(<dewaele2015MeasuredCalculatedResting>, supplement: [S. 279]).])
]
// 21 – BMI-abhängige Zielwerte aus der DGEM-Folie
#slide(title: text(size: 22pt, weight: "regular", [Ernährungsziele nach DGEM und ESPEN]))[
  #set text(size: 12pt)
  #text(size: 15pt, weight: "bold")[Nach DGEM 2019]
  #v(2mm)
  #table(
    columns: (35mm, 1fr, 1fr, 1fr),
    inset: 4pt,
    stroke: 0.5pt + rgb("#DFD7CD"),
    table.header(
      [*Zielgröße*], [*BMI < 30 kg/m²*], [*BMI 30–50 kg/m²*], [*BMI > 50 kg/m²*],
    ),
    [Energie], [24 kcal/kg aktuelles KG], [11–14 kcal/kg aktuelles KG], [22–25 kcal/kg IBW],
    [Aminosäuren], [max. 1,2 g/kg KG], [max. 1,8 g/kg IBW], [max. 1,8 g/kg IBW],
    [Fette], [0,7–1,3 g/kg KG], [max. 0,9 g/kg KG], [max. 1,5 g/kg IBW],
    [Kohlenhydrate], [max. 4 g/kg KG], [max. 2,5 g/kg KG], [max. 5 g/kg IBW],
  )
  #v(1mm)
  - Kohlenhydrat/Fett: 70/30 bis 50/50. Ergibt ca. folgendende Zusammensetzung: 20 % Aminosäuren, 40 % Kohlenhydrate und 40 % Fette.
  #v(2mm)
  #text(size: 15pt, weight: "bold")[Nach ESPEN 2023]
  #v(1mm)
  #table(
    columns: (66mm, 1fr),
    inset: 4pt,
    stroke: 0.5pt + rgb("#DFD7CD"),
    table.header([*Zielgröße*], [*ESPEN 2023*]),
    [Energie], [20--25 kcal/kg/Tag],
    [Protein allgemein], [1,3 g Proteinäquivalente/kg/Tag],
    [Protein bei Adipositas], [Stickstoffverluste oder fettfreie Masse bestimmen; ersatzweise 1,3 g/kg #text(weight: "bold")[adjustiertes Körpergewicht]/Tag.],
    [Kohlenhydrate], [Glukose (parenteral) bzw. Kohlenhydrate (enteral): höchstens 5 mg/kg/min.],
    [Intravenöse Lipide], [Einschließlich nicht nutritiver Lipidquellen höchstens 1,5 g/kg/Tag; an die Verträglichkeit anpassen.],
  )
  #v(1mm)
  #text(size: 15pt)[*Adjustiertes Gewicht: Idealgewicht + 20–25 % der Differenz zum aktuellen Gewicht (pragmatischer Ansatz).*]
  #quelle([#cite(<elke2019DGEMS2kLeitlinieKlinische>, supplement: [S. 352, 362, 383, 387, 392, 400–401]);
    #linebreak()
    #cite(<singer2023ESPENPracticalPartially>, supplement: [S. 1678–1679, Empfehlungen 25, 27, 29; S. 1685, Empfehlung 52]).])
]
// Zusatzfolie – Vergleich der BMI- und ABW-Rechenwege
#slide(title: text(size: 22pt, weight: "regular", [Zielkalorien: DGEM vs ESPEN]))[
  // TODO: [AGENT] kannst Du Die Graphik in der Größe lassen aber zentriert anzeigen lassen
  // NOTE: Die fünf Einblendungen behalten 290 × 128 mm; die Bildbox liegt mittig auf der Folie.
  // TODO: [AGENT] Die Bildbox ist noch nicht mittig
  // NOTE: Die gesamte 290-mm-Bildbox ist jetzt mit einem festen horizontalen Ausgleich auf der Folie zentriert; die fünf Stufen behalten ihre Größe.
  #set text(size: 14pt)
  #place(top + center, dx: 7mm, dy: -5mm, only(1, image("ernaehrung-dgem-espen-stufe-0.pdf", width: 290mm, height: 128mm, fit: "contain")))
  #place(top + center, dx: 7mm, dy: -5mm, only(2, image("ernaehrung-dgem-espen-stufe-1.pdf", width: 290mm, height: 128mm, fit: "contain")))
  #place(top + center, dx: 7mm, dy: -5mm, only(3, image("ernaehrung-dgem-espen-stufe-2.pdf", width: 290mm, height: 128mm, fit: "contain")))
  #place(top + center, dx: 7mm, dy: -5mm, only(4, image("ernaehrung-dgem-espen-stufe-3.pdf", width: 290mm, height: 128mm, fit: "contain")))
  #place(top + center, dx: 7mm, dy: -5mm, only(5, image("ernaehrung-dgem-espen-unterschied.pdf", width: 290mm, height: 128mm, fit: "contain")))
  #quelle([#cite(<elke2019DGEMS2kLeitlinieKlinische>, supplement: [S. 352, 400]);
    #linebreak()
    #cite(<singer2023ESPENPracticalPartially>, supplement: [S. 1684–1685]).])
]
// TODO: [AGENT] brauche ich die untere Folie noch? und wenn ja sollte ich nicht auch eine ESPEN ABW 20 % Rechnung ergänzen
// NOTE: Die Folie bleibt als Beispiel für den Sprung an der DGEM-BMI-Grenze; die ESPEN-ABW-Rechnung für beide Gewichte ist ergänzt.
// 22 – Sprung am BMI-Grenzwert
#slide(title: text(size: 22pt, weight: "regular", [Ernährungsziele: Beispiel am BMI-Grenzwert]))[
  #set text(size: 15pt)
  #place(
    top + left,
    dx: 130mm,
    dy: 22mm,
    rotate(
      0deg,
      reflow: false,
      image(
        bildpfad + "slide-022-bmi-gewichtsvergleich-cartoon.png",
        width: 145mm,
        height: 70mm,
        fit: "contain",
      ),
    ),
  )
#place(
  top + left,
  dx: 0mm,
  dy: 0mm,
  box(
    width: 125mm,
    height: 115mm,
    centered-items([
      - 180 cm und 100 kg: BMI 30,9 → 1.100–1.400 kcal/Tag
      - 180 cm und 95 kg: BMI 29,3 → 2.280 kcal/Tag

      #pause

      - #text(fill: rgb("#c00000"), weight: "bold")[
        Das sind trotz nur 5 kg Unterschied 162–207 % des niedrigeren Zielbereichs.
      ]

      #pause
      \
      - ESPEN mit IBW ≈ 75 kg und ABW 20 %:\
        → bei 100 kg → 80 kg ABW\
        → bei 95 kg → 79 kg ABW.
      - Bei 24 kcal/kg ABW: 1.920 bzw. 1.896 kcal/Tag.
    ]),
  ),
)
  #quelle([#cite(<elke2019DGEMS2kLeitlinieKlinische>, supplement: [S. 352, 400]);
    #cite(<singer2023ESPENPracticalPartially>, supplement: [S. 1685]);
    #linebreak()
    Cartoon: #link("https://medium.com/welfarebychetna/undernutrition-first-impression-one-gets-talking-malnutrition-1982177ebe99")[Medium / Welfare by Chetna] (Stand 13.03.2023).])
]



// NOTE: Erledigt. Formel, physiologische Herleitung und die Grenzen der späteren Beobachtungsstudie sind auf einer neuen Folie dargestellt.
#slide(title: text(size: 22pt, weight: "regular", [Adjustiertes Körpergewicht: Was steckt dahinter?]))[
  #set text(size: 17pt)
  #align(center)[
    #text(weight: "bold")[EW = aktuelles KG − IBW]
    #h(8mm)
    #text(weight: "bold")[ABW = IBW + Anteil × EW]
  ]
  #v(7mm)
  - *20–25 %* des Mehrgewichts: pragmatischer ESPEN-Ansatz.\
    *Begründung:* Fettgewebe verbraucht ca. 4,5 kcal/kg/Tag,
    Muskelgewebe ca. 13 kcal/kg/Tag. Annahme: 1 kg Mehrgewicht
    besteht aus 90 % Fett- und 10 % Muskelgewebe.\
    - Fett: 0,9 × 4,5 = 4,05 kcal/Tag
    - Muskel: 0,1 × 13 = 1,30 kcal/Tag
    - Gesamt: 5,35 kcal/Tag
  
    *Der Muskelanteil von 10 % trägt somit
     ≈ 24,3 % (1,3 / 5,35) zum Energiebedarf des Mehrgewichts bei.*
  #quelle([
    #cite(<wang2000RestingEnergyExpenditurefatfree>, supplement: [S. E541–E542]);
    #linebreak()
    #cite(<singer2023ESPENPracticalPartially>, supplement: [S. 1685])
    ])
]



#slide(title: text(size: 22pt, weight: "regular", [Adjustiertes Körpergewicht: 20–25 % – Stimmt das?]))[
  #set text(size: 18pt)

#centered-items(height: 105mm)[
  de Heer 2025: indirekte Kalorimetrie als Referenz bei adipösen Patient:innen

  - *ABW 18 %*: Beste Übereinstimmung mit indirekter Kalorimetrie
  - *ABW 20 %*: Scheint ein legitimes Vorgehen zu sein

  #v(2em)

  #uncover("2-", cover-fn: hide)[
    Wo man ABW noch benutzt?

    - *40 %* des Mehrgewichts: ältere Rechengröße von Schwartz 1978 für die Dosierung von Aminoglykosiden.
    - Daptomycin
    - Acyclovir
  ]
]
  #quelle([
    #cite(<schwartz1978ControlledInvestigationPharmacokinetics>, supplement: [S. 504]);
    #linebreak()
    #cite(<deheer2025EnergyExpenditureCritically>, supplement: [S. 3–4, 6]).
  ])
]

// 14 – Beispiel statisch
// TODO: [AGENT] brauche ich die Folie wirklich noch
// NOTE: Als optionales Beispiel beibehalten: Die Folie macht den zusätzlichen Stressfaktor der statischen App-Rechnung sichtbar; im 75-Minuten-Vortrag kann sie übersprungen werden.

#slide(title: text(size: 22pt, weight: "regular", [Statisch: Harris-Benedict-Formel]))[
  #set text(size: 18pt)
  #place(
    top + center,
    dy: 1mm,
    box(
      width: 275mm,
    )[
      #align(center)[#text(size: 15pt)[BMI 32,7 · DGEM-Ziel: 1.100–1.400 kcal/Tag · App mit Stressfaktor: 2.969 kcal/Tag]]
    ],
  )
  #place(
    top + center,
    dx: -42mm,
    dy: 12mm,
    image(
      bildpfad + "slide-014-grundumsatz-app-harris-benedict-formel.png",
      width: 88mm,
      height: 98mm,
      fit: "contain",
    ),
  )
  #place(
    top + center,
    dx: 42mm,
    dy: 12mm,
    image(
      bildpfad + "slide-014-grundumsatz-app-eingabe.png",
      width: 88mm,
      height: 98mm,
      fit: "contain",
    ),
  )
  #place(top + left, dx: 170mm, dy: 48mm, uncover("2-", ellipse(width: 39mm, height: 15mm, stroke: 1.3pt + rgb("#c00000"))))
  #place(top + left, dx: 159mm, dy: 67mm, uncover("3-", ellipse(width: 47mm, height: 15mm, stroke: 1.3pt + rgb("#c00000"))))
  #place(top + left, dx: 215mm, dy: 74mm, uncover("3-", text(size: 15pt, fill: rgb("#c00000"))[→ Stressfaktor 1,5 ×]))
  #quelle([#cite(<harris1918BiometricStudyHuman>, supplement: [S. 370–373]);
    #linebreak()
    #cite(<elke2019DGEMS2kLeitlinieKlinische>, supplement: [S. 400])#text[;]
    #linebreak()
    App-Bilder: #link("https://www.aerzteblatt.de/archiv/196208/MedCalX-Schneller-Zugriff-auf-Formeln-Skalen-und-Klassifikationen")[Ärzteblatt / MedCalX] (Stand 12.03.2023).])
]

// TODO: [AGENT] brauche ich die Folie wirklich noch
// NOTE: Als optionalen Vergleich beibehalten: Penn State zeigt, dass auch eine dynamische Formel vom gemessenen Energieumsatz abweichen kann; im Kurzvortrag überspringbar.
// 15 – Beispiel dynamisch
#slide(title: text(size: 22pt, weight: "regular", [Dynamisch: Penn-State-Formel 2003b]))[
  #set text(size: 18pt)
  #place(
    top + center,
    dy: 1mm,
    box(
      width: 275mm,
    )[
      #align(center)[#text(size: 15pt)[BMI 32,7 · DGEM-Ziel: 1.100–1.400 kcal/Tag · Penn State: 2.280 kcal/Tag]]
    ],
  )
  #place(
    top + center,
    dy: 12mm,
    image(
      bildpfad + "slide-015-penn-state-formel-rechner.png",
      width: 110mm,
      height: 99mm,
      fit: "contain",
    ),
  )
  #quelle([#cite(<elke2019DGEMS2kLeitlinieKlinische>, supplement: [S. 400])#text[;]
    #linebreak()
    Rechnerbild: #cite(<PennState2003b>) (Stand 12.03.2023).])
]


// #slide(title: text(size: 22pt, weight: "regular", [Formeln gegenüber Kalorimetrie: BMI-Subgruppen]))[
//   #set text(size: 18pt)
//   #place(
//     top + left,
//     dx: 0mm,
//     dy: 0mm,
//     rotate(
//       0deg,
//       reflow: false,
//       image(
//         bildpfad + "slide-017-energieumsatz-formeln-bmi-subgruppen.png",
//         width: 275mm,
//         height: 114mm,
//         fit: "contain",
//       ),
//     ),
//   )
//   #quelle([#cite(<dewaele2015MeasuredCalculatedResting>, supplement: [S. 279]).])
// ]
//

// #slide(title: text(size: 22pt, weight: "regular", [Formeln gegenüber Kalorimetrie: Altersgruppen]))[
//   #set text(size: 18pt)
//   #place(
//     top + left,
//     dx: 0mm,
//     dy: 0mm,
//     rotate(
//       0deg,
//       reflow: false,
//       image(
//         bildpfad + "slide-018-energieumsatz-formeln-alter-subgruppen.png",
//         width: 275mm,
//         height: 114mm,
//         fit: "contain",
//       ),
//     ),
//   )
//   #quelle([#cite(<dewaele2015MeasuredCalculatedResting>, supplement: [S. 279]).])
// ]
//
// 19 – Schlussfolgerung aus der Leitlinie
#slide(title: text(size: 22pt, weight: "regular", [Berechnung des Ernährungsziels: Fazit]))[
  #set text(size: 16pt)
  #place(
    top + left,
    dx: 0mm,
    dy: 5mm,
    rotate(
      0deg,
      reflow: false,
      image(
        "./bilder-latex/singer-2023-vco2-formula-p-1678.png",
        width: 130mm,
        height: 45mm,
        fit: "contain",
      ),
    ),
  )
  #place(
    top + left,
    dx: 0mm,
    dy: 56mm,
    rotate(
      0deg,
      reflow: false,
      image(
        bildpfad + "slide-019-dgem-empfehlung-vco2-methode.png",
        width: 130mm,
        height: 37mm,
        fit: "contain",
      ),
    ),
  )
  #place(
    top + left,
    dx: 140mm,
    dy: 0mm,
    rotate(
      0deg,
      reflow: false,
      image(
        bildpfad + "slide-019-dgem-empfehlung-indirekte-kalorimetrie.png",
        width: 130mm,
        height: 62mm,
        fit: "contain",
      ),
    ),
  )
  #place(
    top + left,
    dx: 140mm,
    dy: 65mm,
    box(
      width: 130mm,
      height: 50mm,
      centered-items(
        item-by-item([
          - Indirekte Kalorimetrie, wenn verfügbar
          - Andernfalls ein einfaches, BMI- und gewichtsabhängiges Energieziel
          - #text(fill: rgb("#c00000"), weight: "bold")[Keine zusätzliche komplexe Formel und kein pauschaler Stressfaktor]
        ]),
      ),
    ),
  )
  #quelle([
#cite(
  <singer2023ESPENPracticalPartially>,
  supplement: [S. 1678]
)
#linebreak()
    #cite(<elke2019DGEMS2kLeitlinieKlinische>, supplement: [S. 352])])
]

// Zusatzfolien – VCO₂ aus der Stationsfortbildung
#slide(title: text(size: 22pt, weight: "regular", [V̇CO₂: Energie aus der Ausatemluft schätzen]))[
  #set text(size: 16pt)
  #grid(
    columns: (48%, 48%),
    gutter: 4%,
    [
      #image("bilder-latex/voigt-2015-messkopf-kuevette-p-41.png", width: 100%, height: 105mm, fit: "contain")
    ],
    [
      #centered-items(item-by-item([
        - V̇CO₂ ist die ausgeatmete CO₂-Menge pro Minute. Ein etCO₂-Zahlenwert allein reicht dafür nicht.
        - Fehlt die indirekte Kalorimetrie, ist die V̇CO₂-Schätzung genauer als Gewichtsformeln.
      #v(4mm)
      #align(center)[#text(size: 19pt, weight: "bold")[Kalorien ≈ 8,19 × V̇CO₂ (ml/min)]]
      #v(4mm)
        - Der Faktor 8,19 setzt einen angenommenen respiratorischen Quotienten (Food Quotienten) voraus.
      ]))
    ],
  )
  #quelle([#cite(<singer2023ESPENPracticalPartially>, supplement: [S. 1678]);
    #linebreak()
    #cite(<stapel2015VentilatorderivedCarbonDioxide>, supplement: [PDF-S. 2–5]);
    #linebreak()
    Bild: #cite(<voigt2015CO2MeasurementVentilation>, supplement: [S. 41]).])
]

#slide(title: text(size: 22pt, weight: "regular", [Das Setup an der Evita]))[
  #set text(size: 16pt)
  #grid(columns: (1fr, 1fr), gutter: 8mm,
    [#image("bilder-latex/evita-co2-2019-sensor-p-6.png", width: 100%, height: 91mm, fit: "contain")
     #align(center)[Dräger-Infrarotmesskopf]],
    [#image("bilder-latex/evita-co2-2019-kuevette-p-6.png", width: 100%, height: 91mm, fit: "contain")
     #align(center)[Dräger-CO₂-Küvette]],
  )
  #quelle([#cite(<2019CO2Messung>, supplement: [S. 6]).])
]

#slide(title: text(size: 22pt, weight: "regular", [Eine CO₂-Messung, zwei Anwendungen]))[
  #set text(size: 17pt)
  #grid(columns: (54%, 42%), gutter: 4%,
    [#image("bilder-latex/suarez-sipmann-2014-vcap-p-334-no-notes.png", width: 100%, height: 101mm, fit: "contain")],
    [#box(width: 100%, height: 101mm, align(left + horizon, [
      - *V̇CO₂:* Fläche unter dem volumetrischen Kapnogramm → ausgeatmete CO₂-Menge pro Minute; Grundlage der Energieabschätzung.
      - *Totraum:* P#sub[A]CO#sub[2] → Alveoläres CO₂ #sym.arrow.r Hinweis auf nicht wirksam am Gasaustausch beteiligtes Tidalvolumen.
    ]))],
  )
  #quelle([#cite(<suarez-sipmann2014VolumetricCapnographyTime>, supplement: [S. 334–337]).])
]


// TODO: [AGENT] und die Folie "Die vereinfachte Weir Formel"
// NOTE: Die V̇CO₂-Näherung mit einem klar gekennzeichneten Rechenbeispiel ist ergänzt.
#slide(title: text(size: 22pt, weight: "regular", [Die vereinfachte Weir-Formel]))[
  #set text(size: 21pt)
  #v(16mm)
  #align(center)[#text(size: 30pt, weight: "bold")[Energieumsatz ≈ 8,19 × V̇CO₂ (ml/min)]]
  #v(12mm)
  #align(center)[170 ml/min → 1.392 kcal/Tag → bei 70 kg etwa 20 kcal/kg/Tag]
  #v(10mm)
  #align(center)[#text(size: 18pt, fill: rgb("#c00000"))[10 ml/min V̇CO₂ entsprechen ca. 82 kcal/Tag.]]
  #quelle([#cite(<stapel2015VentilatorderivedCarbonDioxide>, supplement: [S. 2–3, 9]);
    #cite(<weir1949NewMethodsCalculating>, supplement: [S. 1–2]).])
]
#slide(title: text(size: 22pt, weight: "regular", [Was steckt hinter RQ und FQ?]))[
  #set text(size: 17pt)
  // TODO: [AGENT] kannst Du statt der Box centered-items nehmen
  // NOTE: Die linke Textspalte verwendet jetzt die bestehende Hilfsfunktion centered-items.
  #grid(columns: (51%, 45%), gutter: 4%,
    [#centered-items(height: 101mm)[
      #set list(
        spacing: 2em,
        tight: false,
      )
      - *RQ = V̇CO₂ / V̇O₂:* Verhältnis von CO₂-Produktion und O₂-Verbrauch.
      - RQ: Kohlenhydrate 1,0\ 
        #h(11mm) Protein 0,8\
        #h(11mm) Fett 0,7.
      - *FQ* = "globaler RQ" für ein bestimmtes Ernährungspräparat.
    ]],
    [#image("bilder-latex/mcclave-2003-rq-p-21.png", width: 100%, height: 98mm, fit: "contain")],
  )
  #quelle([#cite(<stapel2015VentilatorderivedCarbonDioxide>, supplement: [S. 3, 9]);
  #linebreak()
    #cite(<kagan2018ValidationCarbonDioxide>, supplement: [S. 2]).])
]

#slide(title: text(size: 22pt, weight: "regular", [Wann ist eine V̇CO₂-Messung verwertbar?]))[
  #set text(size: 17pt)

  #centered-items(height: 105mm)[
    #grid(
      columns: (1fr, 1fr),
      gutter: 8mm,
      align: top + left,
      [
        #text(weight: "bold", fill: rgb("#15806f"))[verwertbar]
        #v(4mm)

        - stabile Beatmung
        - ruhige Situation ohne ausgeprägte Agitation
        - Verlauf über mehrere Minuten (mind. 5, besser 20 Min.)
      ],
      [
        #text(weight: "bold", fill: rgb("#c00000"))[Vorsicht/nicht verwertbar]
        #v(4mm)

        - gerade geänderte Ventilation oder hohe Leckage/Fistel
        - Fieber
        - RRT
        - nicht verwerten bei ECMO (außer Trial off)
      ],
    )
  ]
  #quelle([
    #cite(<rousing2016EnergyExpenditureCritically>, supplement: [S. 6, 9–10])
   #linebreak() 
    #cite(<singer2023ESPENPracticalPartially>, supplement: [S. 1678]).
  ])
]

#slide(title: text(size: 22pt, weight: "regular", [REE oder (T)EE: gleiche Zahl, andere Bedeutung]))[
  #set text(size: 18pt)
  // TODO: [AGENT] kannst Du statt der Box centered-items nehmen
  // NOTE: Beide Spalten werden als gemeinsamer Inhalt in der verfügbaren Höhe zentriert.
  #centered-items(height: 88mm)[
    #grid(columns: (1fr, 1fr), gutter: 10mm,
      [#text(weight: "bold")[Ruhephase]
       #v(5mm)
       Sedierung, wenig Bewegung → Messwert als *Ruheenergieumsatz (REE)* einordnen.],
      [#text(weight: "bold")[Aktiver Zeitraum]
       #v(5mm)
       Wachphasen, Mobilisation und Physiotherapie → Messwert nähert sich dem *tatsächlichen Energieverbrauch (EE/TEE)*.],
    )
  ]
  #v(5mm)
  #align(center)[#text(size: 20pt, fill: rgb("#c00000"))[Über aktive Stunden gemessenen Verbrauch nicht nochmals pauschal hochrechnen.]]
  #quelle([#cite(<stapel2015VentilatorderivedCarbonDioxide>, supplement: [S. 2])
  #linebreak()
    #cite(<rousing2016EnergyExpenditureCritically>, supplement: [S. 10]).])
]

// TODO: [AGENT] In der unteren Folie sind die Bullets nicht vertikal zentriert. 
// NOTE: Erledigt. Die Bullet-Liste ist innerhalb einer 105-mm-Textfläche vertikal zentriert.
#slide(title: text(size: 22pt, weight: "regular", [V̇CO₂: Messwert prüfen, bevor er benutzt wird]))[
  #set text(size: 18pt)
  #centered-items(height: 105mm)[#item-by-item[
    #set list(
    spacing: 2em,
    tight: false,
    )
    - Stabile Beatmung ist eine Voraussetzung.
    - Nach einer Änderung der Ventilation braucht V̇CO₂ etwa 10–20 Minuten bis zum neuen Gleichgewicht.
    - Mehrere Minuten mitteln; keinen Einzelwert als übernehmen.
    - Passt der Wert nicht zur klinischen Situation, zuerst die Messbedingungen prüfen.
  ]]
  #quelle([#cite(<rousing2016EnergyExpenditureCritically>, supplement: [Abb. 3, Tab. 4]);
    #linebreak()
    #cite(<singer2023ESPENPracticalPartially>, supplement: [S. 1678]).])
]

// 44 – Erkrankungsphasen
// Abschnittsfolie: Energieziele ändern sich mit der Erkrankungsphase.
#slide(title: text(size: 22pt, weight: "regular", [Erkrankungsphase]))[
  #box(width: 100%, height: 108mm)[
    #align(center + horizon)[#text(size: 29pt, weight: "bold")[Ändert sich das Ziel im Krankheitsverlauf?]]
  ]
]
#slide(title: text(size: 22pt, weight: "regular", [Ernährung: Zeitpunkt und Erkrankungsphase]))[
  #set text(size: 16pt)
  #place(
    top + left,
    dx: 105mm,
    dy: 0mm,
    rotate(
      0deg,
      reflow: false,
      image(
        bildpfad + "slide-044-ernaehrungsphasen-schema.png",
        width: 162mm,
        height: 110mm,
        fit: "contain",
      ),
    ),
  )
  #place(
    top + left,
    dx: 0mm,
    dy: 0mm,
    box(
      width: 100mm,
      height: 110mm,
      centered-items(
        item-by-item([
          #set list(
            spacing: 2em,
            tight: false,
          )
          - Akutphase (meist Tag 0-3):\
            · maximal 70--75 % des REE\
            · enterale Ernährung möglich 
          - nach Akutphase auf 100 % des Ziels steigern
          - Rekonvaleszenz auch mehr als 100 %
        ]),
      ),
    ),
  )
  #quelle([#cite(<singer2019ESPENGuidelineClinical>, supplement: [S. 53]);
    #linebreak()
    #cite(<elke2019DGEMS2kLeitlinieKlinische>, supplement: [S. 351–352, 361]).])
]

// Zusatzfolie – EPaNIC und Glukose in der Akutphase
// TODO: [USER] Folie überarbeiten
#slide(title: text(size: 22pt, weight: "regular", [EPaNIC: Glukose allein ist keine Ernährungsstrategie]))[
  #set text(size: 16pt)
  #centered-items(height: 105mm)[#item-by-item[
    - EPaNIC verglich frühe mit später zusätzlicher parenteraler Ernährung – keine reine Zuckerernährung mit vollständiger Ernährung.
    - Beide Gruppen sollten ab Tag 2 enteral ernährt werden. Früh: 20 % Glukose an Tag 1–2, ab Tag 3 parenterale Ergänzung; spät: 5 % Glukose zur Hydrierung, parenteral frühestens ab Tag 8.
    - Späte parenterale Ernährung: weniger neue Intensivinfektionen (22,8 % versus 26,2 %) und etwas frühere Entlassung; die Sterblichkeit war ähnlich.
    - Glukosekalorien mitzählen, aber eine Glukoseinfusion nicht als vollständige Ernährung behandeln. Das Kalorienziel in der Akutphase nicht reflexhaft mit früher Zusatzernährung auffüllen.
    - Bei parenteraler Ernährung in der Akutphase ein unausgewogenes kalorisches Glukose-/Aminosäuren-Verhältnis über 3:1 vermeiden.
    // TODO: [AGENT] zu dem KH AS verhältnis gibt es in der dgem leitlinie auch eine Referenz die ich auch in Zotero, habe aber ich habe die Aussage da so nicht drin gefunden, kannst Du da bitte einmal schauen
    // NOTE: Geprüft in Elke et al. 2019, S. 392, Abschnitt 8.4.6, Empfehlung 52A. Die Aussage bezieht sich ausdrücklich auf die akute parenterale Ernährung; die Formulierung oben ist entsprechend präzisiert.
    // TODO: [USER] noch mal selbst gucken
  ]]
  #quelle([#cite(<casaer2011EarlyLateParenteral>, supplement: [S. 506, 508, 511–512]);
    #linebreak()
    #cite(<singer2023ESPENPracticalPartially>, supplement: [S. 1678–1679]);
    #linebreak()
    #cite(<elke2019DGEMS2kLeitlinieKlinische>, supplement: [S. 392, Empfehlung 52A]).])
]


// 46 – Rekonvaleszenz
#slide(title: text(size: 22pt, weight: "regular", [Ernährung in der Rekonvaleszenz]))[
  #set text(size: 18pt)
  #place(
    top + left,
    dx: 0mm,
    dy: 0mm,
    rotate(
      0deg,
      reflow: false,
      image(
        bildpfad + "slide-046-zielgerichtete-ernaehrung-krankheitsphasen.png",
        width: 140mm,
        height: 113mm,
        fit: "contain",
      ),
    ),
  )
  #place(
    top + left,
    dx: 140mm,
    dy: 0mm,
    rotate(
      0deg,
      reflow: false,
      image(
        bildpfad + "slide-046-propofol-ernaehrung-krankheitsphasen.png",
        width: 140mm,
        height: 113mm,
        fit: "contain",
      ),
    ),
  )
  #quelle([Wischmeyer, ISICEM 2017;
    #linebreak()
    #cite(<wischmeyer2016AreWeCreating>, supplement: [S. 281]).])
]

// 20 – Makronährstoffe
// #slide(title: text(size: 22pt, weight: "regular", [Anteile der Makronährstoffe]))[
//   #set text(size: 18pt)
//   #place(
//     top + left,
//     dx: 27mm,
//     dy: 2mm,
//     rotate(
//       0deg,
//       reflow: false,
//       image(
//         bildpfad + "slide-020-makronaehrstoffverteilung-vergleich.png",
//         width: 215mm,
//         height: 115mm,
//         fit: "contain",
//       ),
//     ),
//   )
//   #quelle([Vergleichsdiagramm: #link("https://malen-mit-kindern.blogspot.com/2019/11/tagliche-nahrungsaufnahme-diagramm.html")[Malen mit Kindern] (Stand 30.01.2023).])
// ]
//
//
// Abschnittsfolie: vom Energieziel zur tatsächlich zugeführten Ernährung.
#slide(title: text(size: 22pt, weight: "regular", [Ernährung zuführen]))[
  #box(width: 100%, height: 108mm)[
    #align(center + horizon)[#text(size: 29pt, weight: "bold")[Was kommt tatsächlich bei Patient:innen an?\ & \
  Nicht ernährungsbedingte Kalorien.]]
  ]
]
#slide(title: text(size: 22pt, weight: "regular", [Ernährung: Rechnung mit 1 kcal/ml]))[
  #set text(size: 17pt)
// TODO: [AGENT] Hier möchte ich das als letztes ein schönes Bild erscheint in einer rechten Spalte das Easy ausdrückt, bitte die Quelle in das Bild einfügen
// NOTE: Eine eigens erstellte Illustration erscheint im letzten Einblendschritt rechts; ihre Herkunft steht direkt am Bild.
  #grid(columns: (54%, 42%), gutter: 4%,
    [#centered-items(height: 105mm)[#item-by-item[
        #set list(
          spacing: 2em,
          // tight: false,
        )
    - Mann, 100 kg, 180 cm, BMI 30,9 kg/m²\
      → IBW 75 kg, EW 25 kg\  
      → ABW 20 % 80 kg\
      \= 1.920 kcal/Tag (24 kcal/kg)
    - 1.920 kcal/Tag ÷ 24 h = 80 ml/h
    ]]],
    [#uncover("3-", box(width: 100%, height: 103mm)[
      #image("./bilder-latex/where-is-waldo.png", width: 100%, height: 99mm, fit: "contain")
    ])],
  )
#quelle([
  #cite(<singer2023ESPENPracticalPartially>, supplement: [S. 1678])
  #linebreak()
  #link("https://www.cartoonstock.com/cartoon?searchID=CS633490")[CartoonStock]; Stand 08.11.2026
])
]

// 25 – praktische Einschränkungen
#slide(title: text(size: 22pt, weight: "regular", [Die praktische Rechnung ist komplexer]))[
  #set text(size: 18pt)
  #grid(
    columns: (57%, 39%),
    gutter: 4%,
    [
      #centered-items(item-by-item([
        #set list(
          spacing: 2em,
          tight: false,
        )
        - Viele enterale Präparate enthalten 1,5 kcal/ml statt 1,0 kcal/ml.
        - Die enterale Ernährung läuft im Beispiel 22–22,5 Stunden pro Tag.
        - Weitere Kalorienquellen: Glukose 5 % (NaCl frei), Propofol und Citratdialyse.
      ]))
    ],
    [
      #grid(
        columns: (1fr,),
        gutter: 2mm,
        row-gutter: 2mm,
        box(
          width: 100%,
          height: 87mm,
          align(
            center + horizon,
            bild(
              "slide-025-kenny-mccormick-traurig.png",
            ),
          ),
        ),
      )
    ],
  )
  #quelle([#cite(<elke2019DGEMS2kLeitlinieKlinische>, supplement: [S. 354])#text[;]
    #linebreak()
    #kennyQuelle (Stand 08.03.2023)])
]
// TODO: [USER] slide DGEM alle nicht ernährungsbedingte Kalorien reinrechnen, kurze Erwähnung dass es 2 unterschiedliche Propofol Formulationen gibt mit 50 % MCT und nur mit Soya
//
// TODO: [AGENT] ich hatte eine Folie hier drin (git) zur not wieder aus der Powerpoint holen die eine Rechnung gezeigt hat mit propofol g5% und ernährung was dann noch übrig bleibt
// NOTE: Die frühere Rechenfolie ist als gemeinsames Beispiel mit Enteral-, Propofol- und Glukosezufuhr wiederhergestellt.
// TODO: [AGENT] Die folgenden 3 Folien bitte zu einer Folie kondensieren, am Anfang sollen noch die Laufraten angegeben werden in Rot soll noch erscheinen dass das Eiweißziel noch eingehalten werden muss, desweren am Ende wieder den roten kenny von oben auch noch mal einfügen
// NOTE: Die drei Rechenschritte stehen nun auf einer Folie. Das Proteinziel und Kenny erscheinen nacheinander am Schluss.
#slide(title: text(size: 22pt, weight: "regular", [Zugeführte Kalorien: Was bleibt vom Ziel?]))[
  #set text(size: 16pt)
  #box(width: 190mm, height: 112mm)[
    #text(weight: "bold")[Laufraten: enteral 10 ml/h · Propofol 2 % 10 ml/h · G5 % 40 ml/h]
    #v(4mm)
    - Enteral: 10 × 1,5 kcal/ml × 22 h = *330 kcal/Tag*.
    - Propofol: 200 mg/h = 10 ml/h × 24 h × 1,03 kcal/ml ≈ *247 kcal/Tag*.
    - Glukose 5 %: 40 ml/h × 24 h × 0,2 kcal/ml = *192 kcal/Tag*.
    - Zusammen *769 kcal/Tag*
    - bei 1.920 kcal Ziel bleiben *1151 kcal/Tag* für die weitere Ernährung
    #v(4mm)
    #h(20mm) #uncover("2-", text(fill: rgb("#c00000"), weight: "bold")[Das Eiweißziel muss trotzdem separat erreicht werden.])
  ]
  #place(top + left, dx: 205mm, dy: 22mm,
    only("1-2", image(bildpfad + "slide-027-propofol-kaloriengehalt-dgem.png", width: 69mm, height: 80mm, fit: "contain")))
  #place(top + left, dx: 205mm, dy: 25mm,
    only("3-", image(bildpfad + "slide-025-kenny-mccormick-traurig.png", width: 69mm, height: 78mm, fit: "contain")))
  #quelle([#cite(<elke2019DGEMS2kLeitlinieKlinische>, supplement: [S. 354]);
    #cite(<dickerson2021ImpactPropofolSedation>, supplement: [S. 5]);
    #linebreak()
    Propofol: #cite(<2019PropofolBaxter20>, supplement: [S. 1, 5]); 
    #linebreak()
    // // TODO: [AGENT] kannst Du mir bei kenny als Quelle bitte die richtige Qelle anzeigen
    // NOTE: Die Bilddatei und die Signatur nennen Pedro4ba. Der Link führt zur überlieferten Blogspot-Bildkopie; eine Originalveröffentlichung ließ sich nicht verifizieren.
    Kenny: #kennyQuelle.])
]



// 38 – Beutel versus Einzelkomponenten
#slide(title: text(size: 22pt, weight: "regular", [Parenterale Ernährung: Dreikammerbeutel oder Einzelkomponenten]))[
  #set text(size: 15pt)
  #place(
    top + left,
    dx: 0mm,
    dy: 20mm,
    rotate(
      0deg,
      reflow: false,
      image(
        bildpfad + "slide-038-dreikammerbeutel-epicos-studie.png",
        width: 110mm,
        height: 25mm,
        fit: "contain",
      ),
    ),
  )
  #place(
    top + left,
    dx: 0mm,
    dy: 48mm,
    rotate(
      0deg,
      reflow: false,
      image(
        bildpfad + "slide-038-dreikammerbeutel-improve-studie.png",
        width: 110mm,
        height: 25mm,
        fit: "contain",
      ),
    ),
  )
  #place(
    top + left,
    dx: 135mm,
    dy: 0mm,
    rotate(
      0deg,
      reflow: false,
      image(
        bildpfad + "slide-038-dreikammerbeutel-dgem-empfehlung.png",
        width: 140mm,
        height: 38mm,
        fit: "contain",
      ),
    ),
  )
  #place(
    top + left,
    dx: 135mm,
    dy: 42mm,
    rotate(
      0deg,
      reflow: false,
      image(
        bildpfad + "slide-038-dreikammerbeutel-ueberernaehrung.png",
        width: 130mm,
        height: 27mm,
        fit: "contain",
      ),
    ),
  )
  #place(
    top + left,
    dx: 0mm,
    dy: 74mm,
    box(
      width: 275mm,
      height: 45mm,
      centered-items(
        item-by-item([
          - Dreikammerbeutel: in der zitierten Studie mit weniger Infektionen assoziiert.
          - Festes Verhältnis: 15 % Aminosäuren, 47 % Kohlenhydrate, 38 % Fette.
          - Bei hohen Kalorienmengen kann die Substratverteilung problematisch werden.
        ]),
      ),
    ),
  )
  #quelle([#cite(<elke2019DGEMS2kLeitlinieKlinische>, supplement: [S. 381])#text[;]
    #linebreak()
    EPICOS und IMPROVE in der Ausgangspräsentation.])
]


// TODO: [AGENT] hier sind gar keinee Folien zu enteraler Ernährung, welche schlägst Du vor?
// NOTE: Vor dem Intoleranzblock stehen nun ein kurzer Abschnittstitel und eine Einstiegsfolie zu Beginn, Applikationsweg und Aufbau der enteralen Ernährung; die bestehenden Folien bleiben in ihrer Reihenfolge.
#slide(title: text(size: 22pt, weight: "regular", [Enterale Ernährung]))[
  #box(width: 100%, height: 108mm)[
    #align(center + horizon)[#text(size: 29pt, weight: "bold")[Wenn der Darm funktioniert: wann und wie beginnen?]]
  ]
]
#slide(title: text(size: 22pt, weight: "regular", [Enterale Ernährung: der praktische Start]))[
  #set text(size: 18pt)
  #centered-items(height: 105mm)[
    #set list(spacing: 2em, tight: false)
    - Wenn orale Ernährung nicht möglich ist, enteral möglichst *innerhalb von 48 Stunden* beginnen.
    - Für den Start ist die *gastrale Sonde* der Standard; die Nahrung *kontinuierlich* statt als Bolus geben.
    - Nach Kreislaufstabilisierung die Zufuhr *schrittweise steigern* und die tatsächlich verabreichte Menge täglich prüfen.
  ]
  #quelle([#cite(<singer2023ESPENPracticalPartially>, supplement: [S. 1674–1676, Empfehlungen 6–7, 14–15]);
    #linebreak()
    #cite(<elke2019DGEMS2kLeitlinieKlinische>, supplement: [S. 354]).])
]

// Abschnittsfolie: Umgang mit enteraler Intoleranz.
#slide(title: text(size: 22pt, weight: "regular", [Enterale Intoleranz]))[
  #box(width: 100%, height: 108mm)[
    #align(center + horizon)[#text(size: 29pt, weight: "bold")[Was tun, wenn enterale Ernährung nicht ankommt?\ \ Gastrales Residualvolumen (GRV *≠* Reflux)]]
  ]
]

#slide(title: text(size: 22pt, weight: "regular", [Magenrestvolumen (GRV): klinisch einordnen]))[
  #set text(size: 17pt)
  #centered-items(height: 105mm)[#item-by-item[
    - GRV beschreibt den Mageninhalt; Regurgitation und Erbrechen sind eigene Zeichen einer Intoleranz.
  // TODO: [AGENT] hier bitte etwas genauer von wem die Studie war wieviele pat.
  // NOTE: Reignier et al. 2013 und die Patientenzahl sind im nächsten Punkt genannt.
    
    - Reignier et al. 2013: 452 beatmete Erwachsene an neun französischen Intensivstationen randomisiert. #underline[Ohne] Routine-GRV-Messung war die Rate von VAPs #underline[nicht] höher; Erbrechen war häufiger.
    - ESPEN: Bei GRV > 500 ml in 6 h akute abdominelle Probleme ausschließen und Prokinetikum erwägen
    - GRV ≥ 800 ml (bei Messung 1x/Tag) Laufrate auf letzte verträgliche reduzieren
    - Bei anhaltend hohem GRV trotz Maßnahmen: postpylorische Ernährung erwägen.
  ]]
  #quelle([#cite(<reignier2013EffectNotMonitoring>, supplement: [S. 249–256]);
    #linebreak()
    #cite(<singer2023ESPENPracticalPartially>, supplement: [S. 1686]);
    #cite(<tarcukovic2022MyEvidencebasedNutrition>, supplement: [ab 14:20 min]).])
]
// TODO: [USER] Bild GRV Pneumonien
// 42 – Prokinetika
#slide(title: text(size: 22pt, weight: "regular", [Wenn enterale Ernährung nicht klappt: Prokinetika]))[
  #set text(size: 15pt)
  #place(
    top + left,
    dx: 135mm,
    dy: 0mm,
    rotate(
      0deg,
      reflow: false,
      image(
        bildpfad + "slide-042-metoclopramid-dosis.png",
        width: 130mm,
        height: 23mm,
        fit: "contain",
      ),
    ),
  )
  #place(
    top + left,
    dx: 135mm,
    dy: 25mm,
    rotate(
      0deg,
      reflow: false,
      image(
        bildpfad + "slide-042-erythromycin-dosis.png",
        width: 130mm,
        height: 23mm,
        fit: "contain",
      ),
    ),
  )
  #place(
    top + left,
    dx: 135mm,
    dy: 50mm,
    rotate(
      0deg,
      reflow: false,
      image(
        bildpfad + "slide-042-erythromycin-wirksamkeit-nach-drei-tagen.png",
        width: 130mm,
        height: 20mm,
        fit: "contain",
      ),
    ),
  )
  #place(
    top + left,
    dx: 135mm,
    dy: 72mm,
    rotate(
      0deg,
      reflow: false,
      image(
        bildpfad + "slide-042-prokinetika-wirksamkeit-vergleich.png",
        width: 130mm,
        height: 35mm,
        fit: "contain",
      ),
    ),
  )
  #place(
    top + left,
    dx: 0mm,
    dy: 0mm,
    box(
      width: 130mm,
      height: 112mm,
      centered-items(
        item-by-item([
        #set list(
          spacing: 3em,
          tight: false,
        )
          
          - Bei gastraler Ernährungsintoleranz empfiehlt ESPEN Erythromycin i.v. als erstes Prokinetikum.
          - Metoclopramid i.v. ist eine Alternative; beide Wirkstoffe können kombiniert werden.
          - Die Wirkung lässt nach etwa 72 Stunden häufig nach.
          - MCP bei Niereninsuffizienz nach *Kreatinin-Clearance* dosieren: >15–60 ml/min → Dosis −50 %; ≤15 ml/min → Tagesdosis −75 %.
          // // TODO: [AGENT] Bitte gib zur MCP eGFR Anpassung die dosing referenz an auch im prokinetika gmics
          // NOTE: Die Fachinformation der i.v.-Lösung nennt Kreatinin-Clearance statt eGFR; die beiden Dosisreduktionen stehen jetzt auf der Folie und in den Prokinetika-Notizen.
        ]),
      ),
    ),
  )
  #quelle([#cite(<elke2019DGEMS2kLeitlinieKlinische>, supplement: [S. 376]);
    #linebreak()
    #cite(<singer2023ESPENPracticalPartially>, supplement: [S. 1686]);
    #linebreak()
    #cite(<nguyen2007ErythromycinMoreEffective>, supplement: [S. 485]);
    #linebreak()
    MCP-Dosis: #link("https://www.ratiopharm.de/assets/products/de/label/MCP-ratiopharm%20SF%2010%20mg2%20ml%20Injektionslosung%20-%204.pdf?pzn=509407")[MCP-ratiopharm SF, Fachinformation, S. 2].])
]
// TODO: [USER] ggf hier noch eine Folie zu Nguyen Erythromycin 7 TAge
// 43 – postpylorische Sonde

// TODO: [USER] Bild Pneumonie GRV


#slide(title: text(size: 22pt, weight: "regular", [Wenn enterale Ernährung nicht klappt: postpylorisch]))[
  #set text(size: 15pt)
  #box(width: 100%, height: 105mm, align(center + horizon, grid(
    columns: (57%, 39%),
    gutter: 4%,
    [
      #centered-items(height: 87mm)[#item-by-item[
        #set list(
          spacing: 3em,
          tight: false,
        )

        - Postpylorische Ernährung erfolgt duodenal oder jejunal, zum Beispiel über eine nasojejunale Sonde.
        - weniger beatmungsassoziierte Pneumonien, jedoch kein Unterschied bei Sterblichkeit, Beatmungsdauer oder Intensivaufenthalt.
        - Erwägen bei hohem Aspirationsrisiko oder anhaltend hohem Magenrestvolumen trotz Prokinetika.
      ]]
    ],
    [
      #grid(
        columns: (1fr,),
        gutter: 2mm,
        row-gutter: 2mm,
        box(
          width: 100%,
          height: 87mm,
          align(
            center + horizon,
            bild(
              "slide-043-postpylorische-sonde-roentgenbild.png",
            ),
          ),
        ),
      )
    ],
  )))
  #quelle([#cite(<singer2023ESPENPracticalPartially>, supplement: [S. 1676–1677, 1686]);
    #linebreak()
    #cite(<reintamblaser2012GastrointestinalFunctionIntensive>, supplement: [S. 388])#text[;]
    #linebreak()
    Röntgenbild: #link("https://radiologykey.com/wp-content/uploads/2016/03/B978032308902900005X_f005-022b-9780323089029.jpg")[Radiology Key] (Stand 12.03.2023).])
]

// Zusatzfolie – enterale Ernährung in Bauchlage
#slide(title: text(size: 22pt, weight: "regular", [Enterale Ernährung ist auch in Bauchlage möglich]))[
  #set text(size: 16pt)
  #grid(columns: (53%, 43%), gutter: 4%,
    [#centered-items(height: 105mm)[#item-by-item[
        #set list(
          spacing: 2em,
          tight: false,
        )
// TODO: [AGENT] Bitte such ein witziges Bild für eine Bauchlage das in eine rechte Spalte soll, dann bitte Quelle angeben
// NOTE: Eine eigene humorvolle Illustration steht rechts; ihre Herkunft ist am Bild und in der Quellenzeile angegeben.
      // TODO: [USER] Bild Clamshall Prone
    - Bei funktionierendem Gastrointestinaltrakt die enterale Ernährung wegen der Bauchlage allein nicht unterbrechen.
    - Das Bett, sofern der Kreislauf es erlaubt, in Oberkörperhochlage bringen; auf Regurgitation und Erbrechen achten.
    - Prokinetika ggf. direkt bei Bauchlage beginnen - postpylorische Sonde erwägen.
    ]]],
    [#image(bildpfad + "slide-047-bauchlage-ernaehrung-illustration.png", width: 100%, height: 95mm, fit: "contain")
     #align(center)[#text(size: 8pt)[Eigene KI-Illustration · 2026]]],
  )
  #quelle([#cite(<elke2019DGEMS2kLeitlinieKlinische>, supplement: [S. 372]);
    #linebreak()
    #cite(<singer2023ESPENPracticalPartially>, supplement: [S. 1674–1675, 1686]);
    #linebreak()
    #cite(<bruni2020NursingIssuesEnteral>, supplement: [Abschn. 3–4]); Bild: eigene KI-Illustration.])
]
// Zusatzfolien – Enterale Ernährung und gastrales Residualvolumen
#slide(title: text(size: 22pt, weight: "regular", [Enterale Ernährung: Kernpunkte für den Alltag]))[
  #set text(size: 18pt)
  #centered-items(height: 105mm)[#item-by-item[
    - Bei stabilem Kreislauf und funktionierendem Darm früh enteral beginnen; die Zufuhr schrittweise steigern.
    - Magenrestvolumen (GRV) ist nicht gleich Reflux oder Aspiration: Erbrechen und abdominelle Zeichen mitbeurteilen.
    - Bauchlage allein ist kein Grund, die enterale Ernährung zu stoppen.
    - Bei gastraler Intoleranz Ursache prüfen; Prokinetikum und gegebenenfalls postpylorischen Zugang erwägen.
  ]]
  #quelle([#cite(<singer2023ESPENPracticalPartially>, supplement: [S. 1674–1676, 1686]);
    #linebreak()
    #cite(<elke2019DGEMS2kLeitlinieKlinische>, supplement: [S. 371–372]).])
]

// 48 – Phosphat
// Abschnittsfolie: tägliche Neubewertung der Ernährung.
#slide(title: text(size: 22pt, weight: "regular", [Ernährung täglich anpassen]))[
  #box(width: 100%, height: 108mm)[
    #align(center + horizon)[#text(size: 29pt, weight: "bold")[Wann müssen wir die Ernährung anpassen?]]
  ]
  // TODO: [AGENT] steuern ist kein so passendes wort für mich hast Du eine Alternative
  // NOTE: „Ernährung täglich anpassen“ ist konkreter und passt zur Leitfrage des Vortrags.
]
#slide(title: text(size: 22pt, weight: "regular", [Phosphat als Signal bei der Ernährungssteuerung]))[
  #set text(size: 15pt)
  #place(
    top + left,
    dx: 0mm,
    dy: 0mm,
    rotate(
      0deg,
      reflow: false,
      image(
        bildpfad + "slide-048-phosphatgesteuerte-ernaehrung-schema.png",
        width: 150mm,
        height: 80mm,
        fit: "contain",
      ),
    ),
  )
  #place(
    top + left,
    dx: 190mm,
    dy: 0mm,
    rotate(
      0deg,
      reflow: false,
      image(
        bildpfad + "slide-048-phosphat-killer-verpackung.png",
        width: 80mm,
        height: 50mm,
        fit: "contain",
      ),
    ),
  )
  #place(
    top + left,
    dx: 190mm,
    dy: 50mm,
    rotate(
      0deg,
      reflow: false,
      image(
        bildpfad + "slide-048-insulingesteuerte-ernaehrung-schema.png",
        width: 80mm,
        height: 20mm,
        fit: "contain",
      ),
    ),
  )
  #place(
    top + left,
    dx: 0mm,
    dy: 84mm,
    box(
      width: 275mm,
      height: 35mm,
      centered-items(
        item-by-item([
          - *Bei Phosphat < 0,65 mmol/l wird die Energiezufuhr auf ca. 25 % reduziert*.
          - ESPEN 2023 nennt bei Refeeding-Hypophosphatämie auch einen *relativen Phosphatabfall > 0,16 mmol/l*.
          - Phosphat als Surrogatparameter für Überernährung funktioniert nicht bei RRT - es sei denn es ist Pausentag.
        ]),
      ),
    ),
  )
  #quelle([#cite(<elke2019DGEMS2kLeitlinieKlinische>, supplement: [S. 361])#text[;]
    #linebreak()
    #cite(<singer2023ESPENPracticalPartially>, supplement: [S. 1686, Empfehlung 58])#text[;]
    #linebreak()
    Produktbild: #link("https://www.ebay.de/itm/Hobby-Phosphat-Killer-entfernt-PO4-Anti-Algen-Wuchs-800-g-54510-/191394845136")[eBay] (Stand 13.03.2023).])
]

// 49 – Insulin
#slide(title: text(size: 22pt, weight: "regular", [Insulinresistenz als Signal]))[
  #set text(size: 15pt)
  #place(
    top + left,
    dx: 0mm,
    dy: 0mm,
    rotate(
      0deg,
      reflow: false,
      image(
        bildpfad + "slide-049-ernaehrungsschema-nierenersatz-einschraenkung.png",
        width: 170mm,
        height: 75mm,
        fit: "contain",
      ),
    ),
  )
  #place(
    top + left,
    dx: 140mm,
    dy: 0mm,
    rotate(
      0deg,
      reflow: false,
      image(
        bildpfad + "slide-049-insulinziel-blutzucker-unter-180.png",
        width: 135mm,
        height: 20mm,
        fit: "contain",
      ),
    ),
  )
  #place(
    top + left,
    dx: 185mm,
    dy: 25mm,
    rotate(
      0deg,
      reflow: false,
      image(
        bildpfad + "slide-049-apfel-insulinspritze-und-zucker.png",
        width: 90mm,
        height: 55mm,
        fit: "contain",
      ),
    ),
  )
  #place(
    top + left,
    dx: 0mm,
    dy: 80mm,
    box(
      width: 275mm,
      height: 40mm,
      centered-items(
        item-by-item([
          - *Angestrebte Blutzuckerkonzentration: < 180 mg/dl.*
          - Bei Insulinperfusor > 4 IE/h und BZ > 180 mg/dl Substratzufuhr reduzieren 
          - Bei Diabetes den vorbestehenden Insulinbedarf berücksichtigen.
        ]),
      ),
    ),
  )
  #quelle([#cite(<elke2019DGEMS2kLeitlinieKlinische>, supplement: [S. 360])#text[;]
    #linebreak()
    Apfelbild: #link("https://pixabay.com/de/insulinspritze-insulin-diabetes-1972843/")[Pixabay] (Stand 13.03.2023).])
]

// 52 – Nierenersatzverfahren
#slide(title: text(size: 22pt, weight: "regular", [Ernährung und Nierenersatzverfahren]))[
  #set text(size: 14pt)
  #place(
    top + left,
    dx: 145mm,
    dy: 5mm,
    rotate(
      0deg,
      reflow: false,
      image(
        bildpfad + "slide-052-aminosaeureverlust-bei-crrt.png",
        width: 125mm,
        height: 27mm,
        fit: "contain",
      ),
    ),
  )
  #place(
    top + left,
    dx: 145mm,
    dy: 65mm,
    rotate(
      0deg,
      reflow: false,
      image(
        bildpfad + "slide-052-citratdialyse-energiezufuhr.png",
        width: 125mm,
        height: 27mm,
        fit: "contain",
      ),
    ),
  )
  #place(
    top + left,
    dx: 0mm,
    dy: 0mm,
    box(
      width: 140mm,
      height: 113mm,
      centered-items(
        item-by-item([
          #set list(
          spacing: 2em,
          tight: false,
          ) 
          - Kontinuierliche Hämofiltration: etwa 0,2 g Aminosäuren pro Liter Filtrat.
          - Kontinuierliche Hämodialyse: etwa 0,6 g Aminosäuren pro Stunde.
          - Beispiel 22 h CVVHD: 13,2 g Aminosäuren ≈ 132 ml einer 10-%-Lösung.
          - Auch Citrat trägt zur Energiezufuhr bei.
          - Bei RRT wasserlösliche Vitamine zusätzlich geben.
        ]),
      ),
    ),
  )
  #quelle([#cite(<druml1999MetabolicAspectsContinuous>, supplement: [S58]);
    #linebreak()
    #cite(<elke2019DGEMS2kLeitlinieKlinische>, supplement: [S. 354, 369, 394]).])
]

// 53 – ECMO
#slide(title: text(size: 22pt, weight: "regular", [Ernährung unter ECMO: Lipide]))[
  #set text(size: 15pt)
  #place(
    top + left,
    dx: 60mm,
    dy: 0mm,
    rotate(
      0deg,
      reflow: false,
      image(
        bildpfad + "slide-053-ecmo-lipide-komplikationen.png",
        width: 180mm,
        height: 33mm,
        fit: "contain",
      ),
    ),
  )
  #place(
    top + left,
    dx: 0mm,
    dy: 64mm,
    rotate(
      0deg,
      reflow: false,
      image(
        bildpfad + "slide-053-ecmo-lipide-empfehlung.png",
        width: 130mm,
        height: 48mm,
        fit: "contain",
      ),
    ),
  )
  #place(
    top + left,
    dx: 140mm,
    dy: 64mm,
    rotate(
      0deg,
      reflow: false,
      image(
        bildpfad + "slide-053-ecmo-lipide-infusionsweg.png",
        width: 135mm,
        height: 42mm,
        fit: "contain",
      ),
    ),
  )
  #place(
    top + left,
    dx: 0mm,
    dy: 35mm,
    box(
      width: 275mm,
      height: 25mm,
      centered-items(
        item-by-item([
          - *Lipide müssen auch unter ECMO bedarfsgerecht zugeführt werden.*

          - Die gezeigte Empfehlung behandelt den Infusionsweg und mögliche Interaktionen mit dem ECMO-Kreislauf.
        ]),
      ),
    ),
  )
  #quelle([#cite(<elke2019DGEMS2kLeitlinieKlinische>, supplement: [S. 403]).])
]


// TODO: [AGENT] Hier bitte einen neuen Abschnitt mir Mikronährstoffen, danach eine Folie zu den Vitaminen und Spurenelementen, dass wenn die enterale Ernährung nicht 1500 kcal/Tag sind die gegeben werden sollen. steht im gmics ernährung und kommt von DGEM, Am Ende die Frage was tun wenn die Zielernährung bei jemandem < 1500 kcal ist. Dilemma das für Vitamine und Spurenelemente oft ein Tagesbedarf angegeben wird der nicht Körpergewichtsabhängig ist. Trotzdem in rot erwähnen das Spurenelemente und Vitamine immer substituiert wercen sollte wenn die enterale Ernährung nicht > 1500 oder 100% des Ziels entspricht. noch erwähnen das im Cernevit und 3-Kammerbeuteln kein Vitamin K drin ist wg Phenprocoumon Pat. Vitamin K ggf. extra ergänzen
// NOTE: Abschnitt und Überblicksfolie ergänzt. Die 1.500-kcal-Schwelle ist als Richtwert für typische enterale Produkte ausgewiesen; Vitamin K und Vitamin-K-Antagonisten werden gesondert berücksichtigt.
#slide(title: text(size: 22pt, weight: "regular", [Mikronährstoffe]))[
  #box(width: 100%, height: 108mm)[
    #align(center + horizon)[#text(size: 29pt, weight: "bold")[Deckt die Ernährung auch Vitamine und Spurenelemente?]]
  ]
]
#slide(title: text(size: 22pt, weight: "regular", [Vitamine und Spurenelemente: mitrechnen]))[
  #set text(size: 17pt)
// TODO: [AGENT] kannst Du die Aufzählung bitte mit centered items machen
// NOTE: Aufzählung und roter Merksatz stehen jetzt gemeinsam vertikal zentriert.
  #centered-items(height: 105mm)[
    #set list(spacing: 2em, tight: false)
    - Typische enterale Lösungen decken den Tagesbedarf laut DGEM bei etwa *1.500 kcal/Tag*.
    - Enterale Zielernährung < 1.500 kcal/Tag? Viele Mikronährstoffziele gelten als Tagesmengen und sind nicht gewichtsbezogen.
    - Bei hauptsächlicher parenteraler Ernährung Vitamine und Spurenelemente *immer* ergänzen.
    - Cernevit enthält *kein Vitamin K*. Bei Bedarf separat geben.
    #v(4mm)
    #align(center)[#text(size: 18pt, weight: "bold", fill: rgb("#c00000"))[Unter 1.500 kcal/Tag enteral: Vitamine und Spurenelemente ergänzen.]]
  ]
  #quelle([#cite(<elke2019DGEMS2kLeitlinieKlinische>, supplement: [S. 393–394, Empfehlungen 53–54]);
    #cite(<CernevitFachinformation>, supplement: [S. 1, 3]).])
]

// 39 – Mikronährstoffe
#slide(title: text(size: 22pt, weight: "regular", [Mikronährstoffe: Thiamin und Vitamin D]))[
  #set text(size: 15pt)
  #place(
    top + left,
    dx: 140mm,
    dy: 0mm,
    rotate(
      0deg,
      reflow: false,
      image(
        bildpfad + "slide-039-espen-mikronaehrstoffe-leitlinie.png",
        width: 128mm,
        height: 40mm,
        fit: "contain",
      ),
    ),
  )
  #place(
    top + left,
    dx: 0mm,
    dy: 84mm,
    rotate(
      0deg,
      reflow: false,
      image(
        bildpfad + "slide-039-espen-thiamin-empfehlung.png",
        width: 128mm,
        height: 28mm,
        fit: "contain",
      ),
    ),
  )
  #place(
    top + left,
    dx: 0mm,
    dy: 0mm,
    box(
      width: 135mm,
      height: 80mm,
      centered-items(
        item-by-item([
#set list(spacing: 2.1em, tight: false)
          - Thiamin (Vitamin B1): Bei Aufnahme auf die Intensivstation nach ESPEN *100–300 mg/Tag i.v. für 3–4 Tage* geben.
          - Cernevit = *3,51 mg Thiamin/Flasche*; für die initiale 100–300-mg-Gabe allein nicht ausreichend.
          - Vitamin D: Substitution und Dosierung an einem nachgewiesenen Mangel ausrichten.
        ]),
      ),
    ),
  )
  #quelle([#cite(<berger2024ESPENPracticalShort>, supplement: [S. 842–843, Empfehlung 148]);
    #linebreak()
    #cite(<CernevitFachinformation>, supplement: [S. 1]).])
]

// TODO: [AGENT] Bitte hier noch eine Folie zu Zink, müsste auch in dem gmics ernährung sein, dass es immunmodulatorisch ist, aber Albuminkorrigiert werden muss bitte erwähnen und angeben wieviel Zink auch in Addel ist bezogen auf den Tagesbedarf (Addel ist in Zotero)
// NOTE: Zinkfunktion, Grenzen des Plasmawerts und Addel-Dosis sind anhand der ESPEN-Leitlinie und Fachinformation ergänzt. Die Albuminkorrektur ist ein Interpretationshinweis, kein validierter ICU-Grenzwert.
#slide(title: text(size: 22pt, weight: "regular", [Zink: Bedarf und Interpretation]))[
  #set text(size: 17pt)
  // TODO: [AGENT] bitte als centered items
  // NOTE: Die drei Aussagen stehen jetzt als gemeinsamer Block vertikal zentriert.
  #centered-items(height: 105mm)[
    #set list(spacing: 2em, tight: false)
    - Zink ist unter anderem für Immunfunktion und Wundheilung erforderlich.
    - Ein niedriger Plasma-Zinkwert bei niedrigem Albumin beweist allein keinen Mangel. Zinkwert mit Albuminkorrektur berechnen.
    - *Addel 10 ml* enthält *6,5 mg elementares Zink* (aus 13,6 mg Zinkchlorid). Das liegt über der üblichen parenteralen Erhaltungszufuhr von *3–5 mg/Tag*; bei Verlusten kann der Bedarf höher sein.
  ]
  #quelle([#cite(<berger2024ESPENPracticalShort>, supplement: [S. 842])
#linebreak()  
  #cite(<AddelFachinformation>, supplement: [S. 1])
#linebreak()
  #cite(<jorgensen2022AlbumincorrectedZnAvailable>).])
]

// TODO: [AGENT] Bitte noch eine kurze Folie zu der alpha linolensäure, dass sie essentiell sind und wichtig, aber auch in Propofol enthalten ist, steht in den gmics allgemein, aber auch in der DGEM Leitlinie. Bitte noch mal berechnen ab wieviel Propofol 2% genügend Alpha Linolensäure vorhanden ist
// NOTE: Die Beispielrechnung nutzt jetzt 1.920 kcal/Tag. Der ältere ALA-Richtwert und die angenommene Sojaöl-Zusammensetzung bleiben als Annahmen gekennzeichnet.
// TODO: [AGENT] Bitte rechnung mit 1920 kcal pro Tag und etwas einfacher verständlich
// NOTE: Drei Rechenschritte ergeben gerundet 0,53 g ALA/Tag und 213 ml Propofol 2 %/Tag, also 9 ml/h bzw. 180 mg/h.

#slide(title: text(size: 22pt, weight: "regular", [Essenzielle α-Linolensäure: Propofol mitrechnen]))[
  #set text(size: 16pt)
  // TODO: [AGENT] bitte als centered items
  // NOTE: Aussagen, drei Rechenschritte und der Sicherheitshinweis sind jetzt als ein Block vertikal zentriert.
  #centered-items(height: 105mm)[
    #set list(spacing: 1.45em, tight: false)
    - α-Linolensäure (ALA) ist essenziell. Propofol 2 % mit Sojaöl liefert ebenfalls ALA.
    - *Bedarf im Beispiel:* 1.920 kcal × 0,25 % = 4,8 kcal aus ALA = *0,53 g/Tag* (älterer Richtwert).
    - *Gehalt im Beispiel:* 50 mg Sojaöl/ml × angenommene 5 % ALA = *2,5 mg ALA/ml*.
    - *Benötigte Menge:* 533 mg ÷ 2,5 mg/ml ≈ *213 ml/Tag* = *9 ml/h* Propofol 2 % (≈ *180 mg/h*).
    #v(2mm)
    #align(center)[#text(size: 16pt, weight: "bold", fill: rgb("#c00000"))[Nur eine Nährstoffrechnung – keine Sedierungsdosis.]]
  ]
  #quelle([#cite(<mirtallo2004SafePracticesParenteral>, supplement: [S53]);
    #cite(<2019PropofolBaxter20>, supplement: [S. 1]);
    #cite(<2021LipofundinMCT20>, supplement: [S. 1–2]).])
]
// 54 – orale Aufnahme
#slide(title: text(size: 22pt, weight: "regular", [Mythos: Sondenernährung nimmt den Hunger]))[
  #set text(size: 16pt)
  #place(
    top + left,
    dx: 5mm,
    dy: 0mm,
    rotate(
      0deg,
      reflow: false,
      image(
        bildpfad + "slide-054-orale-aufnahme-appetit-tabelle.png",
        width: 270mm,
        height: 70mm,
        fit: "contain",
      ),
    ),
  )
  #place(
    top + left,
    dx: 0mm,
    dy: 78mm,
    box(
      width: 275mm,
      height: 40mm,
      centered-items(
        item-by-item([
          - Die dargestellte Untersuchung vergleicht Appetit und orale Aufnahme mit und ohne Sondenernährung.
          - Die Ausgangsfolie zeigt keine einfache Gleichsetzung von Sondenernährung und fehlendem Appetit.
          - N = 45; Appetitmessung auf einer 10-cm-Skala.
        ]),
      ),
    ),
  )
  #quelle([#cite(<rowles2016SUNP019OralIntake>, supplement: [S51]).])
]

// 55 – Zusammenfassung
#slide(title: text(size: 22pt, weight: "regular", [Zusammenfassung: Du bist was Du isst.]))[
  #set text(size: 16pt)
  #centered-items(item-by-item([
    - *Ernährung täglich neu bewerten:* Phase, Bedarf, Verträglichkeit und tatsächlich zugeführte Energie ändern sich.
    - Bei *valider V̇CO₂-Messung* in der akuten Phase zunächst etwa *70–75 %* des geschätzten Energieumsatzes anstreben; Propofol, Glukose und Citrat mitzählen.
    - Bei *PICS und Rekonvaleszenz* bedarfsdeckend ernähren, mindestens *100 % des aktuellen Bedarfs* anstreben und das Proteinziel gesondert prüfen.
    - Ziel und Laufrate morgen anhand von Verlauf, Phosphat, Insulinbedarf und gastrointestinaler Verträglichkeit anpassen.
  ]))
  #quelle([#cite(<elke2019DGEMS2kLeitlinieKlinische>, supplement: [S. 354, 361, Empfehlungen 9A, 10–11]);
    #cite(<singer2023ESPENPracticalPartially>, supplement: [S. 1678]).])
]

// 56 – Abschluss
#slide(title: text(size: 22pt, weight: "regular", [Vielen Dank für die Aufmerksamkeit!]))[
  #set text(size: 18pt)
  #place(
    top + left,
    dx: 60mm,
    dy: 0mm,
    rotate(
      0deg,
      reflow: false,
      image(
        bildpfad + "slide-056-homer-simpson-daumen-hoch.png",
        width: 180mm,
        height: 100mm,
        fit: "contain",
      ),
    ),
  )
  #place(
    top + left,
    dx: 0mm,
    dy: 102mm,
    box(
      width: 275mm,
      height: 18mm,
    )[
        #align(center)[
          #v(1em)
        golo-sung.haarmeyer\@klinikum-nuernberg.de
      ]
    ],
  )

  #place(
    top + left,
    hide(
      bibliography(
        "/Users/g/Library/texmf/bibtex/bib/Zotero.bib",
        style: "touying-cite.csl",
        full: false,
      ),
    ),
  )

  #quelle([Quelle: #link("http://www.youtube.com/watch?v=wCNpZF6EkPA") (Stand 10.10.2022)])
]

// ============================================================
// RESERVEFOLIEN – nach der Schlussfolie für Rückfragen
// ============================================================

// 03 – Unterschiedliche Vorstellungen von Ernährung
#slide(title: text(size: 22pt, weight: "regular", [Ernährung: Schwieriges Thema in der Intensivmedizin?]))[
  #set text(size: 18pt)
  #place(
    top + left,
    dx: 3mm,
    dy: 14mm,
    rotate(
      -9deg,
      reflow: false,
      image(
        bildpfad + "slide-003-cheeseburger-mit-pommes.png",
        width: 120mm,
        height: 62mm,
        fit: "contain",
      ),
    ),
  )
  #place(
    top + left,
    dx: 88mm,
    dy: 70mm,
    rotate(
      0deg,
      reflow: false,
      image(
        bildpfad + "slide-003-gourmetgericht-restaurant-bareiss.png",
        width: 95mm,
        height: 47mm,
        fit: "contain",
      ),
    ),
  )
  #place(
    top + left,
    dx: 182mm,
    dy: 16mm,
    rotate(
      15deg,
      reflow: false,
      image(
        bildpfad + "slide-003-tofu-packung.png",
        width: 95mm,
        height: 76mm,
        fit: "contain",
      ),
    ),
  )
  #quelle([Bildquellen (Stand 12.03.2023): #link("https://eatsmarter.de/rezepte/cheeseburger-mit-pommes-frites")[EatSmarter],
    #linebreak()
    #link("http://kuechenreise.com/2012/11/25/restaurant-bareiss-baiersbronn-d/")[Küchenreise],
    #linebreak()
    #link("https://www.tofulaedchen.de/start/tofu/")[Tofulädchen].])
]

// // 23 – Vergleich ohne Cartoon als Wiederholung
// //NOTE: Kürzungsvorschlag: Diese Wiederholung der BMI-Zielwerte aus Folien 21 und 22 auslassen; Folie 24 führt direkt zur praktischen Laufrate.
// #slide(title: text(size: 22pt, weight: "regular", [Ernährungsziele: BMI und Gewicht]))[
//   #set text(size: 18pt)
//   #centered-items(item-by-item([
//     - BMI < 30 kg/m²: 24 kcal pro kg aktuellem Körpergewicht
//     - BMI 30–50 kg/m²: 11–14 kcal pro kg aktuellem Körpergewicht
//     - Beispiel: 95 kg bei 180 cm → 2.280 kcal/Tag
//     - Beispiel: 100 kg bei 180 cm → 1.100–1.400 kcal/Tag
//   ]))
//   #quelle([#cite(<elke2019DGEMS2kLeitlinieKlinische>, supplement: [S. 352, 400]).])
// ]
//
// // 26 – parenterale Fertiglösungen
// #slide(title: text(size: 22pt, weight: "regular", [Rechnung: parenterale Nährstoffe]))[
//   #set text(size: 16pt)
//   #centered-items(item-by-item([
//     - Zentrale parenterale Ernährung: NuTRIflex Lipid plus novo mit 1,012 kcal/ml ≈ 1 kcal/ml.
//     - Periphere parenterale Ernährung: NuTRIflex Lipid peri novo mit 0,764 kcal/ml.
//     - Bei 1 kcal/ml entspricht die Stundenrate im 24-Stunden-Schema ungefähr dem Körpergewicht bei BMI < 30.
//     - Bei BMI 30–50 liegt sie im Beispiel ungefähr beim halben Körpergewicht.
//   ]))
//   #quelle([#cite(<2021NuTRIflexLipidNovo>, supplement: [S. 2]);
//     #linebreak()
//     #cite(<2021NuTRIflexLipidPeri>, supplement: [S. 2]).])
// ]
//
// // 30 – Einzelkomponenten, Ziel nach kg
// #slide(title: text(size: 22pt, weight: "regular", [Einzelkomponenten: Ziel nach Körpergewicht]))[
//   #set text(size: 15pt)
//   #centered-items(item-by-item([
//     - Bereits zugeführt: enteral 330 kcal, Propofol ungefähr 240 kcal und Glukose 5 % 192 kcal/Tag.
//     - Enteral darin: 15,8 g Aminosäuren, 12,8 g Fett und 40,5 g Kohlenhydrate.
//     - Aminosäurenziel: 1,2 g/kg = 120 g/Tag.
//     - Fettziel: 1,0 g/kg = 100 g/Tag.
//     - In der Ausgangsrechnung: Kohlenhydrate/Aminosäuren ≈ 2:1; Kohlenhydrate/Fett ≈ 42/58.
//   ]))
// ]
//
// // 31 – Ziel nach IBW
// #slide(title: text(size: 22pt, weight: "regular", [Einzelkomponenten: Ziel nach Idealgewicht]))[
//   #set text(size: 15pt)
//   #centered-items(item-by-item([
//     - Bereits zugeführt: enteral 330 kcal, Propofol ungefähr 240 kcal und Glukose 5 % 192 kcal/Tag.
//     - Aminosäurenziel: 1,8 g/kg IBW ≈ 127 g/Tag.
//     - Fettziel: 0,9 g/kg = 90 g/Tag.
//     - In der Ausgangsrechnung: Kohlenhydrate/Aminosäuren ≈ 1,1:1; Kohlenhydrate/Fett ≈ 50/50.
//   ]))
// ]
//
// // 32 – Bewertung derselben Rechnung
// #slide(title: text(size: 22pt, weight: "regular", [Einzelkomponenten: Energie und Substrate]))[
//   #set text(size: 16pt)
//   #place(
//     top + left,
//     dx: 0mm,
//     dy: 0mm,
//     rotate(
//       0deg,
//       reflow: false,
//       image(
//         bildpfad + "slide-032-kenny-mccormick-traurig.png",
//         width: 105mm,
//         height: 110mm,
//         fit: "contain",
//       ),
//     ),
//   )
//   #place(
//     top + left,
//     dx: 113mm,
//     dy: 10mm,
//     box(
//       width: 160mm,
//       height: 105mm,
//       centered-items(
//         item-by-item([
//           - Zielgrößen der Beispielrechnung: 127 g Aminosäuren und 90 g Fett pro Tag.
//           - Die Kombination der Komponenten kann schon bei 14 kcal/kg zur Überernährung führen.
//           - Energieziel und Ziel für Makronährstoffe müssen zusammen betrachtet werden.
//         ]),
//       ),
//     ),
//   )
//   #quelle([#kennyQuelle (Stand 08.03.2023).])
// ]
//
// // 33 – Alternative Aufteilung
// #slide(title: text(size: 22pt, weight: "regular", [Anderer Ansatz: 20/40/40]))[
//   #set text(size: 18pt)
//   #place(
//     top + left,
//     dx: 0mm,
//     dy: 63mm,
//     rotate(
//       -15deg,
//       reflow: false,
//       image(
//         bildpfad + "slide-033-kuchenstuecke.png",
//         width: 105mm,
//         height: 45mm,
//         fit: "contain",
//       ),
//     ),
//   )
//   #place(
//     top + left,
//     dx: 110mm,
//     dy: 0mm,
//     rotate(
//       0deg,
//       reflow: false,
//       image(
//         bildpfad + "slide-033-homer-simpson-nachdenklich.png",
//         width: 165mm,
//         height: 108mm,
//         fit: "contain",
//       ),
//     ),
//   )
//   #place(
//     top + left,
//     dx: 0mm,
//     dy: 0mm,
//     box(
//       width: 105mm,
//       height: 60mm,
//       centered-items(
//         item-by-item([
//           - 20 % Aminosäuren
//           - 40 % Kohlenhydrate
//           - 40 % Fette
//         ]),
//       ),
//     ),
//   )
//   #quelle([Homer: #link("http://www.dohiy.com/2016/03/31/wiring-level-acceptable/homer-thinking/")[dohiy.com];
//     #linebreak()
//     Kuchen: #link("http://clubpenguin.wikia.com/wiki/File:Puffle_Care_catalog_icons_Food_8_peice_cake.png")[Club Penguin Wiki] (Stand 13.07.2023).])
// ]
//
// // 34 – Aufteilung im Beispiel
// #slide(title: text(size: 22pt, weight: "regular", [Einzelkomponenten nach 20/40/40]))[
//   #set text(size: 16pt)
//   #centered-items(item-by-item([
//     - Aminosäuren: 20 % von 1.200 kcal = 240 kcal.
//     - Dem steht im Beispiel ein Ziel von 1,8 g/kg IBW ≈ 127 g/Tag gegenüber.
//     - Fett: 40 % der Energie; Vergleichsziel 0,9 g/kg = 90 g/Tag.
//     - Kohlenhydrat/Aminosäuren ≈ 2:1; Kohlenhydrat/Fett ≈ 50/50.
//   ]))
// ]
//
// // 35 – Bewertung der Aufteilung
// #slide(title: text(size: 22pt, weight: "regular", [20/40/40: Zielkonflikt bei Adipositas]))[
//   #set text(size: 16pt)
//   #grid(
//     columns: (57%, 39%),
//     gutter: 4%,
//     [
//       #centered-items(item-by-item([
//         - Die 20-%-Aminosäurenquote erreicht in der Beispielrechnung weniger als ein Drittel des Aminosäurenziels.
//         - Auch die Fettmenge liegt unter dem Vergleichsziel.
//         - Die prozentuale Verteilung allein löst das Problem nicht.
//       ]))
//     ],
//     [
//       #grid(
//         columns: (1fr,),
//         gutter: 2mm,
//         row-gutter: 2mm,
//         box(
//           width: 100%,
//           height: 87mm,
//           align(
//             center + horizon,
//             bild(
//               "slide-035-kenny-mccormick-traurig.png",
//             ),
//           ),
//         ),
//       )
//     ],
//   )
//   #quelle([#kennyQuelle (Stand 08.03.2023).])
// ]
//
// // 36 – Leitfrage
// //NOTE: Kürzungsvorschlag: Die reine Bildüberleitung auslassen; der Ernährungsrechner auf Folie 37 kann direkt an den Zielkonflikt anschließen.
// #slide(title: text(size: 22pt, weight: "regular", [Kilokalorien oder Makronährstoffe?]))[
//   #set text(size: 18pt)
//   #place(
//     top + left,
//     dx: 0mm,
//     dy: 0mm,
//     rotate(
//       0deg,
//       reflow: false,
//       image(
//         bildpfad + "slide-036-homer-simpson-doh.png",
//         width: 95mm,
//         height: 116mm,
//         fit: "contain",
//       ),
//     ),
//   )
//   #place(
//     top + left,
//     dx: 96mm,
//     dy: 10mm,
//     rotate(
//       0deg,
//       reflow: false,
//       image(
//         bildpfad + "slide-036-homer-simpson-verzweifelt.png",
//         width: 178mm,
//         height: 105mm,
//         fit: "contain",
//       ),
//     ),
//   )
//   #quelle([Homer-Bilder: #link("https://www.netclipart.com/isee/hoRRTb_doh-clipart-homer-simpson-homer-simpson-doh-png/")[NetClipart] und
//     #linebreak()
//     #link("https://picsart.com/i/sticker-235915385048212")[Picsart] (Stand 13.07.2023).])
// ]
//
// // 37 – Rechner
// #slide(title: text(size: 22pt, weight: "regular", [Im Kopf schwer: Ernährungsrechner]))[
//   #set text(size: 18pt)
//   #place(
//     top + left,
//     dx: 0mm,
//     dy: 0mm,
//     rotate(
//       0deg,
//       reflow: false,
//       image(
//         bildpfad + "slide-037-ernaehrungsrechner-eingabe.png",
//         width: 147mm,
//         height: 105mm,
//         fit: "contain",
//       ),
//     ),
//   )
//   #place(
//     top + left,
//     dx: 148mm,
//     dy: 0mm,
//     rotate(
//       0deg,
//       reflow: false,
//       image(
//         bildpfad + "slide-037-ernaehrungsrechner-ergebnis.png",
//         width: 130mm,
//         height: 105mm,
//         fit: "contain",
//       ),
//     ),
//   )
// ]
//
// // 40 – IBW
// #slide(title: text(size: 22pt, weight: "regular", [Ideales Körpergewicht (IBW): DGEM und ARDSNet]))[
//   #set text(size: 15pt)
//   #place(
//     top + center,
//     dy: 3mm,
//     image(
//       bildpfad + "slide-040-dgem-idealgewicht-formel.png",
//       width: 270mm,
//       height: 26mm,
//       fit: "contain",
//     ),
//   )
//   #place(
//     top + center,
//     dy: 34mm,
//     image(
//       bildpfad + "slide-040-ards-idealgewicht-formel-metrisch.png",
//       width: 270mm,
//       height: 40mm,
//       fit: "contain",
//     ),
//   )
//   #place(
//     top + center,
//     dy: 79mm,
//     image(
//       bildpfad + "slide-040-ards-idealgewicht-formel-imperial.png",
//       width: 270mm,
//       height: 25mm,
//       fit: "contain",
//     ),
//   )
//   #place(
//     top + center,
//     dy: 108mm,
//     text(
//       size: 15pt,
//     )[Bei 180 cm: DGEM 72 kg · ARDSNet ca. 71 kg (F) / 75 kg (M); unterschiedliche Zwecke],
//   )
//   #quelle([#cite(<elke2019DGEMS2kLeitlinieKlinische>, supplement: [S. 400]);
//     #linebreak()
//     #cite(<brower2000VentilationLowerTidal>, supplement: [S. 1302]).])
// ]
//
// // 41 – Vergleich der IBW-Formeln
// #slide(title: text(size: 22pt, weight: "regular", [Ist „ideal“ ideal?]))[
//   #set text(size: 15pt)
//   #grid(
//     columns: (57%, 39%),
//     gutter: 4%,
//     [
//       #centered-items(item-by-item([
//         - Beispiel: 180 cm, 100 kg, BMI 30,9 kg/m².
//         - DGEM: 72 kg IBW; ARDSNet: 71 kg (Frau) beziehungsweise 75 kg (Mann).
//         - Für 1,8 g/kg IBW ergeben sich etwa 128–135 g Aminosäuren pro Tag.
//         - IBW-Formeln können bei kleinen Menschen unterschätzen und bei großen überschätzen.
//       ]))
//     ],
//     [
//       #grid(
//         columns: (1fr,),
//         gutter: 2mm,
//         row-gutter: 2mm,
//         box(
//           width: 100%,
//           height: 87mm,
//           align(
//             center + horizon,
//             bild(
//               "slide-041-idealgewicht-abhaengig-von-koerpergroesse.png",
//             ),
//           ),
//         ),
//       )
//     ],
//   )
//   #quelle([#cite(<elke2019DGEMS2kLeitlinieKlinische>, supplement: [S. 363]);
//     #linebreak()
//     #cite(<shah2006ComparisonIdealBody>, supplement: [S. 312]);
//     #linebreak()
//     #cite(<peterson2016UniversalEquationEstimating>, supplement: [S. 1201]).])
// ]
//
// // 47 – Refeeding des Minnesota-Experiments
// //NOTE: Kürzungsvorschlag: Den historischen Rehabilitations-Exkurs auslassen; Refeeding ist laut Überblick nicht Teil des Vortrags, der Vergleich auf Folie 08 bleibt erhalten.
// #slide(title: text(size: 22pt, weight: "regular", [Minnesota Starvation Experiment: Rehabilitation]))[
//   #set text(size: 16pt)
//   #place(
//     top + left,
//     dx: 0mm,
//     dy: 0mm,
//     rotate(
//       0deg,
//       reflow: false,
//       image(
//         bildpfad + "slide-047-minnesota-starvation-rehabilitation-kalorien.png",
//         width: 190mm,
//         height: 100mm,
//         fit: "contain",
//       ),
//     ),
//   )
//   #place(
//     top + left,
//     dx: 193mm,
//     dy: 0mm,
//     box(
//       width: 85mm,
//       height: 112mm,
//       centered-items(
//         item-by-item([
//           - Restriktionsphase: ungefähr 1.570 kcal/Tag in der dargestellten Grafik.
//           - Anschließend stieg die Energiezufuhr auf etwa 3.490 bis 4.780 kcal/Tag.
//           - Die Ausgangsfolie berichtet für einzelne Teilnehmer bis zu 11.500 kcal/Tag.
//         ]),
//       ),
//     ),
//   )
//   #quelle([#cite(<dulloo2021PhysiologyWeightRegain>, supplement: [S. 2])#text[;]
//     #linebreak()
//     weitere Abbildung: #link("https://followtheintuition.com/minnesota-starvation-experiment-eating-disorders/")[Follow the Intuition] (Stand 12.03.2023).])
// ]
//
// // 50 – essenzielle Fettsäuren
// #slide(title: text(size: 22pt, weight: "regular", [Spezielle Nährstoffe: essenzielle Fettsäuren]))[
//   #set text(size: 18pt)
//   #centered-items(item-by-item([
//     - Linolsäure: 2–4 % der Gesamtkilokalorien.
//     - Alpha-Linolensäure: 0,25–0,5 % der Gesamtkilokalorien.
//     - Die Zusammensetzung der Lipidlösung beeinflusst die Zufuhr beider Fettsäuren.
//     - Im Vortrag wird der Sojaanteil verschiedener Propofol- und Lipidformulierungen verglichen.
//   ]))
//   #quelle([#cite(<elke2019DGEMS2kLeitlinieKlinische>, supplement: [S. 387, 393–394]).])
// ]
//
// // 51 – Vitamine und Spurenelemente
// //NOTE: Kürzungsvorschlag: Diese Vertiefung auslassen; Thiamin und Vitamin D sind bereits auf Folie 39 eingeführt.
// #slide(title: text(size: 22pt, weight: "regular", [Spezielle Nährstoffe: Vitamin D und Thiamin]))[
//   #set text(size: 16pt)
//   #centered-items(item-by-item([
//     - Die Ausgangsleitlinie diskutiert Vitamin D bei schwerem Mangel: 25(OH)D ≤ 30 nmol/l beziehungsweise ≤ 12 ng/ml.
//     - Thiaminmangel kann neurologische und kardiovaskuläre Symptome sowie eine Laktatazidose verursachen.
//     - Mikronährstoffe und Spurenelemente sind bei unzureichender enteraler Zufuhr gesondert zu berücksichtigen.
//   ]))
//   #quelle([#cite(<elke2019DGEMS2kLeitlinieKlinische>, supplement: [S. 395, 397]).])
// ]

