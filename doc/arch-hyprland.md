# Arch Linux

## Zsh

Oh My Zsh + Powerlevel10k

After installed JaKooLit's Arch-Hyprland (include oh my zsh setting)

1. install powerlevel10k theme and zsh plugin

   ```bash
   git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
   git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

   git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
   ```

2. configure `.zshrc`

   ```bash
   ZSH_THEME="powerlevel10k/powerlevel10k"
   ```

3. configure p10k

   ```bash
   p10k configure
   ```

## [Clipboard manager](https://wiki.hyprland.org/Useful-Utilities/Clipboard-Managers/)

Using `cliphist` as clipboard manager.

Start by adding the following lines to hyprland config

```conf
exec-once = wl-paste --type text --watch cliphist store # Stores only text data
exec-once = wl-paste --type image --watch cliphist store # Stores only image data
```

To bind `cliphist` to a hotkey for rofi

```conf
bind = SUPER, V, exec, cliphist list | rofi -dmenu | cliphist decode | wl-copy
```

## Fcitx5 (Chinese Input)

### Setup

Run following command to install necessary packages.

```bash
paru -S fcitx5-im fcitx5-chewing
```

Using hyprland to autostart fcitx5 on startup.

```conf
exec-once = fcitx5 &
```

Adding the following setting to hyprland environment to enable fcitx5 be able to
use.

```conf
# env = GTK_IM_MODULE,fcitx
env = QT_IM_MODULE,fcitx
env = XMODIFIERS,@im=fcitx
env = GLFW_IM_MODULE,fcitx
env = INPUT_METHOD,fcitx
env = IMSETTINGS_MODULE,fcitx
env = SDL_IM_MODULE,fcitx
```

### Enable Fcitx5 for Some Apps

To enable fcitx5 used in third party apps, such as electron based apps, we need
to add flags.

- `Electron`

Adding flags to **~/.config/electron-flags.conf**

```conf
--enable-wayland-ime
```

- `Visual Studio Code`

Adding flags to **~/.config/code-flags.conf**

```conf
--enable-wayland-ime
```

## Useful CLI tools

refer to:

1. [josean-dev/dev-environment-files](https://github.com/josean-dev/dev-environment-files)
2. [7 Amazing CLI Tools You Need To Try](https://www.youtube.com/watch?v=mmqDYw9C30I&list=PLnu5gT9QrFg36OehOdECFvxFFeMHhb_07&index=13&t=92s)

- [fzf](https://github.com/junegunn/fzf.git)
- [fd](https://github.com/sharkdp/fd)
- [fzf-git](https://github.com/junegunn/fzf-git.sh)
- [bat](https://github.com/sharkdp/bat)
- [delta](https://github.com/dandavison/delta)
- [eza](https://github.com/eza-community/eza.git)
- [tldr](https://github.com/tldr-pages/tldr)
- [thefuck](https://github.com/nvbn/thefuck)
