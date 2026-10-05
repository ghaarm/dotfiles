# Projekt: {{PROJECT-NAME}}

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

<!-- # Projekt: {{PROJECT-NAME}} -->

## Projektziel und Rahmen

- Allgemeine Absicht: ____

- Zielgruppe: ärztliche Kolleg:innen

- Gewünschtes Ergebnis: ____

- Vorhandenes Dokument: „____“.

<!-- - Arbeitsgrundlage: bestehender LaTeX-Entwurf und die Markdown-Dateien unter `research/`. -->

- Arbeitsgrundlage: bestehender LaTeX-Entwurf. 

- Rahmenbedingungen: Bestehende Gliederung, Gestaltung und Zitierweise erhalten, sofern der konkrete Auftrag keine Änderung vorsieht.

- Gesamtumfang und Abgabetermin: noch nicht festgelegt.

- Sprache: Deutsch.

- Relevante Zotero-Collections: `____` und insbesondere `____`.

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

  * ____


<!-- - Verbindliches Ausgangsmaterial: Die Ablehnungsbegründung in `research/mdk-grund-ablehnung.md` gemeinsam mit der Fallbeschreibung in `research/fallbeschreibung-mdk.md` berücksichtigen. Vor der inhaltlichen Überarbeitung beide Dateien lesen und die konkreten MDK-Einwände mit den dokumentierten Falldaten und der Literatur abgleichen. -->

- Verbindliches Ausgangsmaterial: ____. 

- Umfang / betroffene Abschnitte: noch nicht festgelegt.

- Erledigt, wenn: noch nicht festgelegt.

## Dateien

<!-- - Hauptdatei: [manuscript/thrombaspiration-antwort-mdk.tex](manuscript/thrombaspiration-antwort-mdk.tex). -->
- Hauptdatei: [manuscript/____.tex](manuscript/____.tex).

<!-- - Ergänzendes Ausgangsmaterial: [research/thrombaspiration-inari.md](research/thrombaspiration-inari.md). -->

<!-- - Ergänzendes Ausgangsmaterial: [research/____.md](research/____.md). -->

- Suchprotokoll: [research/search-log.md](research/search-log.md).

- Aussagen und Belege: [research/EVIDENCE.md](research/EVIDENCE.md).

- Abbildungen: `manuscript/figures/`.

- Vorhandenes PDF: [manuscript/____.pdf](manuscript/____.pdf).

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


Bei wesentlichen Arbeitsschritten diesen Stand aktualisieren; dauerhafte Entscheidungen in `DECISIONS.md` festhalten.

