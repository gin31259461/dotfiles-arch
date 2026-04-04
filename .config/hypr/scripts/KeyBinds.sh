#!/usr/bin/env bash
# Searchable keybinds viewer via rofi (supports bindd descriptions)

# Kill yad/rofi if running
pkill yad || true
if pidof rofi > /dev/null; then
  pkill rofi
fi

keybinds_conf="$HOME/.config/hypr/conf.d/keybinds.conf"
laptop_conf="$HOME/.config/hypr/conf.d/laptops.conf"
rofi_theme="$HOME/.config/rofi/config-keybinds.rasi"
msg='☣️ NOTE ☣️: Clicking with Mouse or Pressing ENTER will have NO function'

files=("$keybinds_conf")
[[ -f "$laptop_conf" ]] && files+=("$laptop_conf")

display_keybinds=$("$HOME/.config/hypr/scripts/keybinds_parser.py" "${files[@]}")

if [[ -f "/tmp/hypr_keybind_suggestions_file" ]]; then
  suggestions_file=$(cat "/tmp/hypr_keybind_suggestions_file")
  rm "/tmp/hypr_keybind_suggestions_file"
  if [[ -n "$suggestions_file" && -f "$suggestions_file" ]]; then
     count=$(wc -l < "$suggestions_file")
     msg="$msg | Overrides missing unbind: $count (suggestions: $suggestions_file)"
  fi
fi

printf '%s\n' "$display_keybinds" | rofi -dmenu -i -config "$rofi_theme" -mesg "$msg"
