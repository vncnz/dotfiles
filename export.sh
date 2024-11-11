#!/bin/env bash

cp -r ~/Pictures/wallpaper.jpg ~/Repositories/dotfiles/wallpaper.jpg
cp -r ~/.config/niri/* ~/Repositories/dotfiles/niri/
# cp -r ~/.config/waybar/* ~/Repositories/dotfiles/waybar/
rm -r ~/Repositories/dotfiles/eww/*
cp -r ~/.config/eww/* ~/Repositories/dotfiles/eww/
cp ~/.config/dunst/dunstrc ~/Repositories/dotfiles/dunst/dunstrc
cp -r ~/.config/swaync/* ~/Repositories/dotfiles/swaync/
cp -r ~/.config/networkmanager-dmenu/* ~/Repositories/dotfiles/networkmanager-dmenu/

echo "Copied from .config to repository folder"
