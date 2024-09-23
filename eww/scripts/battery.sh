#!/bin/bash

percentage () {
  local val=$(echo $1 | tr '%' ' ' | awk '{print $1}')
  local icon1=$2
  local icon2=$3
  local icon3=$4
  local icon4=$5
  local icon5=$6
  if [ "$val" -le 15 ]; then
    echo $icon1
  elif [ "$val" -le 35 ]; then
    echo $icon2
  elif [ "$val" -le 65 ]; then
    echo $icon3
  elif [ "$val" -le 85 ]; then
    echo $icon4
  else
    echo $icon5
  fi
}

get_icon () {
    # local br=$(get_percent)
    if [ "$state" == "fully-charged" ]; then
        echo ""
    elif [ "$state" == "charging" ]; then
        echo ""
    elif [ "$state" == "pending-charge" ]; then
        echo ""
    elif [ "$state" == "unknown" ]; then
        echo ""
    elif [ "$state" == "nobattery" ]; then
        echo ""
    else
        echo $(percentage "$PERCENTAGE" "" "" "" "" "")
    fi
}

get_class () {
    # local br=$(get_percent)
    if [ "$state" == "fully-charged" ]; then
        echo "fully"
    elif [ "$state" == "charging" ]; then
        echo "azure-color"
    elif [ "$state" == "pending-charge" ]; then
        echo "warn-color"
    elif [ "$state" == "unknown" ]; then
        echo "red-color"
    elif [ "$state" == "nobattery" ]; then
        echo "nodata-color"
    else
        echo $(percentage "$PERCENTAGE" "err-color" "warn-color" "ok-color" "ok-color" "ok-color")
    fi
}

DEVICE_PATH="/org/freedesktop/UPower/devices/battery_BAT0"
INFORMATION=$(upower -i "$DEVICE_PATH" 2> /dev/null)
PERCENTAGE=$(awk '/percentage/ {print $NF}' <<< $INFORMATION)
CAPACITY=$(awk '/capacity/ {print $NF}' <<< $INFORMATION)
UPDATED=$(awk -F '(' '/updated/ {print $NF}' <<< $INFORMATION | sed -r 's/\)//')
TIME_TO_EMPTY=$(awk -F ':' '/time to empty/ {print $NF}' <<< $INFORMATION | sed -r 's/\s{2,}//g')
TIME_TO_FULL=$(awk -F ':' '/time to full/ {print $NF}' <<< $INFORMATION | sed -r 's/\s{2,}//g')
state=$(awk '/state/ {print $NF}' <<< $INFORMATION)

if [ "$PERCENTAGE" == "ignored)" ]; then
  PERCENTAGE="100"
  CAPACITY="0"
  state="nobattery"
fi

icon=$(get_icon)
clazz=$(get_class)

PERCENTAGE=$(echo $PERCENTAGE | tr '%' ' ' | awk '{print $1}')
CAPACITY=$(echo $CAPACITY | tr '%' ' ' | awk '{print $1}')

TIME=$TIME_TO_EMPTY
if [[ $TIME -eq '' ]]; then
  TIME=$TIME_TO_FULL
fi
if [[ $TIME -eq '' ]]; then
  TIME="unknown"
fi
echo '{"percentage": "'"$PERCENTAGE"'", "capacity": "'"$CAPACITY"'", "updated": "'"$UPDATED"'", "eta": "'"$TIME"'", "icon": "'"$icon"'", "state": "'"$state"'", "clazz": "'"$clazz"'"}'
