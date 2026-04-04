#!/usr/bin/env bash
# Handles screen locking functionality

# For Hyprlock
#pidof hyprlock || hyprlock -q

# Ensure weather cache is up-to-date before locking
bash "$HOME/.config/hypr/UserScripts/WeatherWrap.sh" >/dev/null 2>&1

loginctl lock-session

