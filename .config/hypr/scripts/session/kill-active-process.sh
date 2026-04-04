#!/usr/bin/env bash
# Terminates the currently active window process

# Get id of an active window
active_pid=$(hyprctl -j activewindow | jq -r '.pid')

if [[ -z "$active_pid" || ! "$active_pid" =~ ^[0-9]+$ ]]; then
  notify-send -u low -i "$HOME/.config/swaync/images/error.png" "Kill Active Window" "No active window PID found."
  exit 1
fi

# Close active window
kill "$active_pid"
