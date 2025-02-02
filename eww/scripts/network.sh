#!/bin/bash

# cat /sys/class/net/enp0s3/

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
    if [ "$wired" == "1" ]; then
        echo "󰈀"
    elif [ "$wifi" == "1" ]; then
        echo $(percentage "$signal" "󰢿" "󰢼" "󰢽" "󰢾")
    else
        echo "󰞃"
    fi
}

get_class () {
    if [ "$wired" == "1" ]; then
        echo ""
    elif [ "$wifi" == "1" ]; then
        echo $(percentage "$signal" "err-color" "warn-color" "" "")
    else
        echo "err-color"
    fi
}

signal=$(nmcli -f in-use,signal dev wifi | rg "\*" | awk '{ print $2 }')
essid=$(nmcli -t -f NAME connection show --active | head -n1 | sed 's/\"/\\"/g')
wired=$(nmcli device status | grep -w connected | grep -c ethernet)
wifi=$(nmcli device status | grep -w connected | grep -c wifi)
if [ "$wired" -eq "1" ]; then
  signal="0"
fi
icon=$(get_icon)
class=$(get_class)
echo '{"essid": "'"$essid"'", "signal": "'"$signal"'", "icon": "'"$icon"'", "wired": "'"$wired"'", "wifi": "'"$wifi"'", "class": "'"$class"'"}'

ip monitor link | while read -r line; do
    signal=$(nmcli -f in-use,signal dev wifi | rg "\*" | awk '{ print $2 }')
    essid=$(nmcli -t -f NAME connection show --active | head -n1 | sed 's/\"/\\"/g')
    wired=$(nmcli device status | grep -w connected | grep -c Wired)
    wifi=$(nmcli device status | grep -w connected | grep -c wifi)
    if [ "$wired" == "1" ]; then
      signal="0"
    fi
    icon=$(get_icon)
    class=$(get_class)
    echo '{"essid": "'"$essid"'", "signal": "'"$signal"'", "icon": "'"$icon"'", "wired": "'"$wired"'", "wifi": "'"$wifi"'", "class": "'"$class"'"}'
done