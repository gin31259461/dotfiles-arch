#!/usr/bin/env bash
# Provides web search functionality via Rofi interface

config_file="$HOME/.config/hypr/conf.d/env.conf"

if ! command -v jq >/dev/null 2>&1; then
  notify-send -u low "Rofi Search" "jq is required for URL encoding. Please install jq."
  exit 1
fi

if [[ ! -f "$config_file" ]]; then
  echo "Error: Configuration file not found!"
  exit 1
fi

Search_Engine=$(grep '^\$Search_Engine' "$config_file" | sed 's/\$Search_Engine *= *//; s/"//g')

if [[ -z "$Search_Engine" ]]; then
  echo "Error: \$Search_Engine is not set in the configuration file!"
  exit 1
fi

rofi_theme="$HOME/.config/rofi/config-search.rasi"
msg='‼️ **note** ‼️ search via default web browser'

if pgrep -x "rofi" >/dev/null; then
  pkill rofi
fi

query=$(printf '' | rofi -dmenu -config "$rofi_theme" -mesg "$msg")

if [[ -z "$query" ]]; then
  exit 0
fi

encoded_query=$(printf '%s' "$query" | jq -sRr @uri)
xdg-open "${Search_Engine}${encoded_query}" >/dev/null 2>&1 &
