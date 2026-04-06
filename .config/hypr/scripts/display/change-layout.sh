#!/usr/bin/env bash
# Cycles the window layout: dwindle → master → scrolling → dwindle

LAYOUT=$(hyprctl -j getoption general:layout | jq '.str' | sed 's/"//g')

# On init: step one back in the cycle so the case block re-applies
# keybinds for the current layout without actually changing it.
if [[ "$1" == "init" ]]; then
  case $LAYOUT in
    "dwindle")   LAYOUT="scrolling" ;;
    "master")    LAYOUT="dwindle"   ;;
    "scrolling") LAYOUT="master"    ;;
  esac
fi

case $LAYOUT in
  "dwindle")
    hyprctl keyword general:layout master
    hyprctl keyword unbind SUPER,J
    hyprctl keyword unbind SUPER,K
    hyprctl keyword unbind SUPER,O
    hyprctl keyword bind SUPER,J,layoutmsg,cyclenext
    hyprctl keyword bind SUPER,K,layoutmsg,cycleprev
    notify-send -e -u low " Master Layout"
    ;;
  "master")
    hyprctl keyword general:layout scrolling
    hyprctl keyword unbind SUPER,J
    hyprctl keyword unbind SUPER,K
    hyprctl keyword bind SUPER,J,layoutmsg,focus d
    hyprctl keyword bind SUPER,K,layoutmsg,focus u
    notify-send -e -u low " Scrolling Layout"
    ;;
  "scrolling")
    hyprctl keyword general:layout dwindle
    hyprctl keyword unbind SUPER,J
    hyprctl keyword unbind SUPER,K
    hyprctl keyword bind SUPER,J,cyclenext
    hyprctl keyword bind SUPER,K,cyclenext,prev
    hyprctl keyword bind SUPER,O,togglesplit
    notify-send -e -u low " Dwindle Layout"
    ;;
esac
