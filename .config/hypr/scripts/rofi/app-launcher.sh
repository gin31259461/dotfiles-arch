#!/usr/bin/env bash
# Rofi app launcher: drun mode with filebrowser, run, and window switching (SUPER D alternative).
# Uses ~/.config/rofi/config.rasi (theme selectable via SUPER CTRL R).

pgrep -x rofi | xargs -r kill 2>/dev/null || true
rofi -show drun -modi drun,filebrowser,run,window
