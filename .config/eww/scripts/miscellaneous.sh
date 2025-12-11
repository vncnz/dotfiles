

#!/bin/bash

get_focused_window () {
  local w=$(niri msg focused-window 2> /dev/null)
  
  local title=$(grep 'Title' <<< $w)
  title=$(cut -d\" -f 2 <<< $title)

  local appid=$(grep 'App ID' <<< $w)
  appid=$(cut -d\" -f 2 <<< $appid)

  # echo $appid # | tr -d '%'
  echo '{"title": "'"$title"'", "appid": "'"$appid"'"}'
}

if [[ $1 == "win" ]]; then
  get_focused_window
fi