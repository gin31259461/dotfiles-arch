#!/usr/bin/env bash
# Adjusts window blur effect settings

STATE=$(hyprctl -j getoption decoration:blur:passes | jq ".int")

if [[ "${STATE}" == "2" ]]; then
  hyprctl keyword decoration:blur:size 2
  hyprctl keyword decoration:blur:passes 1
  notify-send -e -u low -i "$HOME/.config/swaync/images/note.png" " Less Blur"
else
  hyprctl keyword decoration:blur:size 5
  hyprctl keyword decoration:blur:passes 2
  notify-send -e -u low -i "$HOME/.config/swaync/images/ja.png" " Normal Blur"
fi
