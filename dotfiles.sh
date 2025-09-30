cd $HOME

alias dot='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# git files
dot add README.md doc dotfiles.sh .gitconfig .gitmodules

# zsh
dot add .zshrc .zprofile .p10k.zsh

# gtk
dot add .icons .config/gtk-3.0

# configs
dot add .config/nvim
dot add .config/kitty
dot add .config/electron-flags.conf
dot add .config/hypr
dot add .config/waybar
# .config/code-flags.conf

dot commit -m "sync dotfiles"
dot push origin main
