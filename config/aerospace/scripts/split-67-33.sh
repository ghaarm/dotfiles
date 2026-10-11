#!/bin/bash
set -e

# Voraussetzung: zwei nebeneinanderliegende Fenster

# Zunächst auf 50:50 zurücksetzen
aerospace balance-sizes

# Unabhängig vom aktuellen Fokus zuerst nach ganz links
aerospace focus left 2>/dev/null || true

# Anschließend das rechte Fenster fokussieren
aerospace focus right

# Bildschirmbreite ermitteln
WIDTH=$(osascript -l JavaScript -e '
ObjC.import("AppKit");
$.NSScreen.mainScreen.frame.size.width;
')

# Rechtes Fenster um 1/6 der Gesamtbreite verkleinern
DELTA=$(( WIDTH / 6 ))

aerospace resize width -"$DELTA"
