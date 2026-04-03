# this dotfile refer to: https://github.com/JaKooLit/Hyprland-Dots

# Parse optional -m flag for commit message
COMMIT_MSG="sync dotfiles"
while getopts ":m:" opt; do
  case $opt in
    m) COMMIT_MSG="$OPTARG" ;;
    \?) echo "Usage: $0 [-m <commit message>]" >&2; exit 1 ;;
    :) echo "Option -m requires an argument." >&2; exit 1 ;;
  esac
done

cd $HOME

alias dot='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# git files
dot add README.md doc dotfiles.sh .gitconfig .gitmodules

# zsh
dot add .zshrc .zprofile .p10k.zsh

# gtk
dot add .icons .config/gtk-3.0

# configs
# https://github.com/JaKooLit/Hyprland-Dots/tree/main/config
dot add .config/nvim
dot add .config/kitty
dot add .config/hypr
dot add .config/Kvantum
dot add .config/quickshell
dot add .config/rofi
dot add .config/btop
dot add .config/fastfetch
dot add .config/qt5ct
dot add .config/qt6ct
dot add .config/swappy
dot add .config/swaync
dot add .config/wallust
dot add .config/discord/settings.json
dot add .config/noctalia

dot add .config/electron-flags.conf
dot add .config/discord-flags.conf
dot add .config/notion-app-flags.conf

# OneDrive
dot add .config/onedrive/config
dot add .config/onedrive/sync_list

# .config/code-flags.conf

dot commit -m "$COMMIT_MSG"
dot push origin main
