# Projekt: {{PROJECT-NAME}}

<!--
Zweck: Dauerhaftes Vortragsziel, aktueller Arbeitsauftrag und Stand dieses Beamer-Vortrags.
Das Ziel bleibt über Sitzungen hinweg bestehen. Den aktuellen Arbeitsauftrag
nur ändern, wenn sich die Aufgabe ändert; Fortschritte unter „Aktueller Stand“
und dauerhafte Entscheidungen in `DECISIONS.md` festhalten.
-->

## Vortragsziel und Rahmen

- Thema und Anlass des Vortrags: {{INPUT}}
- Publikum und Vorwissen: {{INPUT}}
- Kernaussage und gewünschter Erkenntnisgewinn: {{INPUT}}
- Vortragsdauer und Termin: {{INPUT}}
- Gewünschtes Ergebnis: Ein präsentationsfertiger Beamer-Vortrag als PDF.
- Arbeitsgrundlage: bestehender LaTeX-/Beamer-Entwurf, falls vorhanden.
- Rahmenbedingungen: Bestehende Gestaltung und Zitierweise erhalten, sofern der konkrete Auftrag keine Änderung vorsieht.
- Sprache: Deutsch.
- Relevante Zotero-Collection: `{{INPUT}}`; relevante Unterordner dieser Collection sind einzubeziehen.

Es gelten die allgemeinen Anweisungen aus `../../AGENTS.md` sowie die dort
für die jeweilige Aufgabe referenzierten spezialisierten Anweisungen.

## Dramaturgie und Folien

Den Vortrag auf eine Leitfrage oder Kernaussage ausrichten. Die Folien in einer
für das Publikum verständlichen Reihenfolge aufbauen und ihren Umfang an die
Vortragsdauer anpassen. Pro Folie eine erkennbare Hauptaussage; Text,
Abbildungen und Quellenangaben müssen in der Projektion lesbar sein. Details,
die mündlich erläutert werden, nur bei Bedarf auf die Folien setzen.

## Abgrenzung

<!-- Optional: Was gehört ausdrücklich nicht zum Projekt? -->

## Qualitätskriterien

<!-- Optional: Projektspezifische Kriterien ergänzen. -->

## Aktueller Arbeitsauftrag

<!-- Nur ändern, wenn sich die Aufgabe ändert; Fortschritt unter „Aktueller Stand“ festhalten. -->

- Aufgabe:
  * {{INPUT}}

## Dateien und Ressourcen

### Ausgangsmaterial

Notizen, kopierte Chats und Rechercheergebnisse können Themen, Argumente und
Quellenhinweise liefern. Wissenschaftliche und medizinische Aussagen, Zahlen
und Literaturangaben daraus anhand maßgeblicher Originalquellen gemäß
`../../RESEARCH.md` prüfen. Ausgangsmaterial, geprüfte Belege und eigene
Schlussfolgerungen klar unterscheiden.

<!-- Hier vorhandenes Ausgangsmaterial eintragen, zum Beispiel: -->
- [research/notizen.md](research/notizen.md)
- [research/openevidence.md](research/openevidence.md)

### Projektdateien

- Hauptdatei: [manuscript/{{INPUT:MAINFILE}}.tex](manuscript/{{MIRROR:MAINFILE}}.tex).
- Suchprotokoll: [research/search-log.md](research/search-log.md).
- Aussagen und Belege: [research/EVIDENCE.md](research/EVIDENCE.md).
- Abbildungen: `manuscript/bilder-latex/` (Symlink auf das zentrale Abbildungsverzeichnis).

## Folien-TODOs

Die `%TODO:`-Kommentare in `manuscript/{{MIRROR:MAINFILE}}.tex` sind konkrete
Arbeitsaufträge. `%MEMO:` als Kontext berücksichtigen und die Regeln für
`TODO:`, `NOTE:` und `MEMO:` aus `../../LATEX.md` anwenden. Bearbeitete
`%TODO:`-Kommentare gemäß dieser Datei stehen lassen und das Ergebnis direkt
darunter mit `%NOTE:` dokumentieren. Für wissenschaftliche TODOs zusätzlich
`../../RESEARCH.md` und `../../ZOTERO.md` beachten. `%TODO: [USER]` ist von
einer allgemeinen Aufforderung zur Bearbeitung aller TODOs ausgenommen.
TODOs außerhalb des aktuellen Arbeitsauftrags nur auf ausdrücklichen Wunsch
bearbeiten.

Nach Änderungen kompilieren und das PDF Folie für Folie auf Lesbarkeit,
Überläufe, Abbildungen und Quellenangaben prüfen.

## Beamer, Build und Bibliographie

- Dokumentklasse: `beamer`; Theme und Seitenverhältnis in der Hauptdatei prüfen.
- Präambeln für ChatGPT Work: `../../@Vorlagen-Latex-gpt/` ist die bearbeitbare Arbeitskopie gemäß `../../AGENTS.md` und `../../LATEX.md`.
- Zentrale Präambeln: `../../@Vorlagen-Latex/` ist eine READ-ONLY-Referenz und keine Build-Voraussetzung für ChatGPT Work.
- Bibliographie: Die zentrale Bibliographie ist über `../../Zotero.bib` erreichbar.
- Engine: XeLaTeX.
- Build aus `manuscript/`: `latexmk -xelatex -interaction=nonstopmode -halt-on-error -file-line-error -auxdir=auxiliary_files -outdir=. {{MIRROR:MAINFILE}}.tex`.
- Build-Artefakte: PDF und SyncTeX liegen in `manuscript/`, Hilfsdateien in `manuscript/auxiliary_files/`.

## Aktueller Stand

Bei wesentlichen Arbeitsschritten diesen Stand aktualisieren; dauerhafte Entscheidungen in `DECISIONS.md` festhalten.
