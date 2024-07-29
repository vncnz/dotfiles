#!/bin/env bash

rm -rf ~/.config_bck
mkdir -p ~/.config_bck/dunst
mkdir -p ~/.config_bck/networkmanager-dmenu
cp -r ~/.config/niri ~/.config_bck/niri
cp -r ~/.config/eww ~/.config_bck/eww
cp ~/.config/dunst/dunstrc ~/.config_bck/dunst/dunstrc
cp -r ~/.config/networkmanager-dmenu/* ~/.config_bck/networkmanager-dmenu/
echo "Copied current config in .config_bck"

mkdir -p ~/.config/networkmanager-dmenu
cp -r ~/Repositories/dotfiles/wallpaper.jpg ~/Pictures/wallpaper.jpg
cp -r ~/Repositories/dotfiles/niri/* ~/.config/niri/
# cp -r ~/Repositories/dotfiles/waybar/* ~/.config/waybar/
cp -r ~/Repositories/dotfiles/eww/* ~/.config/eww/
cp ~/Repositories/dotfiles/dunst/dunstrc ~/.config/dunst/dunstrc
cp -r ~/Repositories/dotfiles/networkmanager-dmenu/* ~/.config/networkmanager-dmenu/
echo "Copied from repository to current config in .config"
