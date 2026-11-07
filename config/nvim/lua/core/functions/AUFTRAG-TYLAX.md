# Arbeitsauftrag für Codex: Tylax – LaTeX-zu-Typst-Konvertierung verbessern

## 1. Ziel

Die bestehende Tylax-Konvertierungsfunktion soll verbessert werden, sodass LaTeX-Dokumente möglichst vollständig, korrekt und mit einer dem Original vergleichbaren Formatierung nach Typst konvertiert werden.

Als Testfall dient das Dokument **G'MICS Prokinetika**.

Es liegen zwei PDF-Versionen vor:

- LaTeX-Original vom 18.02.2026 (7 Seiten)
- Tylax-/Typst-Ausgabe vom 07.11.2026 (8 Seiten)

Die medizinischen Inhalte wurden weitgehend übernommen. Allerdings enthält die Typst-Version mehrere Konvertierungs- und Layoutfehler.

**Ziel ist nicht die manuelle Korrektur des Testdokuments, sondern die dauerhafte Verbesserung der allgemeinen Tylax-Konvertierungsfunktion.**

## 2. Vorgehensweise

Vor Änderungen:

1. Die bestehende Tylax-Implementierung vollständig untersuchen.
2. Den Ablauf der Konvertierung nachvollziehen, einschließlich eventuell verwendeter Pandoc-, Lua-, Python- oder Shell-Komponenten.
3. Die Ursachen der unten beschriebenen Fehler identifizieren.
4. Vorhandene Funktionen und Mechanismen möglichst weiterverwenden.
5. Änderungen gezielt und nachvollziehbar durchführen.

Keine zweite, parallele Konvertierungslogik entwickeln.

Die bestehende Architektur soll erhalten bleiben, sofern keine zwingenden technischen Gründe dagegen sprechen.

## 3. Bekannte Fehler

### 3.1 Präambel und Dokumentstruktur

In der Typst-Ausgabe erscheinen technische LaTeX-Fragmente als sichtbarer Text, beispielsweise:

```text
fancy toc
linkcolor = red!70!black, citecolor = black, urlcolor = blue
```

Außerdem erscheint der Dokumenttitel doppelt.

**Anforderungen:**

- Präambel und Dokumentkörper zuverlässig trennen.
- Nicht unterstützte Präambelbefehle nicht als Fließtext übernehmen.
- Titel und Metadaten nur einmal ausgeben.
- Gewünschte Dokumenteigenschaften möglichst in entsprechende Typst-Einstellungen übertragen.
- Nicht konvertierbare Einstellungen gegebenenfalls mit einer Warnung protokollieren.

### 3.2 Mathematische Symbole

Vergleichsoperatoren werden teilweise doppelt ausgegeben:

```text
≥≥ 800 ml
≤≤ 15 ml/min
```

**Anforderungen:**

- Ursache der doppelten Konvertierung untersuchen.
- Mathematische Ausdrücke korrekt nach Typst übertragen.
- Bereits konvertierte Symbole nicht erneut verändern.
- Mathematische und normale Textbereiche unterscheiden.

### 3.3 Listen

In der Ausgabe entstehen doppelte Listenmarker:

```text
- - Erythromycin 50 mg i.v. 3x/Tag
```

**Anforderungen:**

- `itemize` und `enumerate` korrekt konvertieren.
- Verschachtelte Listen erhalten.
- Einrückung und Hierarchie übernehmen.
- Keine doppelten Listenmarker erzeugen.
- Mehrzeilige Listeneinträge korrekt behandeln.

### 3.4 Querverweise

Es entstehen redundante Referenzen:

```text
Abb. Abbildung 1
Abschnitt Abschnitt 5.2
```

**Anforderungen:**

- `\label`, `\ref` und gegebenenfalls weitere Referenzbefehle korrekt behandeln.
- Bereits vorhandene sprachliche Präfixe berücksichtigen.
- Keine doppelten Bezeichnungen erzeugen.
- Nummerierung und Verlinkung erhalten.
- Querverweise auch bei verschobenen Abbildungen korrekt auflösen.

### 3.5 Literaturverweise

Insbesondere in Abbildungsbeschriftungen erscheinen nicht konvertierte Zitierbefehle:

```text
{{zaloga2005MythGastricResidual}, S. 449}
```

**Anforderungen:**

- Literaturverweise im Fließtext, in Fußnoten und in Abbildungsbeschriftungen korrekt konvertieren.
- Vorhandene Zotero-/Better-BibTeX-Schlüssel erhalten.
- Seitenangaben übernehmen.
- Bestehende Bibliografiedateien weiterverwenden.
- Die Konvertierung unterschiedlicher Zitierbefehle berücksichtigen, insbesondere `\cite` und `\footcite`.
- Sicherstellen, dass die erzeugten Typst-Zitate mit der Bibliografie kompatibel sind.

### 3.6 Abbildungen

Die Abbildungen werden zwar übernommen, ihre Größe und Positionierung sind teilweise fehlerhaft.

Beobachtete Probleme:

- Abbildungen werden teilweise sehr klein dargestellt.
- Abbildungsbeschriftungen enthalten rohe Literaturverweise.
- Beschriftungen sind ungünstig umbrochen.
- Auf Seite 4 überlagert eine Abbildungsbeschriftung die Fußnoten.
- Abbildungsgrößen sind zwischen den Seiten uneinheitlich.

**Anforderungen:**

- LaTeX-Abbildungen als zusammengehörige Strukturen verarbeiten.
- `figure`, `\includegraphics`, `\caption` und `\label` gemeinsam berücksichtigen.
- Relative Bildgrößen möglichst korrekt nach Typst übertragen.
- Zwischen ein- und zweispaltigen Abbildungen unterscheiden.
- Bild und Beschriftung zusammenhalten.
- Überlagerungen mit Fußnoten verhindern.
- Die vorhandene Spaltenstruktur berücksichtigen.

Keine pauschale Bildgröße festlegen, wenn die ursprüngliche LaTeX-Datei eine andere Größe vorgibt.

### 3.7 Fußnoten

Die Fußnoten sind teilweise deutlich länger als im Original und beanspruchen entsprechend mehr Platz.

**Anforderungen:**

- Zitierstil und Fußnotenformatierung untersuchen.
- Möglichst eine kompakte, dem Original entsprechende Darstellung ermöglichen.
- Vorhandene Seitenangaben erhalten.
- Keine Überlagerungen mit Abbildungen oder Fließtext zulassen.
- Die korrekte Reihenfolge und Zuordnung der Fußnoten sicherstellen.

### 3.8 Inhalts- und Abbildungsverzeichnis

Beobachtete Fehler:

```text
Kernpunkte ()
```

Außerdem enthalten Einträge des Abbildungsverzeichnisses rohe Literaturverweise.

**Anforderungen:**

- Überschriften korrekt in das Inhaltsverzeichnis übernehmen.
- Leere Klammern vermeiden.
- Abbildungsbeschriftungen im Abbildungsverzeichnis korrekt darstellen.
- Literaturverweise in Verzeichniseinträgen sinnvoll behandeln.
- Leere Verzeichnisse nach Möglichkeit nicht automatisch erzeugen, sofern sie im Original nicht gewünscht sind.

## 4. Technische Anforderungen

Die Konvertierung soll möglichst strukturbasiert erfolgen.

Globale reguläre Ausdrücke dürfen weiterhin für einfache, eindeutig abgrenzbare Ersetzungen verwendet werden. Verschachtelte LaTeX-Strukturen sollten jedoch nicht ausschließlich mit globalen Textersetzungen verarbeitet werden.

Insbesondere folgende Elemente müssen zuverlässig erkannt werden:

- Dokumentstruktur und Präambel
- Überschriften
- Listen
- Mathematische Ausdrücke
- Abbildungen und Beschriftungen
- Fußnoten
- Literaturverweise
- Labels und Querverweise

**Wichtig:** Zunächst prüfen, welche dieser Aufgaben bereits durch Pandoc oder andere bestehende Komponenten abgedeckt werden. Keine eigene Parserlogik entwickeln, wenn eine vorhandene Komponente die Struktur bereits zuverlässig bereitstellt.

## 5. Testverfahren

Das Dokument G'MICS Prokinetika dient als Regressionstest.

Nach den Änderungen:

1. LaTeX-Original erneut mit Tylax konvertieren.
2. Erzeugte Typst-Datei kompilieren.
3. Warnungen und Fehlermeldungen auswerten.
4. PDF-Ausgabe visuell mit dem LaTeX-Original vergleichen.
5. Alle acht bekannten Fehlergruppen überprüfen.
6. Sicherstellen, dass keine neuen Fehler entstehen.

Zusätzlich sollen automatisierte Tests für typische Konvertierungsfälle erstellt oder bestehende Tests erweitert werden.

Mindestens folgende Fälle prüfen:

| Testfall | Erwartetes Ergebnis |
|---|---|
| `\geq 800` | Ein einzelnes ≥ |
| `\leq 15` | Ein einzelnes ≤ |
| Verschachtelte `itemize`-Listen | Korrekte Listenhierarchie |
| `Abb. \ref{fig:test}` | Keine doppelte Abbildungsbezeichnung |
| `\caption` mit Literaturverweis | Korrekt aufgelöster Literaturverweis |
| `\footcite` mit Seitenangabe | Korrektes Zitat mit Seitenangabe |
| `\includegraphics[width=...]` | Sinnvolle Übernahme der Bildbreite |
| Abbildung in zweispaltigem Dokument | Keine Überlagerung mit Fußnoten |
| LaTeX-Präambel | Keine technischen Textfragmente im Dokument |
| Inhaltsverzeichnis | Keine leeren Klammern oder rohen Befehle |

## 6. Grenzen

- Medizinische Inhalte nicht eigenständig verändern.
- Keine Literaturangaben erfinden oder ersetzen.
- Inhaltliche Fehler im Original nicht automatisch korrigieren.
- Keine Änderungen an den LaTeX-Quelldateien vornehmen, sofern dies nicht ausdrücklich erforderlich und abgestimmt ist.
- Bestehende funktionierende Konvertierungen nicht verschlechtern.
- Keine unnötigen zusätzlichen Abhängigkeiten einführen.
- Keine rein dokumentbezogenen Sonderregeln einbauen.

Die Verbesserungen sollen allgemein für andere LaTeX-Dokumente funktionieren.

## 7. Erwartetes Ergebnis

Am Ende sollen vorliegen:

1. Eine verbesserte Tylax-Konvertierungsfunktion.
2. Erfolgreich durchlaufene Regressionstests.
3. Eine neu erzeugte Typst-Datei und PDF-Ausgabe des Testdokuments.
4. Eine kurze Übersicht der vorgenommenen Änderungen.
5. Eine Aufstellung weiterhin bestehender Einschränkungen.

Die abschließende Rückmeldung soll zwischen folgenden Kategorien unterscheiden:

- **Behoben:** Fehlerursache korrigiert und erfolgreich getestet.
- **Teilweise behoben:** Verbesserung umgesetzt, aber Einschränkungen bestehen.
- **Offen:** Fehler noch nicht behoben, mit Begründung.

## 8. Prioritäten

**Priorität 1 – Funktionale Korrektheit**

- Keine fehlenden oder beschädigten Inhalte
- Korrekte mathematische Symbole
- Korrekte Listen
- Korrekte Zitate und Querverweise
- Keine Textüberlagerungen

**Priorität 2 – Dokumentstruktur**

- Korrekte Präambelverarbeitung
- Korrekte Titel und Verzeichnisse
- Korrekte Abbildungsbeschriftungen
- Zuverlässige Fußnoten

**Priorität 3 – Layoutqualität**

- Bildgrößen
- Spaltenaufteilung
- Seitenumbrüche
- Abstände
- Annäherung an das ursprüngliche LaTeX-Layout

## 9. Grundsatz

**Die allgemeine Qualität der LaTeX-zu-Typst-Konvertierung ist wichtiger als die pixelgenaue Reproduktion des Testdokuments.**

Das G'MICS-Prokinetika-Dokument dient dazu, systematische Fehler aufzudecken und zu beheben.

Bitte zunächst die bestehende Implementierung und die Fehlerursachen analysieren, anschließend die erforderlichen Änderungen durchführen und anhand des Testdokuments überprüfen.
