#!/bin/env bash

cp -r ~/Pictures/wallpaper.jpg ~/Repositories/dotfiles/wallpaper.jpg
cp -r ~/.config/niri/* ~/Repositories/dotfiles/niri/
# cp -r ~/.config/waybar/* ~/Repositories/dotfiles/waybar/
cp -r ~/.config/eww/* ~/Repositories/dotfiles/eww/

echo "Copied from .config to repository folder"