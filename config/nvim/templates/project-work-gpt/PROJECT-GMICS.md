# Projekt: {{PROJECT-NAME}}

<!--
Zweck: Dauerhaftes Projektziel, aktueller Arbeitsauftrag und Stand dieses G'MICS-Projekts.

Hier hinein gehören:
- Projektziel und Rahmen: Thema des G'MICS, Zielgruppe, gewünschtes Ergebnis und Rahmenbedingungen.
- Aktueller Arbeitsauftrag: die konkrete nächste Aufgabe.
- Relevante Dateien, Hauptdatei und Zotero-Collection.
- LaTeX-Konfiguration, Build und externe Abhängigkeiten.
- Aktueller Stand: Erledigtes, offene Punkte, wichtige Einschränkungen und nächster Schritt.

Das Projektziel bleibt über Sitzungen hinweg bestehen.
Den aktuellen Arbeitsauftrag nur ändern, wenn sich die Aufgabe ändert; eine neue Sitzung kann denselben Auftrag fortsetzen.
Den aktuellen Stand bei wesentlichen Fortschritten aktualisieren.
Dauerhafte Entscheidungen in `DECISIONS.md` festhalten.
-->

## Projektziel und Rahmen

- Allgemeine Absicht: Dies ist ein G'MICS – mein persönlicher Standard für die praktische Anwendung und klinische Einordnung von {{INPUT:TOPIC}}.

- Zielgruppe: ärztliche Kolleg:innen.

- Gewünschtes Ergebnis: Eine verständliche und praxisorientierte Anleitung für ärztliche Kolleg:innen zur Anwendung und klinischen Einordnung von {{MIRROR:TOPIC}}.

- Rahmenbedingungen: Bestehende Gliederung, Gestaltung und Zitierweise erhalten, sofern der konkrete Auftrag keine Änderung vorsieht.

- Gesamtumfang und Abgabetermin: noch nicht festgelegt.

- Sprache: Deutsch.

- Relevante Zotero-Collection: `{{INPUT}}`; relevante Unterordner dieser Collection sind einzubeziehen.

Es gelten die allgemeinen Anweisungen im Arbeitsbereich: `../../AGENTS.md`, `../../RESEARCH.md`, `../../ZOTERO.md` und `../../LATEX.md`.

## Aktueller Arbeitsauftrag

<!--
Hier die konkrete nächste inhaltliche Aufgabe eintragen. Nur aktualisieren, wenn sich die Aufgabe ändert,
nicht bei jedem Sitzungswechsel. Das übergeordnete Projektziel bleibt im vorherigen Abschnitt stehen.
Fortschritte und nächste Schritte unter „Aktueller Stand“ festhalten.
-->

- Aufgabe:

  * {{INPUT}}



## Dateien

- Hauptdatei: [manuscript/{{INPUT:MAINFILE}}.tex](manuscript/{{MIRROR:MAINFILE}}.tex).

<!--
Optionales ergänzendes Ausgangsmaterial hier eintragen, wenn neben dem Manuskript
weitere projektinterne Dateien verbindlich berücksichtigt werden sollen.

Beispiel:
- Ergänzendes Ausgangsmaterial: [research/notizen.md](research/notizen.md).
-->

- Suchprotokoll: [research/search-log.md](research/search-log.md).

- Aussagen und Belege: [research/EVIDENCE.md](research/EVIDENCE.md).

- Abbildungen: `manuscript/bilder-latex/` (Symlink auf das zentrale Abbildungsverzeichnis).

<!-- - Vorhandenes PDF: [manuscript/{{MIRROR:MAINFILE}}.pdf](manuscript/{{MIRROR:MAINFILE}}.pdf). -->

<!-- - Übernommene Build-Hilfsdateien: `manuscript/auxiliary_files/` sowie SyncTeX-Dateien direkt in `manuscript/`. -->

## Manuskript-TODOs

Die `% TODO:`-Kommentare in `manuscript/{{MIRROR:MAINFILE}}.tex` sind als konkrete Arbeitsaufträge innerhalb des Manuskripts zu behandeln.

Bei Arbeiten am Manuskript:

- TODOs im Kontext ihrer jeweiligen Position im Text bearbeiten,
- relevante `% MEMO:`-Kommentare als Kontext berücksichtigen,
- die Regeln für `TODO:`, `NOTE:` und `MEMO:` aus `../../LATEX.md` anwenden,
- nach Bearbeitung einen `% TODO:` gemäß `../../LATEX.md` durch einen aussagekräftigen `% NOTE:` ersetzen,
- bei wissenschaftlichen TODOs zusätzlich `../../RESEARCH.md` und `../../ZOTERO.md` beachten.

TODOs dürfen selbstständig bearbeitet werden, wenn sie zum aktuellen Arbeitsauftrag gehören oder der Nutzer ausdrücklich die Bearbeitung aller TODOs im Manuskript verlangt.

TODOs außerhalb des aktuellen Arbeitsauftrags nicht allein deshalb bearbeiten, weil sie im Manuskript vorhanden sind.

Nach der Bearbeitung das Dokument gemäß `../../LATEX.md` kompilieren und das erzeugte PDF prüfen.

## LaTeX und Bibliographie

- Präambel: Die vom Dokument eingebundene zentrale Präambel verwenden; sie ist über `../../@Vorlagen-Latex/` erreichbar.
- Bibliographie: Die zentrale Bibliographie ist über `../../Zotero.bib` erreichbar.
- Engine: XeLaTeX.
- Build aus `manuscript/`: `latexmk -xelatex -interaction=nonstopmode -halt-on-error -file-line-error -auxdir=auxiliary_files -outdir=. {{MIRROR:MAINFILE}}.tex`.
- Build-Artefakte: PDF und SyncTeX liegen neben der Hauptdatei in `manuscript/`; Hilfsdateien liegen in `manuscript/auxiliary_files/`.

## Aktueller Stand

Bei wesentlichen Arbeitsschritten diesen Stand aktualisieren; dauerhafte Entscheidungen in `DECISIONS.md` festhalten.
