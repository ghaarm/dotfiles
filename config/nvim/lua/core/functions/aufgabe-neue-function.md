# Codex-Auftrag: GTD Next Actions in mein Kanban-System integrieren

## 1. Ziel

Erweitere meine bestehende Neovim-Konfiguration für `arakkkkk/kanban.nvim` um eine GTD-Funktion (*Getting Things Done* nach David Allen).

Ich verwende mehrere Projekt-Kanbans und ein zentrales Tages-Kanban (`kanban-heute.md`).

Die Grundidee lautet:

- **Projekt-Kanban:** Enthält übergeordnete Aufgaben und Projektziele.
- **Next Action:** Beschreibt den nächsten konkreten, unmittelbar ausführbaren Handlungsschritt einer Projektaufgabe.
- **Kanban Heute:** Enthält die konkreten Handlungen, die ich heute bearbeiten möchte.
- **DONE im Projekt-Kanban:** Dokumentiert die tatsächlich abgeschlossenen Next Actions als eigenständige Karten.

Ich möchte Next Actions nur einmal formulieren und anschließend automatisch zwischen Projekt-Kanban und Tages-Kanban verwalten.

Die bestehende Kanban-Funktionalität muss vollständig erhalten bleiben.

---

## 2. Architektur und Modularisierung

Untersuche zunächst die vorhandenen Dateien und ihre tatsächlichen Pfade.

Die relevanten Module sind:

```text
lua/
├── plugins/
│   └── kanban-nvim.lua
│
├── kanban-heute-sync.lua
└── kanban-next-action.lua       # Neu erstellen
```

### `kanban-nvim.lua`

Verantwortlich für:

- Konfiguration von `arakkkkk/kanban.nvim`
- Grafische Darstellung
- Navigation
- Allgemeine Kanban-Funktionen
- Bereits vorhandene Anpassungen des Plugins

Diese Datei möglichst nicht verändern.

### `kanban-heute-sync.lua`

Bleibt der zentrale Einstiegspunkt für:

- Keymaps
- Übernahme normaler Aufgaben nach Heute
- Bidirektionale Status-Synchronisierung normaler Aufgaben
- Zuordnung neuer Heute-Aufgaben zu Projekten
- Tagesreset
- JSON-Metadaten
- Autocommands und Synchronisierungssteuerung

Dieses Modul soll die GTD-Funktionen aufrufen, aber die eigentliche GTD-Geschäftslogik nicht selbst enthalten.

### `kanban-next-action.lua` – neue Datei

Implementiere hier die GTD-spezifischen Funktionen:

- Next Actions innerhalb von Projektkarten erkennen.
- Next Actions aus Projektkarten auslesen.
- Next Actions nach Heute übernehmen.
- Zugehörige Projektkarten identifizieren.
- Den Status von Next Actions auswerten.
- Erledigte Next Actions im Projekt-Kanban nach DONE übernehmen.
- Das `Next:`-Feld der Projektkarte nach Abschluss leeren.
- Doppelte Übernahmen und doppelte Abschlüsse verhindern.
- Konflikte und Sonderfälle behandeln.

### Architekturregeln

1. Keine zweite unabhängige Synchronisierung implementieren.
2. Keine konkurrierenden Autocommands anlegen.
3. Keine zweite JSON-Metadatendatei erstellen.
4. Beide Module müssen dieselben Synchronisierungsmetadaten verwenden.
5. Gemeinsame Hilfsfunktionen bei Bedarf in ein separates Modul auslagern.
6. Zirkuläre Modulabhängigkeiten vermeiden.
7. Die bestehende Funktionalität muss rückwärtskompatibel bleiben.

**Wichtig:** `kanban-heute-sync.lua` bleibt die zentrale Steuerung. `kanban-next-action.lua` implementiert ausschließlich die neue GTD-Logik.

---

## 3. Markdown-Datenmodell

Eine Projektkarte kann eine Next Action enthalten.

Beispiel:

```markdown
## WIP (max. 3)

- [ ] QS Sepsis: Dokumentationsprozess finalisieren
    Next: IT wegen SOFA-Hotscreen kontaktieren
```

Die erste Zeile beschreibt das übergeordnete Projektziel.

Das Feld `Next:` beschreibt eine konkrete Handlung.

### Verbindliche Regeln

- `Next:` gehört zur jeweiligen Projektkarte.
- Es ist keine eigenständige Kanban-Aufgabe.
- Pro Projektkarte wird zunächst maximal eine aktive Next Action unterstützt.
- Das Feld kann leer sein.
- Normale Aufgaben ohne `Next:` bleiben unverändert.
- Die Erkennung muss sowohl mit Tabulatoren als auch mit Leerzeichen zur Einrückung funktionieren.
- Die übrigen Beschreibungszeilen einer Projektkarte müssen erhalten bleiben.

Beispiel einer normalen Aufgabe:

```markdown
- [ ] Auto waschen
```

Beispiel einer Projektaufgabe:

```markdown
- [ ] QS Sepsis: Dokumentationsprozess finalisieren
    Next: IT wegen SOFA-Hotscreen kontaktieren
```

Nur die zweite Aufgabe verwendet die neue GTD-Logik.

---

## 4. Übernahme nach Heute mit `<leader>kh`

Die bestehende Keymap `<leader>kh` bleibt erhalten.

Die Funktion muss künftig zwischen normalen Aufgaben und Projektkarten mit Next Action unterscheiden.

### Fall A: Normale Aufgabe

Wenn die ausgewählte Aufgabe kein nichtleeres `Next:`-Feld besitzt:

- Bisheriges Verhalten beibehalten.
- Aufgabe nach Heute übernehmen.
- Bisherige bidirektionale Status-Synchronisierung verwenden.
- Vorhandene Dublettenprüfung beibehalten.

### Fall B: Projektkarte mit Next Action

Wenn die ausgewählte Projektkarte ein nichtleeres `Next:`-Feld besitzt:

1. Die ausgewählte Projektkarte ermitteln.
2. Das `Next:`-Feld auslesen.
3. Ausschließlich den Text der Next Action nach Heute übernehmen.
4. Die Next Action als eigenständige Aufgabe in TODO einfügen.
5. Eine eindeutige Verknüpfung zur ursprünglichen Projektkarte speichern.
6. Die ursprüngliche Projektkarte unverändert lassen.
7. Das `Next:`-Feld im Projekt nicht entfernen oder verändern.

### Beispiel

**Projekt-Kanban vor der Übernahme:**

```markdown
## WIP (max. 3)

- [ ] QS Sepsis: Dokumentationsprozess finalisieren
    Next: IT wegen SOFA-Hotscreen kontaktieren
```

**Kanban Heute nach `<leader>kh`:**

```markdown
## TODO

- [ ] IT wegen SOFA-Hotscreen kontaktieren
```

Die Next Action beginnt in Heute immer in TODO, unabhängig davon, ob die Projektkarte in TODO oder WIP steht.

### Doppelte Übernahme verhindern

Wurde dieselbe Next Action derselben Projektkarte bereits nach Heute übernommen, darf keine zweite Karte entstehen.

Stattdessen eine verständliche Meldung ausgeben.

---

## 5. Statusänderungen von Next Actions

Die Statusänderungen einer Next Action dürfen nicht automatisch den Status der übergeordneten Projektkarte verändern.

### TODO → WIP

Wenn eine Next Action in Heute nach WIP verschoben wird:

- Die Next Action steht in Heute unter WIP.
- Die Projektkarte bleibt in ihrer bisherigen Spalte.
- Das `Next:`-Feld bleibt unverändert.
- Im Projekt-Kanban wird keine zusätzliche WIP-Karte erzeugt.

### WIP → TODO

Wenn eine Next Action wieder nach TODO verschoben wird:

- Nur ihr Status im Tages-Kanban ändert sich.
- Die Projektkarte bleibt unverändert.

### TODO/WIP → DONE

Wenn eine Next Action in Heute nach DONE verschoben und gespeichert wird:

1. Die zugehörige Projektkarte eindeutig identifizieren.
2. Prüfen, ob die Next Action bereits abgeschlossen wurde.
3. Die Next Action als eigenständige erledigte Karte in die DONE-Spalte des Projekt-Kanbans übernehmen.
4. Das zugehörige `Next:`-Feld in der ursprünglichen Projektkarte leeren.
5. Die übergeordnete Projektkarte in ihrer bisherigen Spalte belassen.
6. Die erledigte Next Action in Heute bis zum Tagesreset unter DONE belassen.
7. Den Abschluss in den gemeinsamen JSON-Metadaten dokumentieren.
8. Verhindern, dass ein erneutes Speichern denselben Abschluss erneut verarbeitet.

### Erwartetes Ergebnis

**Projekt-Kanban nach Abschluss:**

```markdown
## WIP (max. 3)

- [ ] QS Sepsis: Dokumentationsprozess finalisieren
    Next:

## DONE

- [x] IT wegen SOFA-Hotscreen kontaktieren
```

**Kanban Heute nach Abschluss:**

```markdown
## DONE

- [x] IT wegen SOFA-Hotscreen kontaktieren
```

### Wichtige Festlegungen

Die erledigte Next Action wird im Projekt-Kanban als eigenständige DONE-Karte dokumentiert.

Es darf kein zusätzlicher `Done:`-Abschnitt innerhalb der ursprünglichen Projektkarte angelegt werden.

Die Projektkarte darf nicht automatisch nach DONE verschoben werden.

Der Abschluss der übergeordneten Projektaufgabe bleibt eine bewusste manuelle Entscheidung.

---

## 6. Weitere Next Actions

Nach Abschluss der bisherigen Next Action ist das Feld `Next:` leer.

Ich kann anschließend eine neue Handlung eintragen:

```markdown
## WIP (max. 3)

- [ ] QS Sepsis: Dokumentationsprozess finalisieren
    Next: IT-Rückmeldung in Prozessdokument einarbeiten

## DONE

- [x] IT wegen SOFA-Hotscreen kontaktieren
```

Mit `<leader>kh` wird die neue Next Action nach Heute übernommen.

Dieser Ablauf muss beliebig oft wiederholbar sein.

Die bereits abgeschlossenen Next Actions bleiben in der DONE-Spalte des Projekt-Kanbans erhalten.

---

## 7. JSON-Metadaten und Aufgabenidentität

Die bestehende Synchronisierung verwendet `kanban-heute-sync.json`.

Diese Datei muss weiterhin verwendet werden.

Erweitere das Datenmodell um zwei Verknüpfungstypen:

- `normal`: Bisherige bidirektionale Status-Synchronisierung.
- `next_action`: Neue GTD-Synchronisierung.

### Rückwärtskompatibilität

Bestehende JSON-Einträge ohne Typangabe müssen weiterhin als normale Aufgaben behandelt werden.

Vorhandene Zuordnungen dürfen nicht verloren gehen.

### Identifikation

Für Next Actions müssen folgende Informationen eindeutig nachvollziehbar sein:

- Projekt-Kanban-Datei
- Übergeordnete Projektkarte
- Next-Action-Text
- Zugehörige Aufgabe in Heute
- Bearbeitungs- und Abschlusszustand

Die bisherige Identifikation anhand von Aufgabentiteln allein ist fehleranfällig.

Entwickle eine robuste Lösung, die auch dann funktioniert, wenn verschiedene Projektkarten gleichlautende Next Actions enthalten.

Prüfe insbesondere stabile IDs für Projektkarten und Next Actions.

Die IDs dürfen die grafische Darstellung von Kanban.nvim nicht beeinträchtigen.

Falls zusätzliche Markdown-Metadaten erforderlich sind, müssen sie mit dem vorhandenen Parser und der Speicherlogik von Kanban.nvim kompatibel sein.

### JSON-Formatierung

Die JSON-Datei soll weiterhin:

- Lesbar formatiert sein.
- Zwei Leerzeichen Einrückung verwenden.
- Bestehende Einträge erhalten.
- Bei Änderungen zuverlässig gespeichert werden.

---

## 8. Umgang mit bestehenden Funktionen

Die folgenden Funktionen müssen weiterhin funktionieren.

### `<leader>kh`

Normale Aufgabe oder Next Action nach Heute übernehmen.

### `<leader>km`

Eine direkt in Heute erstellte Aufgabe einem Projekt-Kanban zuordnen.

Dabei gilt weiterhin:

- Noch nicht zugeordnet: Projekt-Picker öffnen und Aufgabe zuordnen.
- Bereits zugeordnet: Hinweis anzeigen und keine zweite Kopie erzeugen.
- Veraltete Zuordnungen erkennen, wenn die Projektaufgabe inzwischen gelöscht wurde.

### `<leader>kr`

Tages-Kanban zurücksetzen.

Dabei gilt:

- Aufgaben aus Heute entfernen.
- Tagesbezogene Verknüpfungen zurücksetzen.
- Projekt-Kanbans unverändert lassen.
- Bereits abgeschlossene Next Actions in den Projekt-Kanbans erhalten.
- Keine offenen Projektkarten löschen.
- Keine noch offenen Next Actions im Projekt automatisch abschließen.

### Normale Status-Synchronisierung

Normale Aufgaben ohne `Next:` müssen weiterhin wie bisher bidirektional zwischen Projekt und Heute synchronisiert werden.

Die GTD-Logik darf diese Synchronisierung nicht beeinträchtigen.

---

## 9. Sonderfälle und Sicherheitsregeln

Berücksichtige mindestens folgende Fälle.

### 9.1 Mehrfaches Speichern

Eine bereits abgeschlossene Next Action darf nicht mehrfach in die DONE-Spalte geschrieben werden.

Die Verarbeitung muss idempotent sein.

### 9.2 Projektkarte wurde gelöscht

Wenn die ursprüngliche Projektkarte nicht mehr existiert:

- Keine neue Projektkarte erzeugen.
- Keine andere Projektkarte verändern.
- Keine DONE-Karte ohne eindeutige Zuordnung erzeugen.
- Verständliche Warnung ausgeben.

### 9.3 Next Action wurde nachträglich geändert

Wenn das `Next:`-Feld nach der Übernahme nach Heute manuell geändert wurde:

- Konflikt erkennen.
- Das neue `Next:`-Feld nicht überschreiben oder löschen.
- Keine falsche Projektkarte verändern.
- Eine nachvollziehbare Warnung ausgeben.

### 9.4 Gleiche Titel

Verschiedene Projektkarten können identische Next-Action-Texte besitzen.

Die Zuordnung muss trotzdem eindeutig sein.

### 9.5 Ungespeicherte Änderungen

Dateien dürfen nicht überschrieben werden, wenn dadurch ungespeicherte Änderungen in geöffneten Neovim-Buffern verloren gehen würden.

### 9.6 Teilweise fehlgeschlagene Schreibvorgänge

Beim Abschluss werden mehrere Datenbestände verändert:

- Projekt-Kanban
- Tages-Kanban
- JSON-Metadaten

Entwickle eine sichere Schreibreihenfolge und geeignete Fehlerbehandlung.

Ein fehlgeschlagener Schreibvorgang darf nicht unbemerkt zu inkonsistenten Zuständen führen.

Wiederholtes Ausführen muss einen teilweise abgeschlossenen Vorgang sicher fortsetzen oder einen Konflikt melden können.

### 9.7 Tagesreset vor Abschluss

Wenn eine noch offene Next Action beim Tagesreset aus Heute entfernt wird:

- Die Projektkarte bleibt unverändert.
- Das `Next:`-Feld bleibt erhalten.
- Es entsteht keine DONE-Karte im Projekt.
- Die Next Action kann später erneut nach Heute übernommen werden.

### 9.8 Rückverschieben aus DONE

Wenn eine bereits abgeschlossene Next Action in Heute wieder nach TODO oder WIP verschoben wird, darf die Synchronisierung nicht stillschweigend widersprüchliche Zustände erzeugen.

Für diesen Fall zunächst eine sichere, klar dokumentierte Behandlung implementieren. Bevorzugt den abgeschlossenen Projektzustand erhalten und eine Warnung ausgeben, statt eine bereits dokumentierte Erledigung automatisch rückgängig zu machen.

### 9.9 Markdown-Footer

Der Bereich ab

```markdown
%% kanban:settings
```

gehört nicht zu den Aufgaben.

Er muss bei allen Änderungen vollständig erhalten bleiben.

### 9.10 Neustart

Nach einem Neovim-Neustart müssen die gespeicherten Zuordnungen weiterhin korrekt funktionieren.

---

## 10. Implementierung

Gehe in folgender Reihenfolge vor.

### Schritt 1: Bestehende Architektur analysieren

Untersuche:

- Wie Kanban.nvim Aufgaben intern repräsentiert.
- Wie die grafischen Aufgaben-Buffer gespeichert werden.
- Wie `kanban-heute-sync.lua` aktuelle Aufgaben ermittelt.
- Wie `M.add_current_task()` funktioniert.
- Wie `M.sync_file()` aufgerufen wird.
- Wie `kanban-heute-sync.json` aufgebaut ist.
- Welche Änderungen durch meine Anpassungen an Kanban.nvim bereits vorgenommen wurden.

Verlasse dich nicht auf Annahmen über die Plugin-API. Prüfe die tatsächliche Implementierung.

### Schritt 2: Module strukturieren

Erstelle:

```text
lua/kanban-next-action.lua
```

Die neue Datei enthält die GTD-spezifische Logik.

Passe `kanban-heute-sync.lua` so an, dass sie das neue Modul verwendet.

Falls gemeinsame Hilfsfunktionen ausgelagert werden müssen, verwende eine nachvollziehbare Struktur ohne zirkuläre Abhängigkeiten.

### Schritt 3: Next Actions übernehmen

Erweitere `<leader>kh` um die Unterscheidung zwischen normalen Aufgaben und Projektkarten mit `Next:`.

### Schritt 4: Abschlüsse synchronisieren

Erweitere den bestehenden Synchronisierungsablauf um die Verarbeitung abgeschlossener Next Actions.

Keine unabhängigen konkurrierenden Autocommands verwenden.

### Schritt 5: Metadaten erweitern

Implementiere die erforderlichen zusätzlichen Metadaten.

Vorhandene Einträge müssen kompatibel bleiben.

### Schritt 6: Fehlerbehandlung ergänzen

Berücksichtige insbesondere:

- Dubletten
- Gelöschte Projektkarten
- Geänderte Next Actions
- Ungespeicherte Buffer
- Teilweise fehlgeschlagene Schreibvorgänge
- Wiederholte Synchronisierung

### Schritt 7: Tests durchführen

Erstelle nach Möglichkeit automatisierte Tests für die neue GTD-Logik und die bisherige Synchronisierung.

Teste nicht ausschließlich Hilfsfunktionen, sondern auch den tatsächlichen Ablauf mit Markdown-Dateien und JSON-Metadaten.

---

## 11. Verbindliche Abnahmekriterien

Die Implementierung ist erst abgeschlossen, wenn folgende Punkte erfüllt sind:

- [ ] Eine Projektkarte mit `Next:` wird korrekt erkannt.
- [ ] `<leader>kh` übernimmt ausschließlich die Next Action nach Heute.
- [ ] Die Next Action erscheint zunächst unter TODO.
- [ ] Die übergeordnete Projektkarte bleibt unverändert.
- [ ] Eine bereits übernommene Next Action wird nicht doppelt angelegt.
- [ ] TODO → WIP verändert ausschließlich die Next Action in Heute.
- [ ] WIP → TODO verändert ausschließlich die Next Action in Heute.
- [ ] TODO/WIP → DONE erzeugt genau eine DONE-Karte im Projekt.
- [ ] Das zugehörige `Next:`-Feld wird nach Abschluss geleert.
- [ ] Die ursprüngliche Projektkarte bleibt in ihrer bisherigen Spalte.
- [ ] Es entsteht kein zusätzlicher `Done:`-Abschnitt in der Projektkarte.
- [ ] Eine neue Next Action kann anschließend übernommen werden.
- [ ] Wiederholtes Speichern erzeugt keine doppelten DONE-Karten.
- [ ] Unterschiedliche Projektkarten mit gleichlautenden Next Actions werden korrekt unterschieden.
- [ ] Normale Aufgaben werden weiterhin bidirektional synchronisiert.
- [ ] `<leader>km` funktioniert weiterhin.
- [ ] `<leader>kr` funktioniert weiterhin.
- [ ] Bestehende JSON-Metadaten bleiben kompatibel.
- [ ] Der Markdown-Footer bleibt erhalten.
- [ ] Die Synchronisierung funktioniert auch nach einem Neovim-Neustart.
- [ ] Die GTD-Logik befindet sich überwiegend in `kanban-next-action.lua`.
- [ ] Es existiert nur eine zentrale Synchronisierungssteuerung.

---

## 12. Abschlussbericht

Dokumentiere nach der Implementierung:

1. Welche Dateien erstellt oder geändert wurden.
2. Welche Funktionen neu hinzugekommen sind.
3. Wie die Zusammenarbeit zwischen `kanban-heute-sync.lua` und `kanban-next-action.lua` funktioniert.
4. Wie Projektkarten und Next Actions eindeutig identifiziert werden.
5. Wie die Rückwärtskompatibilität der JSON-Metadaten gewährleistet wird.
6. Welche Tests durchgeführt wurden und welche Ergebnisse sie hatten.
7. Welche Sonderfälle noch Einschränkungen aufweisen.

Führe keine unnötigen Änderungen an anderen Teilen meiner Neovim-Konfiguration durch.

**Ziel ist eine modular aufgebaute, wartbare und rückwärtskompatible GTD-Erweiterung meines bestehenden Kanban-Systems – keine Neuentwicklung.**
