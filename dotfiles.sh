# this dotfile refer to: https://github.com/JaKooLit/Hyprland-Dots

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
dot add .config/electron-flags.conf
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

# .config/code-flags.conf

dot commit -m "sync dotfiles"
dot push origin main
