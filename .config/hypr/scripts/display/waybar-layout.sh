#!/usr/bin/env bash
# Waybar layout picker — select a config layout via rofi (SUPER ALT B)

IFS=$'\n\t'

waybar_layouts="$HOME/.config/waybar/configs"
waybar_config="$HOME/.config/waybar/config"
scriptsDir="$HOME/.config/hypr/scripts"
rofi_config="$HOME/.config/rofi/config-waybar-layout.rasi"
msg='Choose a Waybar layout'

apply_layout() {
    ln -sf "$waybar_layouts/$1" "$waybar_config"
    pgrep -x waybar >/dev/null && pkill -SIGUSR2 waybar || true
}

main() {
    current_name=$(basename "$(readlink -f "$waybar_config")")

    mapfile -t options < <(
        find -L "$waybar_layouts" -maxdepth 1 -type f -printf '%f\n' | sort
    )

    MARKER="›"
    default_row=0
    for i in "${!options[@]}"; do
        if [[ "${options[i]}" == "$current_name" ]]; then
            options[i]="$MARKER ${options[i]}"
            default_row=$i
            break
        fi
    done

    choice=$(printf '%s\n' "${options[@]}" \
        | rofi -i -dmenu \
               -config "$rofi_config" \
               -mesg "$msg" \
               -selected-row "$default_row")

    [[ -z "$choice" ]] && exit 0
    choice="${choice#"$MARKER "}"

    if [[ "$choice" == "no panel" ]]; then
        pgrep -x waybar | xargs -r kill
    else
        apply_layout "$choice"
    fi
}

pgrep -x rofi | xargs -r kill
main
