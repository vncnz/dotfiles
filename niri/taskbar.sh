#!/bin/bash

# Example in EWW
# (defpoll windows_enhanced :interval "2s" "~/.config/niri/taskbar.sh")
# (defpoll workspaces :interval "2s" "niri msg -j workspaces | jq 'sort_by(.id)'")
# (label :text {windows_enhanced["1"]} :visible false)
# (for wo in {workspaces}
#     (box :space-evenly false
#         (box :space-evenly false :spacing 4 :class "workspace" :visible {arraylength(windows_enhanced[wo["id"]]) > 0}
#             (label :text {wo["output"] == "eDP-1" ? "󰌢" : "󰍹"} :class "workspace-id" :width 18 :height 16 :halign "center")
#             (for wi in {windows_enhanced[wo["id"]]}
#                 (taskbar_el :wi wi :wi_id {wi["id"]})
#             )
#         )
#     )
# )



input_json=$(niri msg -j windows)

# Directory di sistema dove cercare i file .desktop
DESKTOP_DIRS=("/usr/share/applications" "$HOME/.local/share/applications")

# Directory di sistema dove cercare le icone
ICON_DIRS=("/usr/share/icons" "$HOME/.local/share/icons" "/usr/share/pixmaps")

# Funzione per trovare l'icona dato un app_id
find_icon() {
    local app_id=$1
    local icon_name=""

    # Cerca il file .desktop corrispondente all'app_id
    for dir in "${DESKTOP_DIRS[@]}"; do
        desktop_file=$(find "$dir" -type f -name "$app_id.desktop" 2>/dev/null | head -n 1)
        if [[ -n $desktop_file ]]; then
            # Estrae la prima occorrenza valida di Icon dal file .desktop
            icon_name=$(grep -i "^Icon=" "$desktop_file" | head -n 1 | cut -d'=' -f2 | tr -d ' ')
            break
        fi
    done

    # Se non è riuscito a trovare l'icona, ritorna una stringa vuota
    if [[ -z $icon_name ]]; then
        echo ""
        return
    fi

    # Cerca l'icona nei temi specificati nelle directory delle icone
    for dir in "${ICON_DIRS[@]}"; do
        icon_path=$(find "$dir" -type f -name "$icon_name.*" 2>/dev/null | head -n 1)
        if [[ -n $icon_path ]]; then
            echo "$icon_path"
            return
        fi
    done

    # Se l'icona non viene trovata come file, restituisce il nome dell'icona generico
    echo "$icon_name"
}

# Elabora ogni oggetto JSON e aggiungi il percorso dell’icona, raggruppando per workspace_id
output_json=$(echo "$input_json" | jq --compact-output '.[]' | while read -r app; do
    app_id=$(echo "$app" | jq -r '.app_id')
    workspace_id=$(echo "$app" | jq -r '.workspace_id')
    icon_path=$(find_icon "$app_id")
    # Aggiungi il percorso dell'icona al JSON dell'app e include il workspace_id
    echo "$app" | jq --arg icon "$icon_path" --arg workspace_id "$workspace_id" '. + {icon: $icon, workspace_id: $workspace_id}'
done | jq -s 'group_by(.workspace_id) | map({(.[0].workspace_id): .}) | add')

# Output finale
echo "$output_json"
