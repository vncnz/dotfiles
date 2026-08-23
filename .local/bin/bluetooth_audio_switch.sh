#!/usr/bin/env bash

# Fetch the current default sink name
CURRENT_SINK=$(pactl get-default-sink)

# Find a connected Bluetooth sink (if any)
BT_SINK=$(pactl list short sinks | grep -E "bluez|bluetooth" | awk '{print $2}' | head -n 1)

# Find the internal/analog audio sink (wired/speakers)
# Fallback excludes Bluetooth devices
INT_SINK=$(pactl list short sinks | grep -E "alsa_output|analog|pci" | grep -vE "bluez|bluetooth" | awk '{print $2}' | head -n 1)

# Safety check: ensure internal sink exists
if [ -z "$INT_SINK" ]; then
    INT_SINK=$(pactl list short sinks | grep -vE "bluez|bluetooth" | awk '{print $2}' | head -n 1)
fi

# Determine target sink
if [ -n "$BT_SINK" ] && [ "$CURRENT_SINK" != "$BT_SINK" ]; then
    TARGET_SINK="$BT_SINK"
    DEVICE_NAME="Bluetooth Headphones"
else
    TARGET_SINK="$INT_SINK"
    DEVICE_NAME="Internal / Wired Audio"
fi

# Exit early if target sink cannot be determined
if [ -z "$TARGET_SINK" ]; then
    notify-send -a "Audio stream switcher" -u critical "Audio Switcher" "No valid target sink found."
    exit 1
fi

# NO-OP CHECK: Exit silently if already on the target sink
if [ "$TARGET_SINK" = "$CURRENT_SINK" ]; then
    notify-send -a "Audio stream switcher" -i audio-headphones "Can't switch audio" "Can't switch audio: no alternative sinks"
    exit 0
fi

# Set default sink for new streams
pactl set-default-sink "$TARGET_SINK"

# Move all existing active sink-inputs to the new sink
pactl list short sink-inputs | awk '{print $1}' | while read -r input_id; do
    [ -n "$input_id" ] && pactl move-sink-input "$input_id" "$TARGET_SINK"
done

# Send desktop notification
notify-send -a "Audio stream switcher" -i audio-headphones "Audio Switched" "Audio output moved to: $DEVICE_NAME"