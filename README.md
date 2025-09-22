# dotfiles

A simple repository for my dotfiles

# How to use stow

```
cd ~/Repositories/dotfiles/
stow . -t ~/.config
```

# Other packages used
|source | name                     | description
|-------|--------------------------|-------------
|       | niri                     | scrollable-tiling Wayland compositor
|       | brightnessctl            | brightness management
|       | eww                      | used by the infobar on the bottom of the screen
|       | fuzzel                   | launcher
|       | iwmenu                   | network management
|       | jq                       | json parser for bash
|pacman | ttf-nerd-fonts-symbols*  | icons
|       | pactl                    | audio ctrl
|       | playerctl                | audio info and ctrl
|       | swaybg                   | wallpaper
|       | swaync                   | notification center
|       | swaylock                 | lock screen
|       | pika-backup              | backup system
|       | wl-clipboard             | for wl-copy in pipeline with cmds
|       | skoll                    | launcher - personal project
|pacman | iwd impala               | for wireless management through a TUI
|pacman | nmtui                    | for wireless management through a TUI
|pacman | bluetui                  | for bluetooth management through a TUI
|yay    | tray-tui                 | for tray usage through a TUI
|yay    | diskonaut                | for disk usage through a TUI
|pacman | gdu                      | for disk usage
|pacman | lf                       | for file exploring through a TUI
|pacman | texlive-luatex           | latex
|pacman | power-profiles-daemon    | Power management
|pacman | matugen                  | generate colors for wallpaper
|pacman | python-ignis             | Alternative for quickshell/eww, swaync, swaybg
|yay    | wob                      | Lightweight overlay bar for volume and brightness

# After cfg update
Sometimes eww freezes when you are touching its configuration...
```
killall eww -9; eww daemon; eww open microstatusbar
```

# Next steps

- Evaluate RGLauncher and RGBar from https://github.com/aeghn/config