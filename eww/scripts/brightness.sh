#!/bin/bash

# @requires: brightnessctl

percentage () {
  local val=$(echo $1 | tr '%' ' ' | awk '{print $1}')
  if [ "$val" -le 1 ]; then
    echo $2
  elif [ "$val" -le 8 ]; then
    echo $3
  elif [ "$val" -le 16 ]; then
    echo $4
  elif [ "$val" -le 24 ]; then
    echo $5
  elif [ "$val" -le 32 ]; then
    echo $6
  elif [ "$val" -le 40 ]; then
    echo $7
  elif [ "$val" -le 48 ]; then
    echo $8
  elif [ "$val" -le 56 ]; then
    echo $9
  elif [ "$val" -le 64 ]; then
    echo ${10}
  elif [ "$val" -le 72 ]; then
    echo ${11}
  elif [ "$val" -le 80 ]; then
    echo ${12}
  elif [ "$val" -le 88 ]; then
    echo ${13}
  elif [ "$val" -le 96 ]; then
    echo ${14}
  else
    echo ${15}
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
  echo $(percentage "$br" "" "" "" "" "" "" "" "" "" "" "" "" "" "")
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