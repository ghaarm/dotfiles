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

- Gewünschtes Ergebnis: Eine verständliche und praxisorientierte Anleitung für ärztliche Kolleg:innen zur Anwendung und klinischen Einordnung von {{MIRROR:TOPIC}}, die neben konkretem Handlungswissen auch Hintergründe und kritische Einordnung vermittelt.

- Rahmenbedingungen: Bestehende Gliederung, Gestaltung und Zitierweise erhalten, sofern der konkrete Auftrag keine Änderung vorsieht.

- Gesamtumfang und Abgabetermin: noch nicht festgelegt.

- Sprache: Deutsch.

- Relevante Zotero-Collection: `{{INPUT}}`; relevante Unterordner dieser Collection sind einzubeziehen.

Es gelten die allgemeinen Anweisungen im Arbeitsbereich: `../../AGENTS.md`, `../../RESEARCH.md`, `../../ZOTERO.md` und `../../LATEX.md`.

Für G'MICS-Texte gelten zusätzlich die G'MICS-spezifischen Stilvorgaben aus `../../STYLE_GUIDE_GMICS.md`.

## Didaktische Ausrichtung

Das G'MICS soll nicht nur konkrete Handlungsanweisungen vermitteln, sondern Verständnis und Neugier fördern.

Wo sinnvoll:

- erklären, warum eine Empfehlung oder Vorgehensweise sinnvoll ist,
- klinisch relevante Zusammenhänge verständlich machen,
- zum Nachfragen und Weiterdenken anregen,
- vermeintliche Selbstverständlichkeiten und etablierte Routinen kritisch hinterfragen,
- besonders anschauliche Beispiele, Größenordnungen und Vergleiche nutzen,
- interessante, überraschende oder erinnerungswürdige Zusatzinformationen einschließlich geeignetem „Partywissen“ einbeziehen,
- auf besonders informative, anschauliche oder didaktisch hilfreiche Abbildungen und Tabellen der Literatur aufmerksam machen.

Didaktische Vereinfachungen dürfen die fachliche Aussage nicht verfälschen. Eigene Vergleiche, Ableitungen oder Einordnungen klar von Aussagen der zugrunde liegenden Quellen unterscheiden.

Interessante Zusatzinformationen gemäß `../../RESEARCH.md` sind ausdrücklich erwünscht. Informationen mit besonderem didaktischem Wert können in den G'MICS-Text aufgenommen werden, wenn sie das Verständnis fördern, zum Nachfragen oder kritischen Hinterfragen anregen oder einen anderen erkennbaren didaktischen Mehrwert bieten.

## Abgrenzung

<!--
Optional. Hier festhalten, was ausdrücklich nicht Ziel dieses Projekts ist.
Nur ausfüllen, wenn eine bewusste Abgrenzung für die weitere Arbeit relevant ist.
-->

## Qualitätskriterien

<!--
Optional. Projektspezifische Kriterien festhalten, anhand derer das Ergebnis als ausreichend oder fertig beurteilt werden kann.
Nur projektspezifische Kriterien festhalten; allgemeine Qualitätsanforderungen aus `AGENTS.md` nicht wiederholen.
-->

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

Die `%TODO:`-Kommentare in `manuscript/{{MIRROR:MAINFILE}}.tex` sind als konkrete Arbeitsaufträge innerhalb des Manuskripts zu behandeln.

Bei Arbeiten am Manuskript:

- TODOs im Kontext ihrer jeweiligen Position im Text bearbeiten,
- relevante `%MEMO:`-Kommentare als Kontext berücksichtigen,
- die Regeln für `TODO:`, `NOTE:` und `MEMO:` aus `../../LATEX.md` anwenden,
- bearbeitete `%TODO:`-Kommentare gemäß `../../LATEX.md` unverändert stehen lassen und das Ergebnis unmittelbar darunter mit einem aussagekräftigen `%NOTE:` dokumentieren,
- bei wissenschaftlichen TODOs zusätzlich `../../RESEARCH.md` und `../../ZOTERO.md` beachten.

TODOs dürfen selbstständig bearbeitet werden, wenn sie zum aktuellen Arbeitsauftrag gehören oder der Nutzer ausdrücklich die Bearbeitung aller bearbeitbaren TODOs im Manuskript verlangt.

`%TODO: [USER]` ist gemäß `../../LATEX.md` von einer allgemeinen Aufforderung zur Bearbeitung aller TODOs ausgenommen.

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
