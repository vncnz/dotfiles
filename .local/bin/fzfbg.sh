#!/usr/bin/bash
set -euo pipefail
WALLPAPERS_DIR=${HOME}/Pictures/wallpapers/;
YELLOW="\033[34m"

if [ ! -f /usr/bin/fzf ]; then
  printf "No fzf executable found. Please install fzf.\n${YELLOW}sudo pacman -S fzf\n"
  sleep 3
  exit 1;
fi

choosen=$(
  find "$WALLPAPERS_DIR" -type f | fzf \
    --layout=reverse \
    --preview-window="top:24,wrap" \
    --preview-border=none \
    --bind 'ctrl-j:down,ctrl-k:up,alt-j:preview-down,alt-k:preview-up' \
    --preview "chafa -s $(tput cols)x24 --fill=block --watch {} --clear --probe=on"
)

if [ -n "$choosen" ]; then
    echo "Choosen ${choosen}"
    awww img "$choosen" "--transition-type" "wipe" "--transition-angle" "30" "--transition-step" "30" "--transition-fps" "30" "--transition-duration" "0.5"
fi