# MacParakeet Vocabulary

Eigene Vokabularlisten für MacParakeet.

## Dateien

- `medical-vocabulary.txt` – medizinische Fachbegriffe
- `allgemein-vocabulary.txt` – allgemeine Begriffe
- `englisch-vocabulary.txt` – englische Begriffe
- `sync-parakeet-vocabulary` – erzeugt das MacParakeet-Vocabulary und synchronisiert es mit MacParakeet
- `vocabulary.json` – generierte Datei, wird nicht versioniert

## Einrichtung

Das Sync-Skript ausführbar machen:

```bash
chmod +x ~/dotfiles/config/macparakeet/sync-parakeet-vocabulary
```

Damit `sync-parakeet-vocabulary` von überall aufgerufen werden kann, einen Symlink nach `~/.local/bin` erstellen:

```bash
ln -s ~/dotfiles/config/macparakeet/sync-parakeet-vocabulary \
  ~/.local/bin/sync-parakeet-vocabulary
```

Voraussetzung ist, dass `~/.local/bin` im `PATH` enthalten ist.

## Verwendung

Die Begriffe werden in den drei Vokabularlisten gepflegt. Leerzeilen sowie Zeilen, die mit `#` beginnen, werden beim Synchronisieren ignoriert.

Beispiel:

```text
# Beatmung
PEEP
PaCO2
etCO2

# Medikamente
Argipressin
Dexmedetomidin
```

Nach Änderungen an den Vokabularlisten MacParakeet synchronisieren:

```bash
sync-parakeet-vocabulary
```

Die Datei `vocabulary.json` wird dabei automatisch erzeugt und dient nur als Zwischenprodukt. Die drei Vokabularlisten sind die maßgebliche Quelle und sollten versioniert werden; `vocabulary.json` sollte nicht versioniert werden.
