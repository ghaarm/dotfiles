# Projekt: {{PROJECT-NAME}}

<!--
Zweck: Dauerhaftes Projektziel, aktueller Arbeitsauftrag und Stand dieses LaTeX-Projekts.

Hier hinein gehören:
- Projektziel und Rahmen: allgemeine Absicht, Zielgruppe bzw. Nutzerkreis, gewünschtes Ergebnis und Rahmenbedingungen.
- Aktueller Arbeitsauftrag: die konkrete nächste Aufgabe.
- Relevante Dateien, Ressourcen und Zotero-Collection.
- LaTeX-Hauptdatei, Präambel, Engine, Build und externe Abhängigkeiten.
- Aktueller Stand: Erledigtes, offene Punkte, wichtige Einschränkungen und nächster Schritt.

Das Projektziel bleibt über Sitzungen hinweg bestehen.
Den aktuellen Arbeitsauftrag nur ändern, wenn sich die Aufgabe ändert; eine neue Sitzung kann denselben Auftrag fortsetzen.
Den aktuellen Stand bei wesentlichen Fortschritten aktualisieren.
Dauerhafte Entscheidungen in `DECISIONS.md` festhalten.
-->

## Projektziel und Rahmen

- Allgemeine Absicht: {{INPUT}}

- Zielgruppe bzw. Nutzerkreis: {{INPUT}}

- Gewünschtes Ergebnis: {{INPUT}}

- Arbeitsgrundlage: bestehender LaTeX-Entwurf.

- Rahmenbedingungen: Bestehende Gliederung, Gestaltung und Zitierweise erhalten, sofern der konkrete Auftrag keine Änderung vorsieht.

- Gesamtumfang und Abgabetermin: noch nicht festgelegt.

- Sprache: Deutsch.

Es gelten die allgemeinen Anweisungen im Arbeitsbereich aus `../../AGENTS.md` sowie die dort für die jeweilige Aufgabe referenzierten spezialisierten Anweisungen. Für LaTeX-Arbeiten gilt insbesondere `../../LATEX.md`.

## Aktueller Arbeitsauftrag

<!--
Hier die konkrete nächste Aufgabe eintragen. Nur aktualisieren, wenn sich die Aufgabe ändert,
nicht bei jedem Sitzungswechsel. Das übergeordnete Projektziel bleibt im vorherigen Abschnitt stehen.
Fortschritte und nächste Schritte unter „Aktueller Stand“ festhalten.
-->

- Aufgabe:

  * {{INPUT}}

## Dateien und Ressourcen

- Hauptdatei: [manuscript/{{INPUT:MAINFILE}}.tex](manuscript/{{MIRROR:MAINFILE}}.tex).

<!--
Optionales ergänzendes Ausgangsmaterial hier eintragen, wenn neben dem Manuskript
weitere projektinterne Dateien verbindlich berücksichtigt werden sollen.

Beispiel:
- Ergänzendes Ausgangsmaterial: [research/notizen.md](research/notizen.md).
-->

- Suchprotokoll: [research/search-log.md](research/search-log.md).

- Aussagen und Belege: [research/EVIDENCE.md](research/EVIDENCE.md).

- Abbildungen: `manuscript/figures/`.

<!-- - Vorhandenes PDF: [manuscript/{{MIRROR:MAINFILE}}.pdf](manuscript/{{MIRROR:MAINFILE}}.pdf). -->

<!-- - Übernommene Build-Hilfsdateien: `manuscript/auxiliary_files/` sowie SyncTeX-Dateien direkt in `manuscript/`. -->

## Manuskript-TODOs

Die `% TODO:`-Kommentare in `manuscript/{{MIRROR:MAINFILE}}.tex` sind als konkrete Arbeitsaufträge innerhalb des Manuskripts zu behandeln.

Bei Arbeiten am Manuskript:

- TODOs im Kontext ihrer jeweiligen Position im Text bearbeiten,
- relevante `% MEMO:`-Kommentare als Kontext berücksichtigen,
- die Regeln für `TODO:`, `NOTE:` und `MEMO:` aus `../../LATEX.md` anwenden,
- bearbeitete `% TODO:`-Kommentare gemäß `../../LATEX.md` unverändert stehen lassen und das Ergebnis unmittelbar darunter mit einem aussagekräftigen `% NOTE:` dokumentieren,
- bei wissenschaftlichen TODOs zusätzlich `../../RESEARCH.md` und `../../ZOTERO.md` beachten.

TODOs dürfen selbstständig bearbeitet werden, wenn sie zum aktuellen Arbeitsauftrag gehören oder der Nutzer ausdrücklich die Bearbeitung aller bearbeitbaren TODOs im Manuskript verlangt.

`% TODO: [USER]` ist gemäß `../../LATEX.md` von einer allgemeinen Aufforderung zur Bearbeitung aller TODOs ausgenommen.

TODOs außerhalb des aktuellen Arbeitsauftrags nicht allein deshalb bearbeiten, weil sie im Manuskript vorhanden sind.

Nach der Bearbeitung das Dokument gemäß `../../LATEX.md` kompilieren und das erzeugte PDF prüfen.



## LaTeX und Bibliographie

- Präambel: Die vom Dokument eingebundene zentrale Präambel verwenden; sie ist über `../../@Vorlagen-Latex/` erreichbar.
- Bibliographie: Die zentrale Bibliographie ist über `../../Zotero.bib` erreichbar.
- Relevante Zotero-Collection: `{{INPUT}}`; relevante Unterordner dieser Collection sind einzubeziehen.
- Engine: XeLaTeX.
- Build aus `manuscript/`: `latexmk -xelatex -interaction=nonstopmode -halt-on-error -file-line-error -auxdir=auxiliary_files -outdir=. {{MIRROR:MAINFILE}}.tex`.
- Build-Artefakte: PDF und SyncTeX liegen neben der Hauptdatei in `manuscript/`; Hilfsdateien liegen in `manuscript/auxiliary_files/`.

## Aktueller Stand

Bei wesentlichen Arbeitsschritten diesen Stand aktualisieren; dauerhafte Entscheidungen in `DECISIONS.md` festhalten.
