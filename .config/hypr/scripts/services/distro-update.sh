#!/usr/bin/env bash
# Handles distribution-specific package updates

# Local Paths
iDIR="$HOME/.config/swaync/images"

# Check for required tools (kitty)
if ! command -v kitty &> /dev/null; then
  notify-send -i "$iDIR/error.png" "Need Kitty:" "Kitty terminal not found. Please install Kitty terminal."
  exit 1
fi

distro_name=""

# Detect distribution and update accordingly
if command -v paru &> /dev/null; then
  kitty -T update -e paru -Syu
  distro_name="Arch-based system"
elif command -v yay &> /dev/null; then
  kitty -T update -e yay -Syu
  distro_name="Arch-based system"
elif command -v dnf &> /dev/null; then
  kitty -T update -e sudo dnf update --refresh -y
  distro_name="Fedora system"
elif command -v apt &> /dev/null; then
  kitty -T update -e bash -c "sudo apt update && sudo apt upgrade -y"
  distro_name="Debian/Ubuntu system"
elif command -v zypper &> /dev/null; then
  kitty -T update -e sudo zypper dup -y
  distro_name="openSUSE system"
else
  notify-send -i "$iDIR/error.png" -u critical "Unsupported system" "This script does not support your distribution."
  exit 1
fi

notify-send -i "$iDIR/ja.png" -u low "$distro_name" 'has been updated.'
