#!/usr/bin/env bash
# change_wallpaper.sh
# Usa: change_wallpaper.sh next | prev

# === CONFIG ===
WALLPAPER_DIR="$HOME/Pictures/wallpapers"
SWWW_CMD="swww img"
# TRANSITION_OPTS="--transition-type any --transition-duration 1"

# === FUNZIONI ===
get_current_wallpaper() {
    swww query 2>/dev/null | grep "image:" | head -n 1 | sed 's/.*image: //'
}

get_all_wallpapers() {
    find "$WALLPAPER_DIR" -type f \
        \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.gif" \) \
        -print0 \
    | sort -z 2>/dev/null || cat
    # NOTE: output is NUL-separated
}

change_wallpaper() {
    local direction="$1"
    local current
    local wallpapers
    local count
    local current_index=-1
    local new_index
    local new_wallpaper

    # wallpapers=($(get_all_wallpapers))
    mapfile -d $'\0' -t wallpapers < <(get_all_wallpapers)
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

    angle="0"
    if [[ $current_index -eq -1 ]]; then
        echo "⚠️ Current wallpaper not found in folder. Selecting the first one"
        new_index=0
    else
        case "$direction" in
            next) new_index=$(( (current_index + 1) % count )); angle="30" ;;
            prev) new_index=$(( (current_index - 1 + count) % count )); angle="210" ;;
            next_folder)
                local current_dir
                current_dir=$(dirname "${wallpapers[$current_index]}")
                new_index=$current_index
                for (( i=1; i<=count; i++ )); do
                    local test_index=$(( (current_index + i) % count ))
                    local test_dir
                    test_dir=$(dirname "${wallpapers[$test_index]}")
                    if [[ "$test_dir" != "$current_dir" ]]; then
                        new_index=$test_index
                        break
                    fi
                done
                ;;
            prev_folder)
                local current_dir
                current_dir=$(dirname "${wallpapers[$current_index]}")
                new_index=$current_index
                for (( i=1; i<=count; i++ )); do
                    local test_index=$(( (current_index - i + count) % count ))
                    local test_dir
                    test_dir=$(dirname "${wallpapers[$test_index]}")
                    if [[ "$test_dir" != "$current_dir" ]]; then
                        new_index=$test_index
                        break
                    fi
                done
                ;;
            random)
                new_index=$(( RANDOM % count )) ;;
            *) echo "Uso: $0 next | prev | next_folder | prev_folder | random"; exit 1 ;;
        esac
    fi

    new_wallpaper="${wallpapers[$new_index]}"
    echo "✅ Setting $new_wallpaper $angle"
    $SWWW_CMD "$new_wallpaper" "--transition-type" "wipe" "--transition-angle" $angle "--transition-step" "30" "--transition-fps" "30" "--transition-duration" "0.5"
}

# === MAIN ===
if [[ $# -ne 1 ]]; then
    echo "Uso: $0 next | prev"
    exit 1
fi

change_wallpaper "$1"
