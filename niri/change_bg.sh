#!/usr/bin/env bash
# change_wallpaper.sh
# Usa: change_wallpaper.sh next | prev

# === CONFIG ===
WALLPAPER_DIR="$HOME/Pictures/wallpapers"
SWWW_CMD="swww img"
# TRANSITION_OPTS="--transition-type any --transition-duration 1"
TRANSITION_OPTS="--transition-type wipe --transition-angle 30 --transition-step 30 --transition-fps 30 --transition-duration 0.5"

# === FUNZIONI ===
get_current_wallpaper() {
    swww query | grep "image:" | sed 's/.*image: //'
}

get_all_wallpapers() {
    find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | sort
}

change_wallpaper() {
    local direction="$1"
    local current
    local wallpapers
    local count
    local current_index
    local new_index
    local new_wallpaper

    wallpapers=($(get_all_wallpapers))
    count=${#wallpapers[@]}

    if [[ $count -eq 0 ]]; then
        echo "❌ No wallpapers in $WALLPAPER_DIR"
        exit 1
    fi

    current=$(get_current_wallpaper)
    current_index=-1
    for i in "${!wallpapers[@]}"; do
        if [[ "${wallpapers[$i]}" == "$current" ]]; then
            current_index=$i
            break
        fi
    done

    if [[ $current_index -eq -1 ]]; then
        echo "⚠️ Current wallpaper not found in folder. Selecting the first one"
        new_index=0
    else
        case "$direction" in
            next) new_index=$(( (current_index + 1) % count )) ;;
            prev) new_index=$(( (current_index - 1 + count) % count )) ;;
            *) echo "Uso: $0 next | prev"; exit 1 ;;
        esac
    fi

    new_wallpaper="${wallpapers[$new_index]}"
    echo "✅ Setting $new_wallpaper"
    $SWWW_CMD "$new_wallpaper" $TRANSITION_OPTS
}

# === MAIN ===
if [[ $# -ne 1 ]]; then
    echo "Uso: $0 next | prev"
    exit 1
fi

change_wallpaper "$1"
