#!/bin/bash

# ws=$(niri msg -j workspaces | jq -c -r '.[]')
# for item in $ws; do
#     echo $item
# done


# Usa il tuo comando che restituisce il JSON delle applicazioni aperte
# json_output=$(niri msg -j windows)

# Usa jq per estrarre i dati e raggruppare le applicazioni per workspace
# applications=$(echo "$json_output" | jq -r '
#     group_by(.workspace_id) | 
#     map("Workspace \(.[]?.workspace_id):\n" + (unique | map("  - \(.title)") | join("\n"))) | 
#     join("\n\n")
# ')

applications=$("/home/vncnz/.config/eww/scripts/niri_spaces.py")

# Mostra il risultato con fuzzel
c=$(echo "$applications" | fuzzel --dmenu --prompt="" --width 60)
numero=$(echo $c | grep -o '^[0-9]*' | head -n 1)
echo $numero

if [[ -n "$numero" ]]; then
    $(niri msg action focus-window --id $numero)
fi