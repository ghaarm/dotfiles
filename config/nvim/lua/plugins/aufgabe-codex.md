# Codex-Auftrag: Buffer-Verwaltung und Buffer-Anzeige von kanban.nvim korrigieren

## 1. Ausgangssituation

Ich verwende Neovim mit `arakkkkk/kanban.nvim` und mehreren Markdown-basierten Kanban-Boards.

Die Kanban-Dateien heißen beispielsweise:

- `kanban-heute.md`
- `kanban-gmics.md`
- `kanban-qssepsis.md`
- `kanban-nextcloud-golo.md`

Ich kann zwischen der Markdown-Ansicht und der grafischen Board-Ansicht wechseln.

Dabei sind zwei Probleme aufgefallen:

1. In der grafischen Board-Ansicht zeigt Lualine als Buffername `[No Name]` an.
2. Bei jedem erneuten Öffnen eines Boards steigt die Gesamtzahl der Neovim-Buffer um ungefähr zehn.

Beide Probleme sollen untersucht und möglichst mit minimalen Änderungen behoben werden.

**Wichtig:** Dieser Auftrag ist unabhängig von meiner GTD-/Next-Action-Erweiterung. Deren Funktionalität darf nicht verändert werden.

---

## 2. Problem A: Buffername in der grafischen Board-Ansicht

### Aktuelles Verhalten

In der grafischen Kanban-Ansicht liefert:

```vim
:echo bufname('%')
```

einen leeren String.

```vim
:echo &buftype
```

liefert:

```text
nofile
```

Lualine zeigt deshalb `[No Name]` an.

Die ursprüngliche Markdown-Datei bleibt als benannter Buffer erhalten.

### Gewünschtes Verhalten

In der grafischen Board-Ansicht soll Lualine ausschließlich den Projektnamen anzeigen.

Dieser wird aus dem Dateinamen der zugehörigen Markdown-Datei abgeleitet:

1. Verzeichnisanteil entfernen.
2. Führendes `kanban-` entfernen.
3. Abschließendes `.md` entfernen.

Beispiele:

| Markdown-Datei | Gewünschte Anzeige |
|---|---|
| `kanban-heute.md` | `heute` |
| `kanban-gmics.md` | `gmics` |
| `kanban-qssepsis.md` | `qssepsis` |
| `kanban-nextcloud-golo.md` | `nextcloud-golo` |

### Implementierung

**Bevorzugte Lösung:**

Passe die bestehende Lualine-Konfiguration so an, dass sie erkennt, ob das aktuelle Fenster zur grafischen Ansicht von `kanban.nvim` gehört.

Wenn ja, soll statt des normalen Dateinamens der aus dem Markdown-Dateinamen abgeleitete Projektname angezeigt werden.

Wenn nein, soll die bisherige Lualine-Anzeige unverändert bleiben.

Verwende möglichst den bereits vorhandenen Pfad `kanban.kanban_md_path` oder eine andere zuverlässige Zuordnung des aktuellen Board-Fensters zur Markdown-Datei.

### Anforderungen

- Keine Änderung der tatsächlichen Markdown-Dateinamen.
- Keine Umbenennung der ursprünglichen Markdown-Buffer.
- Keine pauschale Umbenennung aller `nofile`-Buffer.
- Keine Veränderung der Anzeige anderer Plugins.
- Die Anzeige muss beim Wechsel zwischen unterschiedlichen Boards korrekt aktualisiert werden.
- Nach dem Schließen des Boards muss die normale Lualine-Anzeige wiederhergestellt sein.
- Bei mehreren gleichzeitig vorhandenen Kanban-Fenstern muss die Anzeige zum jeweiligen Fenster passen.
- Die Lösung darf nicht ausschließlich anhand von `buftype=nofile` entscheiden, ob ein Buffer zu Kanban gehört.

Falls eine zuverlässige Erkennung über Lualine nicht möglich ist, prüfe eine alternative Lösung mit intern eindeutig benannten Kanban-Buffern.

Dabei dürfen keine Namenskonflikte zwischen den verschiedenen Board-Komponenten entstehen.

---

## 3. Problem B: Kontinuierlich steigende Buffer-Anzahl

### Beobachtetes Verhalten

Beim wiederholten Schließen und erneuten Öffnen eines Kanban-Boards wurden folgende Werte gemessen:

| Zustand | Gesamtzahl Buffer | Geladene Buffer |
|---|---:|---:|
| Board geöffnet | 75 | 17 |
| Board geschlossen | 75 | 11 |
| Board erneut geöffnet | 85 | 17 |

Bei vorherigen Öffnungen stieg die Gesamtzahl ebenfalls:

```text
55 → 65 → 75 → 85
```

Die Zahl der geladenen Buffer sinkt beim Schließen von 17 auf 11 und steigt beim erneuten Öffnen wieder auf 17.

Die Gesamtzahl wächst dagegen kontinuierlich.

Die Buffer wurden mit folgenden Neovim-Funktionen untersucht:

```lua
vim.api.nvim_list_bufs()
vim.api.nvim_buf_is_valid()
vim.api.nvim_buf_is_loaded()
```

Bei einer Messung waren alle 75 Buffer gültig, aber nur 17 geladen.

### Vermutete Ursache

`kanban.nvim` erzeugt beim Öffnen temporäre Buffer für die grafische Darstellung.

Beim Schließen werden diese offenbar teilweise entladen, aber nicht vollständig aus der Bufferverwaltung entfernt.

Diese Erklärung ist bisher eine Hypothese und muss anhand des tatsächlichen Codes überprüft werden.

---

## 4. Untersuchung der Buffer-Verwaltung

Untersuche zunächst die tatsächliche Implementierung von `kanban.nvim`.

Prüfe insbesondere:

- Wo Board-Buffer erzeugt werden.
- Wo Spalten-Buffer erzeugt werden.
- Wo Aufgaben-Buffer erzeugt werden.
- Welche Buffer beim Schließen des Boards erhalten bleiben.
- Welche Buffer nur entladen werden.
- Welche Buffer vollständig gelöscht werden.
- Ob Buffer-Referenzen in Lua-Tabellen zurückbleiben.
- Ob Autocommands, Fenster oder andere Plugin-Komponenten auf diese Buffer verweisen.
- Ob bei jedem erneuten Öffnen dieselben Buffer wiederverwendet oder neue angelegt werden.

Untersuche dabei die vorhandenen lokalen Anpassungen des Plugins.

Verändere nicht ungeprüft die ursprüngliche Buffer-Verwaltung.

### Diagnose

Ermittle für die betroffenen Buffer:

- Buffer-ID
- Buffername
- `buftype`
- `filetype`
- `buflisted`
- `modified`
- Gültigkeitsstatus
- Ladezustand
- Zugehörigkeit zur jeweiligen Kanban-Instanz

Unterscheide zwischen Buffern des Kanban-Plugins und Buffern anderer Neovim-Plugins.

**Wichtig:** Die kontinuierlich steigende Gesamtzahl allein beweist noch keinen Speicherverlust. Entscheidend ist, ob nicht mehr benötigte Kanban-Buffer gültig bleiben und unnötig Ressourcen oder Bufferlisten-Einträge belegen.

---

## 5. Gewünschte Korrektur der Buffer-Verwaltung

Falls sich bestätigt, dass `kanban.nvim` nicht mehr benötigte temporäre Buffer zurücklässt, korrigiere deren Lebenszyklus.

### Beim Öffnen eines Boards

- Nur die tatsächlich benötigten Buffer erzeugen.
- Bestehende gültige Buffer wiederverwenden, sofern dies der Plugin-Architektur entspricht.
- Keine veralteten Buffer-Referenzen übernehmen.

### Beim Schließen eines Boards

- Alle ausschließlich für diese Board-Instanz erzeugten temporären Buffer identifizieren.
- Zugehörige Fenster und sonstige Referenzen ordnungsgemäß freigeben.
- Nicht mehr benötigte temporäre Buffer vollständig löschen.
- Dafür bei geeigneten Buffern `vim.api.nvim_buf_delete()` verwenden.
- Falls erforderlich, zugehörige Autocommands oder andere Ressourcen entfernen.

### Sicherheitsregeln

Folgende Buffer dürfen nicht gelöscht werden:

- Ursprüngliche Markdown-Dateien.
- Andere normale Datei-Buffer.
- Buffer anderer Plugins.
- Buffer anderer noch geöffneter Kanban-Instanzen.
- Buffer mit ungespeicherten Änderungen, die noch nicht zuverlässig in die Markdown-Datei übernommen wurden.

Keine globale Bereinigung aller unbenannten oder `nofile`-Buffer durchführen.

Keine pauschalen Befehle wie `:%bd` oder vergleichbare globale Buffer-Löschoperationen verwenden.

**Es dürfen ausschließlich Buffer gelöscht werden, deren Zugehörigkeit zur geschlossenen Kanban-Instanz eindeutig feststeht.**

---

## 6. Bestehende Funktionen erhalten

Die Korrektur darf folgende Funktionen nicht beeinträchtigen:

- Öffnen und Schließen von Kanban-Boards.
- Wechsel zwischen Markdown- und Board-Ansicht.
- Bearbeiten von Aufgaben.
- Verschieben von Aufgaben zwischen TODO, WIP und DONE.
- Speichern von Aufgaben.
- Bearbeiten von Aufgabenbeschreibungen.
- Bestehende Keymaps.
- `kanban-heute-sync.lua`.
- `kanban-next-action.lua`, sofern bereits vorhanden.
- Synchronisierung zwischen Projekt-Kanbans und Tages-Kanban.
- Tagesreset.
- JSON-Metadaten.

Insbesondere dürfen keine Änderungen an Aufgaben verloren gehen, wenn ein Board geschlossen wird.

---

## 7. Tests

Führe nach der Implementierung folgende Tests durch.

### Test A: Buffer-Anzeige

Öffne nacheinander:

```text
kanban-heute.md
kanban-gmics.md
kanban-qssepsis.md
kanban-nextcloud-golo.md
```

Prüfe jeweils, ob Lualine in der grafischen Board-Ansicht korrekt anzeigt:

```text
heute
gmics
qssepsis
nextcloud-golo
```

Prüfe außerdem, ob nach dem Zurückwechseln zur Markdown-Ansicht wieder die normale Dateianzeige erscheint.

### Test B: Buffer-Lebenszyklus

1. Neovim mit einer Kanban-Markdown-Datei starten.
2. Anzahl gültiger und geladener Buffer erfassen.
3. Board öffnen.
4. Anzahl erneut erfassen.
5. Board schließen.
6. Anzahl erneut erfassen.
7. Vorgang mindestens zehnmal wiederholen.

Erwartung:

Die Anzahl der gültigen, nicht mehr verwendeten Kanban-Buffer darf nicht mit jedem Durchlauf weiter steigen.

Die Anzahl geladener Buffer muss nach dem Schließen wieder auf den erwarteten Ausgangswert zurückkehren.

Berücksichtige dabei, dass Neovim intern fortlaufende Buffer-IDs vergeben kann. Eine steigende höchste Buffer-ID ist für sich genommen kein Fehler.

### Test C: Datensicherheit

1. Eine Aufgabe bearbeiten.
2. Änderungen speichern.
3. Board schließen.
4. Markdown-Datei erneut öffnen.
5. Prüfen, ob die Änderung erhalten geblieben ist.

### Test D: Andere Buffer

Prüfe, dass normale Markdown-, Lua- und andere Plugin-Buffer beim Schließen des Kanban-Boards unverändert erhalten bleiben.

### Test E: Wiederholtes Öffnen

Öffne und schließe unterschiedliche Projekt-Kanbans mehrfach hintereinander.

Prüfe, dass weder Buffer-Reste noch falsche Projektbezeichnungen in Lualine entstehen.

---

## 8. Implementierungsregeln

- Bevorzuge kleine, gezielte Änderungen.
- Verwende bestehende Plugin-Funktionen, sofern möglich.
- Vermeide unnötige neue Module.
- Keine neuen Abhängigkeiten installieren, wenn sie nicht erforderlich sind.
- Keine Änderungen an der GTD-Logik.
- Keine Änderung des Markdown-Datenformats.
- Keine Änderung der JSON-Metadaten.
- Keine zusätzliche globale Buffer-Bereinigung.
- Keine neuen Autocommands, sofern die bestehenden Mechanismen ausreichen.

Falls die lokale Version von `kanban.nvim` direkt angepasst werden muss, prüfe zunächst, wie das Plugin über Lazy.nvim installiert und aktualisiert wird.

Stelle sicher, dass die Korrektur nicht beim nächsten Plugin-Update unbeabsichtigt verloren geht. Bevorzuge eine wartbare Lösung in meiner eigenen Neovim-Konfiguration, sofern technisch sinnvoll.

---

## 9. Abschlussbericht

Berichte nach der Implementierung:

1. Welche Ursache für `[No Name]` gefunden wurde.
2. Wie die gewünschte Projektbezeichnung in Lualine umgesetzt wurde.
3. Warum die Buffer-Anzahl bei jedem Öffnen gestiegen ist.
4. Welche Buffer tatsächlich zurückgeblieben sind.
5. Wie deren Bereinigung implementiert wurde.
6. Welche Dateien geändert wurden.
7. Welche Tests durchgeführt wurden.
8. Wie sich die Buffer-Anzahl vor und nach der Korrektur verhält.
9. Ob verbleibende Einschränkungen bestehen.

**Ziel:** In der grafischen Kanban-Ansicht soll Lualine den jeweiligen Projektnamen anzeigen. Gleichzeitig sollen temporäre Kanban-Buffer beim Schließen korrekt freigegeben werden, ohne andere Buffer oder bestehende Kanban-Funktionen zu beeinträchtigen.
