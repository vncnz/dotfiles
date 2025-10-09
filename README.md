# dotfiles

A simple repository for my dotfiles

# How to use stow

```
cd ~/Repositories/dotfiles/
stow . -t ~/.config
```

# Nemo configuration

The content of ```nemo_actions``` folder can be manually moved/copied in ```~/.local/share/nemo/actions/``` in order to add my custom actions to Nemo context menu.

# Other packages used
(Deprecated if between braches)
|source | name                     | description
|-------|--------------------------|-------------
|pacman | niri                     | scrollable-tiling Wayland compositor
|pacman | stow                     | Dotfiles management
|pacman | nemo                     | File explorer
|pacman | zip                      | for archive management in command line
|       | brightnessctl            | brightness management
|       | (eww)                    | used by the infobar on the bottom of the screen
|pacman | fuzzel                   | launcher
|       | iwmenu                   | network management
|pacman | jq                       | json parser for bash
|pacman | ttf-nerd-fonts-symbols*  | icons
|yay    | googledot-cursor-theme   | a cursor theme
|       | pactl                    | audio ctrl
|       | playerctl                | audio info and ctrl
|       | (swaybg)                 | wallpaper
|       | (swaync)                 | notification center
|pacman | swaylock                 | lock screen
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
|yay    | niri-screen-time-git     | Tracks time spent on applications
|yay    | btop                     | htop alternative

# Currently in use on my screen:
- niri (Window manager)
- ignis (Resources information, notifications, time, wallpaper)
- wob (Audio and brightness bar visible briefly on changes)
- Fuzzel, Fenrir (a project of mine) and Skoll (same) as launchers (I still have to decide)

# Some tips
- ```find /usr/share/icons ~/.local/share/icons ~/.icons -type d -name "cursors"``` lists all cursors installed in my system

# Next steps
- Who knows?
