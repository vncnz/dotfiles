#!/usr/bin/env bash

output=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
muted=$(echo $output | grep -c "MUTED")
volume=$(echo $output | grep -Eo '[+-]?[0-9]+([.][0-9]+)?' )

# echo $output
# echo $muted
# echo $volume

if [ $muted -eq 1 ]; then
    echo -n 'Muted'
else
    echo $(echo $volume | awk '{print ($0 * 100.0);}')
fi
