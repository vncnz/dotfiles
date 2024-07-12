#!/usr/bin/env bash

output=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
muted=$(echo $output | grep -c "MUTED")
volume=$(echo $output | grep -Eo '[+-]?[0-9]+([.][0-9]+)?' )

# echo $output
# echo $muted
# echo $volume

if [ $muted -eq 1 ]; then
    echo -n ''
elif (( $(echo $volume | awk '{if ($1 < 0.4) print 1;}') )); then
    echo -n ""
elif (( $(echo $volume | awk '{if ($1 < 0.7) print 1;}') )); then
    echo -n ""
else
    echo -n ""
fi
