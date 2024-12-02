#!/bin/bash

LINK_DIR=".links" # Verstecktes Verzeichnis für die Links

# Hilfsfunktion: Sicherstellen, dass das Link-Verzeichnis existiert
ensure_link_dir() {
  mkdir -p "$PWD/$LINK_DIR"
}

# Funktion: Link erstellen
create_link() {
  local target_dir="$1"
  local current_dir="$PWD"

  # Verzeichnisse validieren
  if [[ ! -d "$target_dir" ]]; then
    echo "Fehler: Zielverzeichnis '$target_dir' existiert nicht."
    exit 1
  fi

  ensure_link_dir

  # Link in Zielverzeichnis erstellen
  local target_link="$target_dir/$LINK_DIR/$(basename "$current_dir")"
  echo "cd \"$current_dir\"" > "$target_link"
  chmod +x "$target_link"

  # Link im aktuellen Verzeichnis erstellen
  local current_link="$PWD/$LINK_DIR/$(basename "$target_dir")"
  echo "cd \"$target_dir\"" > "$current_link"
  chmod +x "$current_link"

  echo "Links wurden erfolgreich erstellt:"
  echo "- $current_link -> $target_dir"
  echo "- $target_link -> $current_dir"
}

# Funktion: Wechseln in ein Zielverzeichnis basierend auf Autovervollständigung
navigate() {
  local query="$1"
  ensure_link_dir

  # Suche nach möglichen Links
  local matches=($(find "$PWD/$LINK_DIR" -type f -name "*$query*" -exec basename {} \;))
  
  if [[ ${#matches[@]} -eq 1 ]]; then
    local target="$(cat "$PWD/$LINK_DIR/${matches[0]}" | awk '{print $2}')"
    cd "$target" || exit
  elif [[ ${#matches[@]} -gt 1 ]]; then
    echo "Mehrere Übereinstimmungen gefunden:"
    for match in "${matches[@]}"; do
      local target="$(cat "$PWD/$LINK_DIR/$match" | awk '{print $2}')"
      echo "- $match -> $target"
    done
  else
    echo "Kein Ziel gefunden für '$query'."
  fi
}

# Hauptlogik
if [[ "$1" == "-c" ]]; then
  # Link erstellen
  if [[ -n "$2" ]]; then
    create_link "$2"
  else
    echo "Verwendung: $0 -c <zielverzeichnis>"
    exit 1
  fi
elif [[ "$1" == "-p" ]]; then
  # Pfad eines Links anzeigen
  if [[ -n "$2" ]]; then
    ensure_link_dir
    local matches=($(find "$PWD/$LINK_DIR" -type f -name "*$2*" -exec basename {} \;))
    if [[ ${#matches[@]} -eq 1 ]]; then
      cat "$PWD/$LINK_DIR/${matches[0]}" | awk '{print $2}'
    else
      echo "Keine oder mehrere Übereinstimmungen gefunden."
    fi
  else
    echo "Verwendung: $0 -p <suchbegriff>"
    exit 1
  fi
else
  # Navigation ausführen
  if [[ -n "$1" ]]; then
    navigate "$1"
  else
    echo "Verwendung: $0 <suchbegriff> | -c <zielverzeichnis> | -p <suchbegriff>"
    exit 1
  fi
fi

