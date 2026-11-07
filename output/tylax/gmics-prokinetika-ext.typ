// ============================================================
// DOKUMENTINFORMATIONEN
// ============================================================
//
// Typst-Version bei Erstellung: 0.15.1
//
// Versionshistorie:
// - 2026-10-11 | Typst 0.15.1 | Vorlage erstellt
//
// Aktuelle Version prüfen: typst --version
// Die Versionsangabe ist Dokumentation, keine Versionsbindung.


// ============================================================
// PRÄAMBEL
// ============================================================

#import "/Users/g/Library/Mobile Documents/com~apple~CloudDocs/!Docs iCloud/typst-icloud/1-vorlagen-typst/preamble-footnotes-bibliographie-neu.typ": praembel, balanced-columns, footnotes

// ============================================================
// OPTIONALE PAKETE
// ============================================================
//
// Nur bei Bedarf aktivieren.
// Vor Aktivierung aktuelle Versionsnummer prüfen.
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

// Hinweis- und Merkkästen (Showybox)
// #import "@preview/showybox:VERSION": *

// Formatierte Codeblöcke (Codly)
// #import "@preview/codly:VERSION": *

// Zeitachsen (Timeliney)
// #import "@preview/timeliney:VERSION": *

// Präsentationen (Touying)
// Besser in eigener Präsentationsvorlage verwenden.
// #import "@preview/touying:VERSION": *


// ============================================================
// DOKUMENTLAYOUT
// ============================================================

#show: praembel

// Linkfarben
#let linkrot = rgb("a32121")

// Interne Links dunkelrot, externe URLs blau
#show link: it => text(
  fill: if type(it.dest) == str { blue } else { linkrot },
  it,
)

// Querverweise auf Abbildungen, Tabellen und Abschnitte dunkelrot
#show ref: set text(fill: linkrot)

// Fußnotenziffern im Fließtext dunkelrot
#show footnote: set text(fill: linkrot)

#show heading.where(level: 1): set block(
  above: 1.25em,
  below: 0.65em,
)
#let titel = "G'MICS Prokinetika"

#let fusszeile = "G'MICS Prokinetika, G. Haarmeyer"

#let untertitel = "- nur für den persönlichen Gebrauch -"

// #let datum = datetime.today().display("[day].[month].[year]")

#let datum = datetime.today().display("[year]-[month]-[day]")

// #set page(footer: context {
//   line(length: 100%, stroke: 0.4pt)
//   v(2pt)
//   link(<inhaltsverzeichnis>)[Zurück zum Inhaltsverzeichnis]
//   h(1fr)
//   // [#fusszeile, Stand: #datetime.today().display("[day].[month].[year]"), S. #counter(page).display()]
//   [#fusszeile, Stand: #datetime.today().display("[year]-[month]-[day]"), S. #counter(page).display()]
// })

#set page(footer: context {
  line(length: 100%, stroke: 0.4pt)
  v(2pt)
  link(<inhaltsverzeichnis>)[Zurück zum Inhaltsverzeichnis]
  h(1fr)
  [
    #fusszeile, Stand: #datetime.today().display("[year]-[month]-[day]"),
    S. #counter(page).display("1/1", both: true)
  ]
})

#align(center)[
  #text(size: 17pt, weight: "regular", titel)

  #if untertitel != none {
    parbreak()
    text(size: 12pt, untertitel)
  }

  #if datum != none {
    v(4mm)
    parbreak()
    datum
  }
]
#v(1em) // Abstand zum Inhaltsverzeichnis


#[
  #show outline.entry: set text(fill: linkrot)
  #show outline.entry.where(level: 1): set text(weight: "bold")
  #show outline.entry.where(level: 1): set outline.entry(fill: none)
  #show outline.entry.where(level: 1): set block(above: 1em)

  #outline(title: "Inhaltsverzeichnis") <inhaltsverzeichnis>
]


#outline(target: figure.where(kind: image), title: "Abbildungsverzeichnis")


// ============================================================
// BEGINN DOCUMENT
// ============================================================

#pagebreak()

= Kernpunkte

+ Erythromycin ist als Prokinetikum wirksamer als MCP und sollte das primär genutzte Prokinetikum sein.
+ Der beste prokinetische Effekt ist wenn man Erythromycin und MCP kombiniert.
+ MCP sollte aufgrund seiner Nebenwirkungen nur für 5 konsekutive Tage genutzt werden.
+ Erythromycin verliert nach 3 Tagen einen großen Anteil seiner Wirkung, kann aber bis zu 7 Tagen gegeben werden.
+ Gastrale Residualvolumina (GRV (Reflux)) bis zu 500 ml pro Messung können toleriert werden, eine prokinetische Therapie sollte ab 500 ml pro Messung begonnen werden ohne die enterale Ernährung zu reduzieren.
+ Bei einem GRV von $>=$ 800 ml sollte die enterale Ernährungslaufrate um 50 % reduziert werden.
+ Neostigmin hat in Dosierungen von 1 mg i.v. positive Auswirkungen auf das GRV.
+ Vorgehen:
  - Opiate so niedrig wie möglich dosieren (Sufentanil-Ziel um 10 - 20 µg/h)
  - Erythromycin und MCP kombiniert beginnen:
    - Erythromycin 50 mg i.v. 3x/Tag
    - MCP 10 mg i.v. 3x/Tag
      - Reduktion bei akuter Nierenschädigung/chronischer Nierenerkrankung entsprechend eGFR:#footnote[#cite(<MCPratiopharm10Mg>, supplement: [S. 2])] #link("https://dosing.de/popup_niere.php?monoid=450")[dosing.de, Stand 25.01.2026]
      - eGFR 15 - 60 ml/min: MCP 5 mg 3x/Tag (Reduktion um 50 %)
      - eGFR $<=$ 15 ml/min: MCP 7,5 mg 1x/Tag (Reduktion um 75 %)
  - Wenn nach Tag 3 keine Besserung der enteralen Nahrungsverträglichkeit eingetreten ist 1 - 2,5 mg Neostigmin i.v. in 100 ml NaCl 0,9 % über 30 Minuten geben (bis zu 3x Tag).
  - Parallel ab Tag 3 NJS planen (Aufklärung).
  - Wenn ab Tag 5 keine Besserung der enteralen Nahrungsverträglichkeit eingetreten ist NJS anmelden.

#columns(2)[
  
  = Allgemein
  
  <sec-Allgemein>
  
  Eine Intoleranz der enteralen Ernährung ist mit einem verlängerten Intensivaufenthalt und einer höheren Sterblichkeit assoziiert.#footnote[#cite(<elke2015GastricResidualVolume>, supplement: [S. 60])]
  
  Eine frühe enterale Ernährung beeinflusst die funktionale, immunologische und strukturelle Integrität des GI-Traktes, der das größte immunologische Organ des Körpers ist. Eine enterale Ernährung, fördert die Sekretion von IgA, verringert den oxidativen Stress und verringert ein SIRS, die einen Effekt auf das Outcome haben.#footnote[#cite(<mcclave2009PhysiologicResponseAssociated>, supplement: [S. 305, 314])] Paper Reintam Blaser
  
  = Reflux, Gastrales Residualvolumen GRV
  
  <sec-Reflux-Gastrales-Residualvolumen-GRV> Das im alltäglichen intensivmedizinischen Kontext benutzte Wort Reflux ist für das was damit gemeint ist ungenau und irreführend. Im englischen wird gastric residual volume (GRV) benutzt und meint damit das Residualvolumen im Magen. Die Tatsache, dass im Magen Flüssigkeit ist, heisst nicht dass diese einen Reflux bewirkt. Der Reflux bei Patient:innen mit einer Magensonde wird meist nur festgestellt, weil die Magensonde auf Ablauf ist. Wenn die Patient:innen keine Magensonde hätten würde man den Reflux ggf. gar nicht feststellen.
  
  Zaloga hat bereits 2005 in seinem Kommentar The Myth of gastric residual volume die fehlende Evidenz, die fehlende Definition ab wann ein GRV nicht mehr tolerierbar ist und die fehlende Standardisierung der GRV Messung thematisiert.#footnote[#cite(<zaloga2005MythGastricResidual>, supplement: [S. 449, 450])]
  
  5 Jahre später zeigten Montejo et al. 2010, dass eine GRV bis 500 ml pro Messung nicht mit mehr gastrointestinalen Komplikationen, Pneumonien, Beatmungstagen oder der Länge des Intensivaufenthalts assoziiert waren, verglichen mit einem Cut off von 200 ml pro Messung.#footnote[#cite(<montejo2010GastricResidualVolume>, supplement: [S. 1386])]
  
  Und noch mal 3 Jahre später haben Reignier et al. 2013 in einer Studie (NUTRIREA 1) mit 452 mechanisch beatmeten Patient:innen, in der sie keine GRV-Kontrollen mit GRV-Kontrollen alle 6 h verglichen wurden. Es gab keine Unterschiede hinsichtlich des Auftretens einer VAP, ICU assoziierten Infektionen, Dauer der mechanischen Beatmung, Dauer des Intensivaufenthalts oder Sterblichkeit.#footnote[#cite(<reignier2013EffectNotMonitoring>, supplement: [S. 249])]
  
  Dies wurde durch eine Meta-Analyse von Feng et al. 2023 in der 7 RCTs (n = 1240 Patient:innen) bestätigt. Wenn kein Monitoring des GRV durchgeführt wurde, trat zwar vermehrt Erbrechen auf, aber es gab keinen signifikanten Unterschied zwischen abdominaler Distension, Durchfall, VAPs, Dauer der mechanischen Beatmung, Dauer des Intensivaufenthalts und der Sterblichkeit.#footnote[#cite(<feng2023MonitoringGastricResidual>, supplement: [S. 1])]
  
  In dem oben genannten Kommentar von Zaloga 2025 hatte dieser als kleine Veranschaulichung die GRVs von 12 Patient:innen, die ein neues Infiltrat entwickelt hatten und mechanisch beatmet waren, dargestellt. Die dargestellten GRVs sind Mittelwerte der letzten 24 h vor dem neuem Infiltrat. Alle gemittelten GRVs waren $<$ 200 ml (s. @fig-Durchschnittliche-GRVs-24-h-vor-neuem-Infiltrat-bei-MV).
  
  #figure(
  [#image("./bilder/zaloga-2005-grv-s-449.png", width: 50%)],
  caption: [Durchschnittliche GRVs 24 h vor neuem Infiltrat bei MV #cite(<zaloga2005MythGastricResidual>, supplement: [S. 449], style: "chicago-author-date")],
) <fig-Durchschnittliche-GRVs-24-h-vor-neuem-Infiltrat-bei-MV>

Elke, der Erstautor der S2k-Leitlinie der DGEM für Ernährung von Intensivpatient:innen schrieb, 2015 das eine GRV-Messung auf internistischen Intensivstationen wahrscheinlich nicht notwendig ist, wenn folgende Kriterien erfüllt sind:#footnote[#cite(<elke2015GastricResidualVolume>, supplement: [S. 69])]
+ Es gibt ein erfahrenes Pflegeteam.
+ Es gibt etablierte SOPs für die Ernährung mit anderen Sicherheitskriterien wie halbaufrechte, Position im Bett oder eine oropharyngeale Hygiene.
+ Es gibt proaktive Strategien, um das Risiko (von Aspirationen, abdominaler Distension) zu reduzieren prophylaktische prokinetische Therapie die jejunale Ernährung.

Eine GRV-Messung ist sinnvoll bei Patienten, die ein hohes Risiko für eine GI-Dysfunktion haben, zum Beispiel kritisch kranke (schwere Pankreatitis) oder chirurgische Patient:innen.

Ab einem GRV von $>=$ 800 ml pro Messung sollte die enterale Ernährungslaufrate um 50 % reduziert werden.#footnote[#cite(<tarcukovic2022MyEvidencebasedNutrition>, supplement: [ab Min. 14:20])]

Wie wichtig ein erfahrenes Pflegeteam ist, zeigt eine Umfrage von vier Intensivstationen im United Kingdom, in der 78,2 % der Pflegekräfte angegeben haben, dass sie besorgt (51,2 %) oder sehr besorgt wären (27 %), wenn sie keine GRV-Messung durchführen würden.#footnote[#cite(<tume2024NursesDecisionmakingGastric>, supplement: [S. 1])]

Die ESPEN Guideline 2023 für Intensivpatient:innen empfiehlt eine prokinetische Therapie zu erwägen wenn das GRV $>=$ 500 ml/in 6 h ist und keine abdominelle Komplikation vorliegt.#footnote[#cite(<singer2023ESPENPracticalPartially>, supplement: [S. 1686])]

= Opioide reduzieren

<sec-Opioide-reduzieren>

In einer Studie von Nguyen et al. 2013 von 248 mechanisch beatmeten Patient:innen zeigte, dass ein Opioidverbrauch von im Durchschnitt 20,83 ± 27,46 mg Hydromorphon-Äquivalent i.v. pro Tag ein Risikofaktor für das Entwickeln einer GI-Dysfunktion war.#footnote[#cite(<nguyen2013ImpairedGastrointestinalTransit>, supplement: [S. 537.e13])]

20,83 ± 27,46 mg Hydromorphon-Äquivalent i.v. pro Tag entsprechen ungefähr einer Laufrate von 10 - 20 µg Sufentanil pro Stunde.#footnote[#cite(<freye2002OpioideMedizin>, supplement: [S. 64])]

= Prokinetika

<sec-Prokinetika>

== MCP, Metoclopramid

<sub-MCP-Metoclopramid> MCP erhöht die gastrale Motilität über muskarinerge Rezeptoren.#footnote[#cite(<rahat-dahmardeh2021ComparingEffectNeostigmine>, supplement: [S. 5])] Die übliche Dosis als Prokinetikum ist 10 mg 2 - 3x/Tag.#footnote[#cite(<singer2023ESPENPracticalPartially>, supplement: [S. 1686])] MCP ist in seiner prokinetischen Wirkung Erythromycin unterlegen und sollte entsprechend der EMA wegen der Nebenwirkungen nur max. 5 Tage gegeben werden (vgl. @sub-Erythromycin)

- Reduktion bei akuter Nierenschädigung/chronischer Nierenerkrankung entsprechend eGFR:#footnote[#cite(<MCPratiopharm10Mg>, supplement: [S. 2])] #link("https://dosing.de/popup_niere.php?monoid=450")[dosing.de, Stand 25.01.2026]
- eGFR 15 - 60 ml/min: MCP 5 mg 3x/Tag (Reduktion um 50 %)
- eGFR $<=$ 15 ml/min: MCP 7,5 mg 1x/Tag (Reduktion um 75 %)

== Erythromycin

<sub-Erythromycin> Erythromycin verstärkt die Amplitude der Kontraktionen im Antrum, erhöht aber nicht der Frequenz der Kontraktionen (Dosis 1-3 mg/kg/h).#footnote[#cite(<annese1992ErythromycinAcceleratesGastric>, supplement: [S. 825])]

Nguyen et al. haben in ihrer Studie von 2007 (n = 107) nachgewiesen, dass Erythromycin (200 mg 2x Tag) in seiner prokinetischen Wirkung effektiver war als MCP. Der Effekt von beiden Medikamenten hat allerdings schnell nachgelassen (s. auch #ref(<fig-Erfolg-der-enteralen-Ernährung-Erythromycin-vs.-MCP>)):#footnote[#cite(<nguyen2007ErythromycinMoreEffective>, supplement: [S. 483, 485])]

Erythromycin:
- Tag 1 = 87 %
- Tag 3 = 47 %
- Tag 3 = 47 %

MCP:
- Tag 1 = 62 %
- Tag 3 = 27 %
- Tag 7 = 16 %

Der beste prokinetische Effekt trat auf, wenn Erythromycin mit MCP kombiniert wurde, dann konnte auch ein anhaltender Effekt von $>=$ 5 Tagen nachgewiesen werden (s. @fig-Erfolg-der-enteralen-Ernährung-Erythromycin-kombiniert-mit-MCP).

Aus der Studie von Nguyen 2007 kann auch nachvollzogen werden warum es sinnvoll sein kann Erythromycin länger als 3 Tage als Prokinetikum zu geben. An Tag 7 bestand immerhin noch eine Effektivität von 31 %, die höher war als die Effektivität von MCP an Tag 3 (27 %).

Eine kleinere Studie (n = 20) von MacLaren et al. 2008 ergab ebenfalls Hinweise, dass Erythromycin wirksamer ist als MCP.#footnote[#cite(<maclaren2008ErythromycinVsMetoclopramide>, supplement: [S. 412])]

Wenn nur ein Prokinetikum benutzt wird, sollte nach der aktuellen ESPEN Leitlinie von 2023 bei Intensivpatient:innen primär Erythromycin verwendet werden.#footnote[#cite(<singer2023ESPENPracticalPartially>, supplement: [S. 1686])]

In der S2k DGEM Leitlinie zur Ernährung von Intensivpatient:innen ist MCP aufgrund der Zulassungseinschränkung durch die EMA von 2013 aufgrund von Dyskinesien und Konvulsionen auf max. 5 Tage beschränkt. Erythromycin sollte laut der S2k Leitlinie auf 3 Tage beschränkt werden.#footnote[#cite(<elke2019DGEMS2kLeitlinieKlinische>, supplement: [S. 376])]

Die Dosierung von Erythromycin wird nach der ESPEN Leitlinie von 2023 mit 3 - 10 mg/kg/Tag angegeben.#footnote[#cite(<singer2023ESPENPracticalPartially>, supplement: [S. 1686])] TDM Messungen aus der Klinik haben allerdings gezeigt, dass mit einer Standarddosierung von 250 mg i.v. 3x/Tag sehr hohe Serumspiegel vom Erythromycin erreicht werden. So dass nach TDM die aktuelle Dosisempfehlung 50 mg i.v. 3x/Tag sind.



  
  #figure(
  [#image("./bilder/nguyen-2007-erythromycin-s-486-mcp-vs-erythromycin.png", width: 100%)],
  caption: [Erfolg der enteralen Ernährung, Erythromycin vs. MCP #cite(<nguyen2007ErythromycinMoreEffective>, supplement: [S. 486], style: "chicago-author-date")],
) <fig-Erfolg-der-enteralen-Ernährung-Erythromycin-vs.-MCP>

#figure(
  [#image("./bilder/nguyen-2007-erythromycin-s-488-mcp-kombiniert-erythromycin.png", width: 100%)],
  caption: [Erfolg der enteralen Ernährung, Erythromycin kombiniert mit MCP #cite(<nguyen2007ErythromycinMoreEffective>, supplement: [S. 488], style: "chicago-author-date")],
) <fig-Erfolg-der-enteralen-Ernährung-Erythromycin-kombiniert-mit-MCP>



  
  == Neostigmin
  
  <sub-Neostigmin>
  
  Eine interessante kanadische Studie von Parthasarathy et al. 2015, in der die Wirkung von 1 mg Neostigmin i.v. bei 28 Patient:innen mit Störungen der oberen GI-Motilität mittels antroduodenaler Manometrie untersucht wurde, zeigte, dass Neostigmin im Antrum die Frequenz der Kontraktionen erhöht (im Gegensatz zu Erythromycin), nicht aber die Amplitude der Kontraktionen beeinflusst. Im Dünndarm hingegen erhöht Neostigmin sowohl die Frequenz als auch die Amplitude der Kontraktionen. Neben der Manometrie wurde auch die gastrointestinale Transitzeit mittels Szintigraphie gemessen.#footnote[#cite(<parthasarathy2015EffectNeostigmineGastroduodenal>, supplement: [S. 1738, 1743, 1744])]
  
  Die Halbwertszeit nach i.v. Applikation liegt zwischen 24 - 80 Minuten.#footnote[#cite(<Neostigcarinopharm05Mga>, supplement: [S. 2])]
  
  Interessanterweise haben insb. iranische Ärzt:innen Studien zu Neostigmin durchgeführt (Aghadavoudi et al. 2013, Baradari et al 2016, Farzanegan et al 2021, Rahat-Dahmardeh et al. 2021). Die Studien ähneln sich in Aufbau, Methodik und Aussage sehr und sind tlw. was die Aussagen und Abbildungen betrifft nicht einfach zu lesen, decken sich aber mit anderen Studien von Seyam et al. 2025 und Parthasarathy et al. 2025). Neostigmin wurde dabei in unterschiedlichen Dosierungen von 1 mg#footnote[#cite(<aghadavoudi2013EvaluationIntravenousNeostigmine>, supplement: [S. 751])]#super[],#footnote[#cite(<seyam2025EffectTwoDifferent>, supplement: [S. 2])], 2 mg#footnote[#cite(<seyam2025EffectTwoDifferent>, supplement: [S. 2])] und 2,5 mg#footnote[#cite(<baradari2016DoubleblindRandomizedClinical>, supplement: [S. 386])]#super[],#footnote[#cite(<farzanegan2021MeasurementGastricResidual>, supplement: [S. 313])]#super[],#footnote[#cite(<rahat-dahmardeh2021ComparingEffectNeostigmine>, supplement: [S. 2])] in 100 ml NaCl 0,9 % über 30 Min. verabreicht und gegen MCP und oder NaCl verglichen.
  
  Seyam et al. 2025, die Neostigmin in der Dosis 1 und 2 mg gegen MCP getestet haben, allerdings kann in dem Paper nicht nachvollzogen werden in welcher Zeit und mit wie viel NaCl das Neostigmin appliziert wurde.#footnote[#cite(<seyam2025EffectTwoDifferent>, supplement: [S. 2])] Aghadavoudi et al 2013 haben initial 1 mg Neostigmin wie oben beschrieben appliziert und danach 0,5 mg in 50 ml NaCl 0,9 % über 15 Min. alle 4 bis 24 h verabreicht.
  Aghadavoudi et al. 2013 war die einzige iranische Studie in der bei Intensivpatient:innen kein signifikanter Effekt für Neostigmin vs. Placebo (NaCl) nachgewiesen wurde.#footnote[#cite(<aghadavoudi2013EvaluationIntravenousNeostigmine>, supplement: [S. 750])]  In den übrigen iranischen Studien als auch der ägyptischen Studie von Seyam et al. 2025 war Neostigmin in seiner prokinetischen Wirkung (Reduktion des GRV) MCP überlegen.#footnote[#cite(<baradari2016DoubleblindRandomizedClinical>, supplement: [S. 387])]#super[],#footnote[#cite(<farzanegan2021MeasurementGastricResidual>, supplement: [S. 315])]#super[],#footnote[#cite(<rahat-dahmardeh2021ComparingEffectNeostigmine>, supplement: [S. 3])]#super[],#footnote[#cite(<seyam2025EffectTwoDifferent>, supplement: [S. 3])]
  
  In der Studie von Baradari et al. 2016 waren nur mechanisch beatmete Pat. eingeschlossen (n = 60).#footnote[#cite(<baradari2016DoubleblindRandomizedClinical>, supplement: [S. 385])]
  
  Diese Ergebnisse zusammen mit der oben erwähnten kanadischen Studie von Parthasarathy et al. 2015, die eine direkte antroduodenale Druckmessung nach Neostigmin durchgeführt haben, lassen die Wirksamkeit von Neostigmin als Prokinetikum im oberen GI-Trakt nachvollziehbar erscheinen.
  
  == Ondansetron
  
  <sub-Ondansetron> Farzanengan et al. haben 2021 bei 40 Patient:innen die Wirkung von Neostigmin, MCP und Ondansetron auf das GRV verglichen. Ondansetron wurde mit 8 mg 3x/Tag verabreicht und hatte einen gering besseren Effekt als MCP.#footnote[#cite(<farzanegan2021MeasurementGastricResidual>, supplement: [S. 315])] Obwohl Netzer et al. 2002 bereits bei Gesunden keinen Effekt von Ondansetron auf die Magenentleerung nachgewiesen haben,#footnote[#cite(<netzer2002DoesIntravenousOndansetron>, supplement: [S. 121])] hatten Farzanengan et al. Ondansetron untersucht, weil es im Tiermodell die Magenentleerung beschleunigt hatte.#footnote[#cite(<farzanegan2021MeasurementGastricResidual>, supplement: [S. 316])]
]
#v(20mm)




#v(20mm)
#set heading(outlined: false)
#bibliography(
  "/Users/g/Library/texmf/bibtex/bib/Zotero.bib",
  title: [Literatur],
  style: "/Users/g/Library/Mobile Documents/com~apple~CloudDocs/!Docs iCloud/typst-icloud/1-vorlagen-typst/typst-footcite-chicago.csl",
)
