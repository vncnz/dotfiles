#!/bin/bash

# Cartella di input (opzionale)
BASE_DIR="${1:-$(pwd)}"
BASE_DIR="$(realpath "$BASE_DIR")"

# Verifica che la directory esista
if [[ ! -d "$BASE_DIR" ]]; then
    echo "❌ Errore: la directory '$BASE_DIR' non esiste."
    exit 1
fi

echo "📁 Cartella di partenza: $BASE_DIR"

# Usa mapfile per caricare i risultati di find in un array
mapfile -d '' flac_files < <(find "$BASE_DIR" -type f -iname "*.flac" -print0)

# Cicla su ogni file trovato
for flac_file in "${flac_files[@]}"; do
    # Percorso relativo
    rel_path="${flac_file#$BASE_DIR/}"

    # Percorso di output
    mp3_path="${rel_path%.flac}.mp3"
    mp3_full_path="$BASE_DIR/$mp3_path"

    # Crea la cartella di destinazione
    mkdir -p "$(dirname "$mp3_full_path")"

    # Skippa se esiste già
    if [[ -f "$mp3_full_path" ]]; then
        echo "⏩ Skipping (already done): $mp3_path"
        continue
    fi

    echo "🎧 Converting: $rel_path → $mp3_path"
    ffmpeg -i "$flac_file" -ab 320k -map_metadata 0 -id3v2_version 3 "$mp3_full_path"
done
