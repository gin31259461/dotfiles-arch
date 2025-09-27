# Arch Linux + Hyprland Dotfiles

This config is using
[JaKooLit's Arch-Hyprland](https://github.com/JaKooLit/Arch-Hyprland)

<!-- markdownlint-disable -->

<!-- toc -->

- [First Time Setup](#first-time-setup)
- [Setting up a new machine](#setting-up-a-new-machine)
- [References](#references)

<!-- tocstop -->

<!-- markdownlint-enable -->

## First Time Setup

1. create bare repository

   ```bash
   mkdir $HOME/.dotfiles

   git init --bare $HOME/.dotfiles
   ```

2. make an alias for runing git commands (to .bashrc or .zshrc)

   ```bash
   alias dot='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
   ```

3. add a remote, and also set status not to show untracked files

   ```bash
   dot config --local status.showUntrackedFiles no

   dot remote add origin <repo>

   dot branch -m main
   ```

4. run `dotfiles.sh` to sync dotfiles automatically

## Setting up a new machine

```bash
git clone --separate-git-dir=$HOME/.dotfiles \
  git@github.com:gin31259461/arch-dotfiles.git tmpdotfiles

rsync --recursive --verbose --exclude '.git' tmpdotfiles/ $HOME/

rm -rf tmpdotfiles

# after restart terminal
dot config --local status.showUntrackedFiles no
```

## References

- [A simpler way to manage your dotfiles](https://www.anand-iyer.com/blog/2018/a-simpler-way-to-manage-your-dotfiles/)
