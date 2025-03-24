# dotfiles

A simple repository for my dotfiles

# stow

cd ~/Repositories/dotfiles/
stow . -t ~/.config

# Other packages used

brightnessctl
eww (used by the infobar on the bottom of the screen)
fuzzel (launcher)
iwmenu (network management)
jq (json parser for bash)
ttf-nerd-fonts-symbols*
niri (scrollable-tiling Wayland compositor)
pactl (audio ctrl)
playerctl (audio info and ctrl)
swaybg (wallpaper)
swaync (notification center)
---
skoll (sirula forking by me)

### To be added to my notebook
``` sudo pacman -S iwd impala ``` for wireless management
``` sudo pacman -S bluetui ``` for bluetooth management
``` yay -S tray-tui ``` for tray usage
``` yay -S diskonaut ``` for disk managing
``` sudo pacman -S lf ``` for file exploring

# After cfg update

Restart EWW if frozen:
killall eww -9; eww daemon; eww open microstatusbar

# Next steps

- Use wttr? curl wttr.in/{Desenzano+Del+Garda,Bosco+Chiesanuova,Malmö,Oslo}?format="%l:+%c+%t+%f+%S+%s\n"

- Evaluate RGLauncher and RGBar from https://github.com/aeghn/config