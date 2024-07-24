#!/bin/bash
# dunstMixer

msgId="3378423"
info="$(wpctl get-volume @DEFAULT_SINK@)"
volume=$(echo $info | awk '{print $2}')
mute="$(echo $info | grep 'MUTED' | wc -l)"
volume100=$(awk '{ print $1 * 100 }' <<< $volume)

if [[ $volume == 0 || "$mute" == "1" ]]; then
	dunstify -a "changeVolume" -u low -i audio-volume-muted -r "$msgId" "Volume muted" 
else
	dunstify -a "changeVolume" -u low -i audio-volume-high -r "$msgId" \
	-h int:value:"$volume" "Volume: ${volume100}%"
fi

# canberra-gtk-play -i audio-volume-change -d "changeVolume"