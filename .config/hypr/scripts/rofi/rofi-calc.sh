#!/usr/bin/env bash
# Calculator interface via Rofi

rofi_theme="$HOME/.config/rofi/config-calc.rasi"

command -v qalc >/dev/null 2>&1 || { notify-send "qalc not found"; exit 1; }

# Kill Rofi if already running before execution
if pgrep -x "rofi" >/dev/null; then
  pkill rofi
fi

while true; do
  result=$(
    rofi -i -dmenu \
      -config "$rofi_theme" \
      -mesg "$result      =    $calc_result"
  ) || exit 0

  if [[ -n "$result" ]]; then
    calc_result=$(qalc -t "$result")
    echo "$calc_result" | wl-copy
  fi
done
