# dotfiles

A simple repository for my dotfiles

# How to use stow

```
cd ~/Repositories/dotfiles/
stow . -t ~/.config
```

# Nemo configuration

The content of ```nemo_actions``` folder can be manually moved/copied in ```~/.local/share/nemo/actions/``` in order to add my custom actions to Nemo context menu.

# Custom aliases

The content of ```aliases``` is a list of my aliases.

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
|yay    | matugen                  | generate colors for wallpaper
|pacman | python-ignis             | Alternative for quickshell/eww, swaync, swaybg
|pacman | swww                     | Wallpaper manager with nice transition
|yay    | wob                      | Lightweight overlay bar for volume and brightness
|pacman | termdown                 | An utility for timers and countdowns
|yay    | niri-screen-time-git     | Tracks time spent on applications
|yay    | btop                     | htop alternative
|pacman | tig                      | Git log viewer TUI
|pacman | entr                     | File watcher that re-exec cmd on file updates

# Currently in use on my screen:
- niri (Window manager)
- ~~ignis (Resources information, notifications, time, optional wallpaper)~~
- [Heimdallr](https://github.com/vncnz/heimdallr), a project of mine, as desktop-shell and notification manager
- swww (for wallpaper management)
- wob (Audio and brightness bar visible briefly on changes)
- Fuzzel, [Fenrir](https://github.com/vncnz/fenrir) (a project of mine) and Skoll (same) as launchers (I still have to decide)

## Screenshots

Heimdallr, neofetch and fenrir on kitty, two resource alarms (RAM and disk):
![heimdallr fenrir neofetch](./screenshots/heimdallr%20and%20fenrir.png)

Heimdallr, neofetch and fenrir on kitty, two resource alarms (RAM and disk), notification shown:
![heimdallr fenrir neofetch notification](./screenshots/heimdallr%20and%20fenrir%20and%20notification.png)

# Some tips
- ```find /usr/share/icons ~/.local/share/icons ~/.icons -type d -name "cursors"``` lists all cursors installed in my system

# Next steps
- handle notification bursts by introducing a short delay and showing only the latest one
- special management for reboot request by pacman via notification (for example, reboot icon in Foreground widget instead of the usual bell icon)
- better theme using / color computing
- evaluate to make matugen optional and insert colors in settings.json
- evaluate to make swww optional
- show song info / lyrics in overpression?