#!/bin/bash

# Root-Verzeichnis der Ordnerstruktur (Mindmap)
ROOT_DIR="/home/jay/_"

# Funktion zum Erstellen von Link-Skripten
create_link() {
  local target_path="$1"
  local current_path="$(pwd)"

  # Absolute Pfade erhalten
  target_path="$(realpath "$target_path")"
  current_path="$(realpath "$current_path")"

  # Namen der Verzeichnisse extrahieren
  local target_name="$(basename "$target_path")"
  local current_name="$(basename "$current_path")"

  # Skript im aktuellen Verzeichnis erstellen
  echo -e "#!/bin/bash\ncd \"$target_path\"" > "$target_name"
  chmod +x "$target_name"

  # Skript im Zielverzeichnis erstellen
  echo -e "#!/bin/bash\ncd \"$current_path\"" > "$target_path/$current_name"
  chmod +x "$target_path/$current_name"

  echo "Link-Skripte wurden erstellt:"
  echo "- '$target_name' im aktuellen Verzeichnis (führt zu $target_path)"
  echo "- '$current_name' im Zielverzeichnis (führt zu $current_path)"
}

# Funktion zum Wechseln in ein Verzeichnis basierend auf einem Teilnamen
change_dir() {
  local partial_name="$1"
  echo $1
  source "./$1"
  #TODO "$ l bar" gibt immer alle möglichen pfade aus...
  # Alle passenden Verzeichnisse unter ROOT_DIR finden
  #IFS=$'\n' read -rd '' -a matches <<< "$(find "$ROOT_DIR" -type d -name "*$partial_name*" 2>/dev/null)"
  #matches=($(find "$ROOT_DIR" -type d -name "*$partial_name*" 2>/dev/null))
  IFS=$'\n' matches=($(find "$ROOT_DIR" -type d -name "*$partial_name*" 2>/dev/null))

  if [[ ${#matches[@]} -eq 0 ]]; then
    echo "Kein Verzeichnis gefunden für '$partial_name'"
    return 1
  elif [[ ${#matches[@]} -eq 1 ]]; then
    cd "${matches[0]}"
  else
    # Gemeinsamen Pfadanteil finden
    local prefix="$(printf "%s\n" "${matches[@]}" | sed 's|\(.*\)/.*|\1|' | sed -e 'N;s|^\(.*\).*\n\1.*$|\1|')"
    echo "Mehrere Verzeichnisse gefunden:"
    printf "%s\n" "${matches[@]#$ROOT_DIR/}"
    echo "Bitte spezifischer sein."
    return 1
  fi
}

# Hauptprogramm
if [[ "$1" == "-c" ]]; then
  if [[ -n "$2" ]]; then
    create_link "$2"
  else
    echo "Verwendung: $0 -c <pfad>"
    exit 1
  fi
elif [[ "$1" == "-p" ]]; then
  if [[ -n "$2" ]]; then
    # Vollständige Pfade der alternativen Verzeichnisse anzeigen
    partial_name="$2"
    find "$ROOT_DIR" -type d -name "*$partial_name*" -print 2>/dev/null | sed "s|$ROOT_DIR/||"
  else
    echo "Verwendung: $0 -p <teilname>"
    exit 1
  fi
else
  if [[ -n "$1" ]]; then
    change_dir "$1"
  else
    echo "Verwendung: $0 [-c <pfad>] | [-p <teilname>] | <teilname>"
    exit 1
  fi
fi

