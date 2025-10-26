#!/usr/bin/env sh

if [ -z "$1" ]; then
echo "Uso: compress <file_o_cartella>"
return 1
fi

target="$1"
base=$(basename "$target")
output="${base}.tar.zst"

# Controlla se Alacritty o Kitty sono installati
if command -v alacritty >/dev/null 2>&1; then
term="alacritty"
elif command -v kitty >/dev/null 2>&1; then
term="kitty"
else
echo "Errore: né Alacritty né Kitty trovati nel PATH"
return 1
fi

# Crea il comando di compressione
if [ -d "$target" ]; then
cmd="tar -I 'zstd -19 -T0' -cf \"$output\" \"$target\""
elif [ -f "$target" ]; then
cmd="tar -I 'zstd -19 -T0' -cf \"$output\" \"$target\""
else
echo "Errore: '$target' non è un file o una directory valida"
return 1
fi

# Esegui in terminale
$term -e bash -c "$cmd; echo; echo 'Compressione completata!'; read -p 'Premi invio per chiudere...'"