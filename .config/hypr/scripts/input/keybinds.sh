#!/usr/bin/env bash
# Searchable keybinds viewer via rofi (supports bindd descriptions)

pkill yad || true
if pidof rofi > /dev/null; then
  pkill rofi
fi

keybinds_conf="$HOME/.config/hypr/conf.d/keybinds.conf"
laptop_conf="$HOME/.config/hypr/conf.d/laptops.conf"
rofi_theme="$HOME/.config/rofi/config-keybinds.rasi"
parser="$HOME/.config/hypr/scripts/input/keybinds-parser.py"
msg='☣️ NOTE ☣️: Clicking with Mouse or Pressing ENTER will have NO function'

files=("$keybinds_conf")
[[ -f "$laptop_conf" ]] && files+=("$laptop_conf")

[[ -x "$parser" ]] || exit 1
display_keybinds=$("$parser" "${files[@]}")

if [[ -f "/tmp/hypr_keybind_suggestions_file" ]]; then
  suggestions_file=$(cat "/tmp/hypr_keybind_suggestions_file")
  rm "/tmp/hypr_keybind_suggestions_file"
  if [[ -n "$suggestions_file" && -f "$suggestions_file" ]]; then
    count=$(wc -l < "$suggestions_file")
    msg="$msg | Overrides missing unbind: $count (suggestions: $suggestions_file)"
  fi
fi

printf '%s\n' "$display_keybinds" | rofi -dmenu -i -config "$rofi_theme" -mesg "$msg"
