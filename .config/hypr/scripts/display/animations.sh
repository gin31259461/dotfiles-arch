#!/usr/bin/env bash
# Configures window animation settings

if pidof rofi > /dev/null; then
  pkill rofi
fi

iDIR="$HOME/.config/swaync/images"
scriptsDir="$HOME/.config/hypr/scripts"
animations_dir="$HOME/.config/hypr/animations"
confd="$HOME/.config/hypr/conf.d"
rofi_theme="$HOME/.config/rofi/config-Animations.rasi"
msg='❗NOTE:❗ This will copy the selected preset into conf.d/animations.conf'
animations_list=$(find -L "$animations_dir" -maxdepth 1 -type f | sed 's/.*\///' | sed 's/\.conf$//' | sort -V)

chosen_file=$(echo "$animations_list" | rofi -i -dmenu -config "$rofi_theme" -mesg "$msg")

if [[ -n "$chosen_file" ]]; then
  full_path="$animations_dir/$chosen_file.conf"
  cp "$full_path" "$confd/animations.conf"
  notify-send -u low -i "$iDIR/ja.png" "$chosen_file" "Hyprland Animation Loaded"
fi

sleep 1
"$scriptsDir/services/refresh-theme.sh"
