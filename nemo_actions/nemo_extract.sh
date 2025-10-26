#!/usr/bin/env sh

set -u

if [ "$#" -eq 0 ]; then
  echo "Nessun file passato."
  exit 1
fi

for f in "$@"; do
  [ -f "$f" ] || { echo "Saltato (non file): $f"; continue; }
  dir=$(dirname "$f")
  base=$(basename "$f")
  name="${base%.*}"   # togli l'ultima estensione
  target="$dir/$name"

  echo "=== Estrazione: $base -> $target ==="
  mkdir -p "$target"

  case "$f" in
    *.zip)    unzip "$f" -d "$target" ;;
    *.tar.gz|*.tgz) tar -xvzf "$f" -C "$target" ;;
    *.tar.bz2|*.tbz2) tar -xvjf "$f" -C "$target" ;;
    *.tar.xz|*.txz) tar -xvJf "$f" -C "$target" ;;
    *.tar)    tar -xvf "$f" -C "$target" ;;
    *.rar)    unrar x -o+ "$f" "$target" ;;
    *)        echo "Formato non supportato: $f" ;;
  esac

  echo
done

echo "Tutte le estrazioni terminate."
echo "Premi INVIO per chiudere..."
read -r _
