#!/bin/env bash

rm -rf ~/.config_bck
mkdir -p ~/.config_bck
cp -r ~/.config/niri ~/.config_bck/niri
cp -r ~/.config/eww ~/.config_bck/eww
cp ~/.config/dunst/dunstrc ~/.config_bck/dunst/dunstrc
echo "Copied current config in .config_bck"

cp -r ~/Repositories/dotfiles/wallpaper.jpg ~/Pictures/wallpaper.jpg
cp -r ~/Repositories/dotfiles/niri/* ~/.config/niri/
# cp -r ~/Repositories/dotfiles/waybar/* ~/.config/waybar/
cp -r ~/Repositories/dotfiles/eww/* ~/.config/eww/
cp ~/Repositories/dotfiles/dunst/dunstrc ~/.config/dunst/dunstrc
echo "Copied from repository to current config in .config"
