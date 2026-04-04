#!/usr/bin/env bash
# Handles screen locking functionality

# Ensure weather cache is up-to-date before locking
bash "$HOME/.config/hypr/scripts/services/weather-wrap.sh" >/dev/null 2>&1

loginctl lock-session
