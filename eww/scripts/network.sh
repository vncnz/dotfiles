#!/bin/bash

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

get_icon () {
    # local br=$(get_percent)
    if [ "$essid" == "lo" ]; then
        echo ""
    elif [ "$wired" == "1" ]; then
        echo ""
    else
        echo $(percentage "$signal" "" "" "" "")
    fi
}

signal=$(nmcli -f in-use,signal dev wifi | rg "\*" | awk '{ print $2 }')
essid=$(nmcli -t -f NAME connection show --active | head -n1 | sed 's/\"/\\"/g')
wired=$(nmcli device status | grep connected | grep -c Wired)
if [ "$wired" == "1" ]; then
  signal="100"
fi
icon=$(get_icon)
echo '{"essid": "'"$essid"'", "signal": "'"$signal"'", "icon": "'"$icon"'", "wired": "'"$wired"'"}'

ip monitor link | while read -r line; do
    signal=$(nmcli -f in-use,signal dev wifi | rg "\*" | awk '{ print $2 }')
    essid=$(nmcli -t -f NAME connection show --active | head -n1 | sed 's/\"/\\"/g')
    wired=$(nmcli device status | grep connected | grep -c Wired)
    if [ "$wired" == "1" ]; then
      signal="100"
    fi
    icon=$(get_icon)
    echo '{"essid": "'"$essid"'", "signal": "'"$signal"'", "icon": "'"$icon"'", "wired": "'"$wired"'"}'
done