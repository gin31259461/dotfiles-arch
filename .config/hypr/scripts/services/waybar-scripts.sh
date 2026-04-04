#!/usr/bin/env bash
# Waybar click-handler helper — launches terminal apps from waybar modules
# Usage: waybar-scripts.sh [--btop|--nvtop|--nmtui|--term|--files]

# Read $term and $files from env.conf
env_conf="$HOME/.config/hypr/conf.d/env.conf"
term=$(grep -m1 '^\$term\s*=' "$env_conf" | sed 's/.*=\s*//')
files=$(grep -m1 '^\$files\s*=' "$env_conf" | sed 's/.*=\s*//')

if [[ -z "$term" ]]; then
    notify-send -u critical "waybar-scripts" "\$term not set in conf.d/env.conf"
    exit 1
fi

case "$1" in
    --btop)   exec $term --title btop  -e btop ;;
    --nvtop)  exec $term --title nvtop -e nvtop ;;
    --nmtui)  exec $term -e nmtui ;;
    --term)   exec $term ;;
    --files)
        if [[ -z "$files" ]]; then
            notify-send -u low "waybar-scripts" "\$files not set in conf.d/env.conf"
            exit 1
        fi
        exec $files
        ;;
    *)
        echo "Usage: $0 [--btop | --nvtop | --nmtui | --term | --files]"
        exit 1
        ;;
esac
