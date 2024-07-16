#!/bin/bash

do_operation () {
    if [ "$operation" == "suspend" ]; then
        systemctl suspend
    elif [ "$operation" == "shutdown" ]; then
        shutdown
    elif [ "$operation" == "reboot" ]; then
        reboot
    fi
}


operation=$(printf "suspend\nshutdown\nreboot\nnothing" | fuzzel -d)
if [ "$operation" != "nothing" ]; then
    confirmed=$(printf "confirm\nundo" | fuzzel -p "Are you sure?" -d)
    if [ "$confirmed" == "confirm" ]; then
        do_operation
    fi
fi