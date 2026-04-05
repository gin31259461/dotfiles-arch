#!/usr/bin/env bash
# Sync dotfiles to the bare git repo.
# Reference: https://github.com/JaKooLit/Hyprland-Dots
#
# Usage: dotfiles.sh [-m "commit message"]

set -euo pipefail

# ── helpers ──────────────────────────────────────────────────────

dot() { git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME" "$@"; }

# ── options ──────────────────────────────────────────────────────

COMMIT_MSG="sync dotfiles"
while getopts ":m:" opt; do
  case $opt in
  m) COMMIT_MSG="$OPTARG" ;;
  \?)
    echo "Usage: $0 [-m <commit message>]" >&2
    exit 1
    ;;
  :)
    echo "Option -m requires an argument." >&2
    exit 1
    ;;
  esac
done

cd "$HOME"

# ── stage files ──────────────────────────────────────────────────

# git & shell
dot add \
  README.md \
  doc \
  .local/bin/dotfiles.sh \
  .local/bin/install-packages.sh \
  .gitconfig \
  .gitmodules \
  .gitignore \
  .github

# zsh
dot add \
  .zshrc \
  .zprofile \
  .p10k.zsh

# gtk
dot add \
  .icons/Papirus \
  .icons/Bibata-Modern-Ice \
  .local/share/themes/adw-gtk3 \
  .config/gtk-3.0 \
  .config/gtk-4.0

# app configs — https://github.com/JaKooLit/Hyprland-Dots/tree/main/config
dot add \
  .config/nvim \
  .config/kitty \
  .config/electron-flags.conf \
  .config/hypr \
  .config/Kvantum \
  .config/quickshell \
  .config/rofi \
  .config/btop \
  .config/fastfetch \
  .config/qt5ct \
  .config/qt6ct \
  .config/swappy \
  .config/swaync \
  .config/wallust \
  .config/discord/settings.json \
  .config/cava \
  .config/ghostty \
  .config/waybar \
  .config/noctalia

# OneDrive
dot add \
  .config/onedrive/config \
  .config/onedrive/sync_list

# ── commit and push ──────────────────────────────────────────────

dot commit -m "$COMMIT_MSG"
dot push origin main
