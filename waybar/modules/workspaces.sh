#!/usr/bin/env bash

case "$1" in
focus-workspace)
    niri msg action "$@" && pkill -SIGRTMIN+8 waybar;;
up)
    niri msg action focus-workspace-up && pkill -SIGRTMIN+8 waybar;;
down)
    niri msg action focus-workspace-down && pkill -SIGRTMIN+8 waybar;;
*)
    workspace_str=" "
    for ws in $(niri msg -j workspaces | jq ".[] | select(.output == \"$1\") | .is_active"); do
        workspace_str="$workspace_str$( if "$ws"; then
                 echo "<span color='#1793d1'></span>";
            else echo "<span></span>"; fi) "
    done
    name=$(niri msg -j workspaces | jq -r ".[] | select(.output == \"$1\" and .is_active == true) | .name")
    echo -e "{\"text\":\"${workspace_str}\", \"tooltip\":\"Active workspace name: ${name}\"}"
esac
