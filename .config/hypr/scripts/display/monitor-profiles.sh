#!/usr/bin/env bash
# Manages monitor profile configurations

# Check if rofi is already running
if pidof rofi > /dev/null; then
  pkill rofi
fi

# Variables
iDIR="$HOME/.config/swaync/images"
scriptsDir="$HOME/.config/hypr/scripts"
monitor_dir="$HOME/.config/hypr/monitor-profiles"
target="$HOME/.config/hypr/monitors.conf"
rofi_theme="$HOME/.config/rofi/config-Monitors.rasi"
msg='❗NOTE:❗ This will overwrite $HOME/.config/hypr/monitors.conf'

# List of Monitor Profiles, sorted alphabetically with numbers first
mon_profiles_list=$(find -L "$monitor_dir" -maxdepth 1 -type f | sed 's/.*\///' | sed 's/\.conf$//' | sort -V)

# Rofi Menu
chosen_file=$(echo "$mon_profiles_list" | rofi -i -dmenu -config "$rofi_theme" -mesg "$msg")

if [[ -n "$chosen_file" ]]; then
  full_path="$monitor_dir/$chosen_file.conf"
  cp "$full_path" "$target"
  notify-send -u low -i "$iDIR/ja.png" "$chosen_file" "Monitor Profile Loaded"
fi

sleep 1
"${scriptsDir}/services/refresh-theme.sh" &