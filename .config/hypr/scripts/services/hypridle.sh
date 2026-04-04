#!/usr/bin/env bash
# Configures idle state management for Hyprland

PROCESS="hypridle"

command -v "$PROCESS" >/dev/null 2>&1 || { notify-send "hypridle not found"; exit 1; }

if [[ "$1" == "status" ]]; then
  if pgrep -x "$PROCESS" >/dev/null; then
    echo '{"text": "RUNNING", "class": "active", "tooltip": "idle_inhibitor NOT ACTIVE\nLeft Click: Activate\nRight Click: Lock Screen"}'
  else
    echo '{"text": "NOT RUNNING", "class": "notactive", "tooltip": "idle_inhibitor is ACTIVE\nLeft Click: Deactivate\nRight Click: Lock Screen"}'
  fi
elif [[ "$1" == "toggle" ]]; then
  if pgrep -x "$PROCESS" >/dev/null; then
    pkill "$PROCESS"
  else
    "$PROCESS" >/dev/null 2>&1 & disown
  fi
else
  echo "Usage: $0 {status|toggle}"
  exit 1
fi
