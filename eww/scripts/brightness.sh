#!/bin/bash

# @requires: brightnessctl

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

get_brightness () {
  (( br = $(brightnessctl get) * 100 / $(brightnessctl max) ))
  printf "%.0f\n" $br
}

get_percent () {
  echo $(get_brightness)%
}

get_icon () {
  local br=$(get_percent)
  echo $(percentage "$br" "" "󰃞" "󰃟" "")
}

send_notif () {
  msgId="3378455"

  brightnessctl "$@" > /dev/null

  brightnow="$(brightnessctl g)"
  brightmax="$(brightnessctl m)"

  brightpercent=$(awk "BEGIN {print int(${brightnow}/${brightmax}*100)}")

  notify-send -h int:transient:1 -h string:x-dunst-stack-tag:brightness -h int:value:$brightpercent -h string:synchronous:brightness "Brightness: ${brightpercent}%"
  # dunstify -a "Brightness" -u low -r "$msgId" -h int:transient:1 -h string:synchronous:brightness -h int:value:"$brightpercent" "Brightness: ${brightpercent}%"
}

get_json () {
  PERCENTAGE=$(get_brightness)
  ICON=$(get_icon)
  CLAZZ=""
  echo '{"percentage": "'"$PERCENTAGE"'", "icon": "'"$ICON"'", "clazz": "'"$CLAZZ"'"}'
}

if [[ $1 == "json" ]]; then
  get_json
fi

if [[ $1 == "br" ]]; then
  get_brightness
fi

if [[ $1 == "percent" ]]; then
  get_percent
fi

if [[ $1 == "icon" ]]; then
  get_icon
fi

if [[ $1 == "set" ]]; then
  brightnessctl set $2
  data=$(get_json)
  $(/usr/bin/eww update brightness="$data")
  # send_notif
fi

if [[ $1 == "delta" ]]; then
  per=$( get_brightness )
  # half=$(( $2 / 2 ))
  # rem=$(( ($per + $half) % $2 ))
  # echo $2
  # echo $rem
  # echo $half
  val=$(( ((per+1) / $2) * $2 + $2))
  #if [[ "$rem" -ge "$half" ]]; then
  #  if [[ "$half" -ge "0" ]]; then
  #    echo "qui"
  #    val=$(( $val + $2 ))
  #  fi
  #fi
  echo $val
  brightnessctl set $val"%"
  data=$(get_json)
  echo $data
  $(/usr/bin/eww update brightness="$data")
  # send_notif
fi