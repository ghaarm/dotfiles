<!--
Zweck: Dauerhaftes Projektziel, aktueller Arbeitsauftrag und Stand dieses Projekts.
Hier hinein gehören:
- Projektziel und Rahmen: allgemeine Absicht, Zielgruppe, gewünschtes Ergebnis und Rahmenbedingungen.
- Aktueller Arbeitsauftrag: konkrete nächste Aufgabe, Umfang und überprüfbare Abschlusskriterien.
- Relevante Dateien, Zotero-Collection und Bibliographie-Einbindung.
- LaTeX-Hauptdatei, Engine, Build-Befehl und externe Abhängigkeiten.
- Erledigtes, offene Punkte, wichtige Einschränkungen und nächster Schritt mit Standdatum.
Das Projektziel bleibt über Sitzungen hinweg bestehen. Den aktuellen Arbeitsauftrag nur ändern,
wenn sich die Aufgabe ändert; eine neue Sitzung kann denselben Auftrag fortsetzen.
Den aktuellen Stand bei wesentlichen Fortschritten aktualisieren; dauerhafte Entscheidungen in DECISIONS.md festhalten.
-->

# Projekt: MDK Thrombaspiration

## Projektziel und Rahmen

- Allgemeine Absicht: Eine wissenschaftlich belegte Stellungnahme zur Begründung der Thrombaspiration gegenüber dem Medizinischen Dienst erstellen, der MDK will die Kosten nicht erstatten. Die Argumentation anhand der Literatur prüfen und relevante Evidenzlücken oder widersprüchliche Befunde kenntlich machen.

- Zielgruppe: Medizinischer Dienst.

- Gewünschtes Ergebnis: Fertige Stellungnahme als LaTeX-Dokument und geprüftes PDF.

- Vorhandenes Dokument: „Antwort MDK Thrombaspiration“.

- Arbeitsgrundlage: bestehender LaTeX-Entwurf und die Markdown-Dateien unter `research/`.

- Rahmenbedingungen: Bestehende Gliederung, Gestaltung und Zitierweise erhalten, sofern der konkrete Auftrag keine Änderung vorsieht.

- Gesamtumfang und Abgabetermin: noch nicht festgelegt.

- Sprache: Deutsch.

- Relevante Zotero-Collections: `lae` und insbesondere `lae-inari`.

Es gelten die allgemeinen Anweisungen im Arbeitsbereich: `../../AGENTS.md`, `../../RESEARCH.md`, `../../ZOTERO.md` und `../../LATEX.md`.

## Aktueller Arbeitsauftrag

<!--
Hier die konkrete nächste inhaltliche Aufgabe eintragen. Nur aktualisieren, wenn sich die Aufgabe ändert,
nicht bei jedem Sitzungswechsel. Das übergeordnete Projektziel bleibt im vorherigen Abschnitt stehen.
Beispiel für eine Aufgabe: Den Abschnitt zur Indikation anhand der Literatur prüfen und fehlende Belege ergänzen.
Beispiel für Abschlusskriterien: Aussagen geprüft, Quellen ergänzt und offene Evidenzfragen dokumentiert.
Fortschritte und nächste Schritte unter „Aktueller Stand“ festhalten.
-->

- Aufgabe:

  <!-- * Alle `% TODO:`-Kommentare im Manuskript gemäß `LATEX.md` bearbeiten. -->

  * beim sPESI ist der Cutoff für die Herzfrequenz größer gleich 110 /min, für den PESI und sPESI bitte die originalliteratur als Referenz angeben

  * ggf. ist es sinnvoll auch die Widersprüchlichkeit bei hochrisiko lae mit Lyse vs. V-A ECMO kurz zu benennen

  * in einem absatz auf die deutlich veralterte Leitlinie eingehen die der MDK angibt, ich glaube von 2009 und zeigen warum das veraltert ist

  * in der aktuellen AHA Leitlinie 2026 von Creagar et al. gibt es auch eine Risikobewertung des reitenden Thrombus 2026 AHA/ACC/ACCP/ACEP/CHEST/SCAI/SHM/SIR/SVM/SVN Guideline for the Evaluation and Management of Acute Pulmonary Embolism in Adults: A Report of the American College of Cardiology/American Heart Association Joint Committee on Clinical Practice Guidelines, die guideline ist in der zotero datenbank und storage zum lesen vorhanden

  * die AHA 2026 Leitlinie prüfen ob es neue Informationen für die Antwort der MDK Antwort gibt


- Verbindliches Ausgangsmaterial: Die Ablehnungsbegründung in `research/mdk-grund-ablehnung.md` gemeinsam mit der Fallbeschreibung in `research/fallbeschreibung-mdk.md` berücksichtigen. Vor der inhaltlichen Überarbeitung beide Dateien lesen und die konkreten MDK-Einwände mit den dokumentierten Falldaten und der Literatur abgleichen.
- Umfang / betroffene Abschnitte: noch nicht festgelegt.
- Erledigt, wenn: noch nicht festgelegt.

## Dateien

- Hauptdatei: [manuscript/thrombaspiration-antwort-mdk.tex](manuscript/thrombaspiration-antwort-mdk.tex).
- Projektlokale Präambel: [manuscript/preamble-project.tex](manuscript/preamble-project.tex).
- Fallbeschreibung: [research/fallbeschreibung-mdk.md](research/fallbeschreibung-mdk.md).
- MDK-Ablehnungsbegründung: [research/mdk-grund-ablehnung.md](research/mdk-grund-ablehnung.md).
- Ergänzendes Ausgangsmaterial: [research/thrombaspiration-inari.md](research/thrombaspiration-inari.md).
- Suchprotokoll: [research/search-log.md](research/search-log.md).
- Aussagen und Belege: [research/evidence.md](research/evidence.md).
- Abbildungen: `manuscript/figures/`.
- Vorhandenes PDF: [manuscript/thrombaspiration-antwort-mdk.pdf](manuscript/thrombaspiration-antwort-mdk.pdf).
- Übernommene Build-Hilfsdateien: `manuscript/auxiliary_files/` sowie SyncTeX-Dateien direkt in `manuscript/`.

## Manuskript-TODOs

Die `% TODO:`-Kommentare in `manuscript/thrombaspiration-antwort-mdk.tex` sind als konkrete Arbeitsaufträge innerhalb des Manuskripts zu behandeln.

Bei Arbeiten am Manuskript:

- TODOs im Kontext ihrer jeweiligen Position im Text bearbeiten,
- relevante `% MEMO:`-Kommentare als Kontext berücksichtigen,
- die Regeln für `TODO:`, `NOTE:` und `MEMO:` aus `../../LATEX.md` anwenden,
- nach Bearbeitung einen `% TODO:` gemäß `LATEX.md` durch einen aussagekräftigen `% NOTE:` ersetzen,
- bei wissenschaftlichen TODOs zusätzlich `../../RESEARCH.md` und `../../ZOTERO.md` beachten.

TODOs dürfen selbstständig bearbeitet werden, wenn sie zum aktuellen Arbeitsauftrag gehören oder der Nutzer ausdrücklich die Bearbeitung aller TODOs im Manuskript verlangt.

TODOs außerhalb des aktuellen Arbeitsauftrags nicht allein deshalb bearbeiten, weil sie im Manuskript vorhanden sind.

Nach der Bearbeitung das Dokument gemäß `LATEX.md` kompilieren und das erzeugte PDF prüfen.

## LaTeX und Bibliographie

- Dokumentklasse: `article`; Schrift: Calibri über `fontspec`.
- Ursprünglich verwendete externe Präambel, im Quelltext als Referenz dokumentiert:
  `/users/g/library/mobile documents/com~apple~clouddocs/!docs icloud/r statistik, icloud/latex, icloud/latex projekte/@vorlagen-latex/preamble-footnotes-bibliographie-neu.tex`.
- Für einen reproduzierbaren Build innerhalb des Projektbereichs wird `manuscript/preamble-project.tex` verwendet. Sie bindet `/Users/g/Library/texmf/bibtex/bib/Zotero.bib` ein. Dieselbe Datei ist im Arbeitsbereich als `../../Zotero.bib` erreichbar und strikt READ-ONLY.
- Es wird keine zusätzliche `references.bib` angelegt.
- Getesteter Build-Befehl aus `manuscript/`: `latexmk -xelatex -interaction=nonstopmode -halt-on-error -file-line-error -auxdir=auxiliary_files -outdir=. thrombaspiration-antwort-mdk.tex`. PDF und SyncTeX gehören neben die Hauptdatei in `manuscript/`, Hilfsdateien nach `manuscript/auxiliary_files/`.

## Aktueller Stand

Stand: 2026-10-03.

- Projektstruktur eingerichtet; vorhandene Arbeitsdateien ohne Inhaltsänderungen einsortiert.
- Auf Nutzerwunsch PDF, SyncTeX und den Ordner `auxiliary_files/` nach `manuscript/` verschoben; den anschließend leeren Ordner `output/` entfernt.
- Die Prüfsummen der verschobenen Dateien wurden kontrolliert.
- Das Dokument wurde mit XeLaTeX und Biber erfolgreich neu kompiliert. Das Ergebnis umfasst fünf Seiten; es bestehen keine undefinierten Zitate, keine leere Bibliographie und keine übervollen Textzeilen.
- Das vollständige PDF wurde seitenweise gerendert und visuell auf Beschnitt, Überlagerungen, Verweisrahmen, Tabellenlesbarkeit, Fußnoten und Literaturverzeichnis geprüft.
- In `research/thrombaspiration-inari.md` steht weiterhin `bibliography: zotcite.bib`; eine solche Datei ist hier nicht vorhanden. Vor einer Verarbeitung dieser Markdown-Datei die Bibliographie-Einbindung klären. Die vorhandene Angabe wurde nicht verändert.
- Fallbeschreibung und MDK-Ablehnungsbegründung wurden vollständig abgeglichen.
- Der LaTeX-Entwurf wurde neu strukturiert und um eine direkte Beantwortung aller MDK-Fragen ergänzt.
- PESI/sPESI wurden korrigiert: präklinisch PESI 119/Klasse IV und sPESI 2; in ZNA und ITS unter Sauerstoffgabe PESI 99/Klasse III und sPESI 1. Der sPESI-Grenzwert für die Herzfrequenz beträgt 100/min.
- Die formale Risikokategorie zum Interventionszeitpunkt wird als am ehesten intermediär-niedrig eingeordnet; die ausgeprägte initiale klinische Gefährdung wird getrennt dargestellt.
- Die G-BA-Entscheidung, die AWMF-/ESC-Leitlinien, das FLASH-Register, die PEERLESS-RCT und eine Kostenanalyse wurden geprüft und in `research/evidence.md` sowie `research/search-log.md` dokumentiert.
- Die Argumentation stellt klar, dass eine primäre systemische Lyse bei normotensivem intermediärem Risiko nicht routinemäßig empfohlen ist. Zugleich bleibt transparent, dass die Akte die individualisierte Entscheidung gegen alleinige Antikoagulation nicht vollständig dokumentiert.
- Kostenfolgen von Komplikationen und verlängertem Intensivaufenthalt sind qualitativ eingeordnet; eine nicht belegte deutsche Kostenersparnis wird nicht behauptet.
- Weil der Compiler auf die außerhalb des Projektbereichs liegende externe Präambel nicht zugreifen konnte, wurde eine projektlokale Präambel mit den im letzten erfolgreichen Build nachweisbaren Kernpaketen, dem Letter-Layout und derselben zentralen Zotero-Bibliographie angelegt.

Nächster Schritt: Nach Möglichkeit Originalbefunde bzw. eine ergänzende Erklärung des Behandlungsteams einarbeiten, insbesondere zur präinterventionellen Verschlechterung, zur konkreten Wahl der Thrombaspiration gegenüber alleiniger Antikoagulation und zu den erwogenen Alternativen.

Bei wesentlichen Arbeitsschritten diesen Stand aktualisieren; dauerhafte Entscheidungen in `DECISIONS.md` festhalten.

