#!/bin/bash

# @requires: pactl

SINK=$(pactl list short sinks | sed -e 's,^\([0-9][0-9]*\)[^0-9].*,\1,' | head -n 1)

percentage () {
  local val=$(echo $1 | tr '%' ' ' | awk '{print $1}')
  local icon1=$2
  local icon2=$3
  local icon3=$4
  local icon4=$5
  if [ "$val" -le 15 ]; then
    echo $icon1
  elif [ "$val" -le 30 ]; then
    echo $icon2
  elif [ "$val" -le 60 ]; then
    echo $icon3
  else
    echo $icon4
  fi
}

is_muted () {
  # pacmd list-sinks | awk '/muted/ { print $2 }'
  wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -c "MUTED"
}

get_percentage () {
  local muted=$(is_muted)
  if [[ $muted == '1' ]]; then
    echo 0%
  else
    per=$(amixer sget Master | awk -F"[][]" '/Left:/ { print $2 }')
    echo "${per}%"
  fi
}

get_icon () {
  local headphones=$(pactl list sinks | grep "Active Port" | grep "headphones" | wc -l)
  if [[ $headphones == "1" ]]; then
    echo ""
  else
    local vol=$(get_percentage)
    if [[ $vol == "0%" ]]; then
      echo ""
    else
      echo $(percentage "$vol" "" "" "" "")
    fi
  fi
}

get_class () {
  local vol=$(get_percentage)
  if [[ $vol == "0%" ]]; then
    echo "red"
  else
    echo $(percentage "$vol" "red" "magenta" "yellow" "blue")
  fi
}

get_vol () {
  local percent=$(get_percentage)
  echo $percent | tr -d '%'
}

get_json () {
  PERCENTAGE=$(get_vol)
  ICON=$(get_icon)
  CLAZZ=$(get_class)
  echo '{"value": '$PERCENTAGE', "icon": "'"$ICON"'", "clazz": "'"$CLAZZ"'"}'
}

if [[ $1 == "json" ]]; then
  get_json
fi

if [[ $1 == "icon" ]]; then
  get_icon
fi

if [[ $1 == "class" ]]; then
  get_class
fi

if [[ $1 == "percentage" ]]; then
  get_percentage
fi

if [[ $1 == "vol" ]]; then
  get_vol
fi

if [[ $1 == "muted" ]]; then
  is_muted
fi

if [[ $1 == "toggle-muted" ]]; then
  pactl set-sink-mute $SINK toggle
  $(~/.config/eww/scripts/dunstvolume.sh)
fi

if [[ $1 == "up" ]]; then
  pactl set-sink-volume @DEFAULT_SINK@ +5%
  data=$(get_json)
  $(/usr/bin/eww update volume="$data")
  # send_notif
fi
if [[ $1 == "down" ]]; then
  pactl set-sink-volume @DEFAULT_SINK@ -5%
  data=$(get_json)
  $(/usr/bin/eww update volume="$data")
  # send_notif
fi

if [[ $1 == "set________" ]]; then
  val=$(echo $2 | tr '.' ' ' | awk '{print $1}')
  if test $val -gt 100; then
    val=100
  fi
  pactl set-sink-volume $SINK $val%
  # wpctl set-volume 
  # $(~/.config/eww/scripts/dunstvolume.sh)
  muted=$(is_muted)
  volume=$(get_vol)
  volume100=$(awk '{ print $1 / 100 }' <<< $volume)
  
  msgId="3378423"
  if [[ $volume == 0 || "$muted" == "1" ]]; then
    dunstify -h int:transient:1 -a "changeVolumee" -u low -i audio-volume-muted -r "$msgId" "Volume muted"
  else
    dunstify -h int:transient:1 -a "changeVolumee" -u low -i audio-volume-high -r "$msgId" \
    -h int:value:"$volume100" "Volume: ${volume}%"
  fi
fi