#!/usr/bin/env bash
# Waybar style picker — select a CSS style via rofi (SUPER CTRL B)

IFS=$'\n\t'

waybar_styles="$HOME/.config/waybar/style"
waybar_style="$HOME/.config/waybar/style.css"
scriptsDir="$HOME/.config/hypr/scripts"
rofi_config="$HOME/.config/rofi/config-waybar-style.rasi"
msg='Choose a Waybar style'

apply_style() {
    ln -sf "$waybar_styles/$1.css" "$waybar_style"
    pgrep -x waybar >/dev/null && pkill -SIGUSR2 waybar || true
}

main() {
    current_name=$(basename "$(readlink -f "$waybar_style")" .css)

    mapfile -t options < <(
        find -L "$waybar_styles" -maxdepth 1 -type f -name '*.css' \
            -exec basename {} .css \; | sort
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
    apply_style "$choice"
}

pgrep -x rofi | xargs -r kill
main
