#!/usr/bin/env bash
# Refreshes Hyprland configuration


for proc in rofi swaync ags; do pkill -x "$proc" 2>/dev/null || true; done
pkill -x qs 2>/dev/null || true
qs &
sleep 0.3
swaync >/dev/null 2>&1 &
swaync-client --reload-config
sleep 1
[[ -f "$HOME/.config/hypr/scripts/display/RainbowBorders.sh" ]] && "$HOME/.config/hypr/scripts/display/RainbowBorders.sh" &

exit 0
