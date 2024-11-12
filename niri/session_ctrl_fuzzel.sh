#!/bin/bash

# do_operation () {
#     if [ "$operation" == "suspend" ]; then
#         systemctl suspend
#     elif [ "$operation" == "shutdown" ]; then
#         shutdown now
#     elif [ "$operation" == "reboot" ]; then
#         reboot
#     fi
# }


# operation=$(printf "suspend\nshutdown\nreboot\nnothing" | fuzzel -d)
# if [ "$operation" != "nothing" ] && [ "$operation" != "" ]; then
#     confirmed=$(printf "confirm\nundo" | fuzzel -p "Are you sure?" -d)
#     if [ "$confirmed" == "confirm" ]; then
#         do_operation
#     fi
# fi

SELECTION="$(printf "1 - Lock\n2 - Suspend\n3 - Log out\n4 - Reboot\n5 - Reboot to UEFI\n6 - Hard reboot\n7 - Shutdown" | fuzzel --dmenu -l 7 -p "Power Menu: ")"

case $SELECTION in
	*"Lock")
		swaylock -i /home/vncnz/.config/wallpaper.jpg;;
	*"Suspend")
		systemctl suspend;;
	*"Log out")
		swaymsg exit;;
	*"Reboot")
		systemctl reboot;;
	*"Reboot to UEFI")
		systemctl reboot --firmware-setup;;
	*"Hard reboot")
		pkexec "echo b > /proc/sysrq-trigger";;
	*"Shutdown")
		systemctl poweroff;;
esac
