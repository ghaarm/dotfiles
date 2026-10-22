# Projekt: {{PROJECT-NAME}}

<!--
Zweck: Dauerhaftes Vortragsziel, aktueller Arbeitsauftrag und Stand dieses Touying-Vortrags in Typst.
Das Ziel bleibt über Sitzungen hinweg bestehen. Den aktuellen Arbeitsauftrag
nur ändern, wenn sich die Aufgabe ändert; Fortschritte unter „Aktueller Stand“
und dauerhafte Entscheidungen in `DECISIONS.md` festhalten.
-->

## Vortragsziel und Rahmen

- Thema und Anlass des Vortrags: {{INPUT}}
- Publikum und Vorwissen: {{INPUT}}
- Kernaussage und gewünschter Erkenntnisgewinn: {{INPUT}}
- Vortragsdauer und Termin: {{INPUT}}
- Gewünschtes Ergebnis: Ein präsentationsfertiger Touying-Vortrag als PDF.
- Arbeitsgrundlage: bestehender Typst-/Touying-Entwurf, falls vorhanden.
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

- Hauptdatei: [manuscript/{{INPUT:MAINFILE}}.typ](manuscript/{{MIRROR:MAINFILE}}.typ).
- Suchprotokoll: [research/search-log.md](research/search-log.md).
- Aussagen und Belege: [research/EVIDENCE.md](research/EVIDENCE.md).
- Abbildungen: `manuscript/bilder-latex/` (Symlink auf das zentrale Abbildungsverzeichnis).

## Folien-TODOs

Die `// TODO:`-Kommentare in `manuscript/{{MIRROR:MAINFILE}}.typ` sind konkrete
Arbeitsaufträge. `// MEMO:` als Kontext berücksichtigen. Bearbeitete TODOs
stehen lassen und das Ergebnis unmittelbar darunter mit `// NOTE:`
dokumentieren, sofern der aktuelle Auftrag keine andere Regel vorgibt.
`// TODO: [USER]` ist von einer allgemeinen Aufforderung zur Bearbeitung aller
TODOs ausgenommen. Wissenschaftliche TODOs gemäß `../../RESEARCH.md` und
`../../ZOTERO.md` bearbeiten. TODOs außerhalb des aktuellen Arbeitsauftrags
nur auf ausdrücklichen Wunsch bearbeiten.

Nach Änderungen kompilieren und das PDF Folie für Folie auf Lesbarkeit,
Überläufe, Abbildungen und Quellenangaben prüfen.

## Touying, Build und Bibliographie

- Präsentationssystem: Touying in Typst; Theme und Seitenverhältnis in der Hauptdatei prüfen.
- Vorlagen/Imports: Lokale Typst-Dateien und Pakete aus den `#import`-Anweisungen verwenden; benötigte Touying-Version dort festhalten.
- Bibliographie: Die zentrale Bibliographie ist über `../../Zotero.bib` erreichbar; Einbindung und Zitierstil in der Hauptdatei prüfen.
- Compiler: Typst CLI.
- Build aus `manuscript/`: `typst compile --root / {{MIRROR:MAINFILE}}.typ` (für zentrale Dateien und absolute Imports).
- Build-Artefakt: `manuscript/{{MIRROR:MAINFILE}}.pdf`.

## Aktueller Stand

Bei wesentlichen Arbeitsschritten diesen Stand aktualisieren; dauerhafte Entscheidungen in `DECISIONS.md` festhalten.
