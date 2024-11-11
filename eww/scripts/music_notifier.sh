#!/bin/bash

playerctl --follow metadata --format "{{playerName}} {{status}} {{artist}} - {{title}}" | while read -r line; do
    player=$(echo "$line" | awk '{print $1}')
    status=$(echo "$line" | awk '{print $2}')
    song_info=$(echo "$line" | cut -d' ' -f3-)
    
    # Verifica che l'informazione della traccia non sia vuota
    if [[ -n "$song_info" ]]; then
        "/home/vncnz/.config/eww/scripts/notif.sh" "show_music"
        # notify-send -h int:transient:1 -h string:synchronous:player "($player) $status" "$song_info"
    fi
done
