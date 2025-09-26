cd $HOME

alias dot='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# self and github files
dot add README.md dotfiles.sh .gitconfig .gitmodules

# zsh
dot add .zshrc .zprofile .p10k.zsh

# gtk
dot add .icons .config/gtk-3.0
dot add .config/hypr/UserConfigs .config/hypr/UserScripts

# configs
dot add .config/nvim
dot add .config/kitty
dot add .config/electron-flags.conf
# .config/code-flags.conf

dot commit -m "Sync dotfiles"
dot push origin main
