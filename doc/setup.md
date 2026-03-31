# Hyprland Post-Install Setup

Configuration steps after a fresh Hyprland installation.

<!-- markdownlint-disable -->
<!-- toc -->

- [Zsh](#zsh)
- [Clipboard Manager](#clipboard-manager)
- [Fcitx5 (Chinese Input)](#fcitx5-chinese-input)
  - [Install](#install)
  - [Enable for Electron and VS Code](#enable-for-electron-and-vs-code)
- [Remote Desktop (wayvnc)](#remote-desktop-wayvnc)
- [Useful CLI Tools](#useful-cli-tools)

<!-- tocstop -->
<!-- markdownlint-enable -->

## Zsh

Uses **Oh My Zsh** + **Powerlevel10k** (Oh My Zsh is pre-configured by the
JaKooLit installer).

1. Install Powerlevel10k theme and plugins:

   ```bash
   git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
     ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

   git clone https://github.com/zsh-users/zsh-autosuggestions \
     ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions

   git clone https://github.com/zsh-users/zsh-syntax-highlighting \
     ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
   ```

2. Set the theme in `~/.zshrc`:

   ```bash
   ZSH_THEME="powerlevel10k/powerlevel10k"
   ```

3. Run the interactive prompt configurator:

   ```bash
   p10k configure
   ```

## Clipboard Manager

Uses [`cliphist`](https://wiki.hyprland.org/Useful-Utilities/Clipboard-Managers/).

Add to `~/.config/hypr/hyprland.conf`:

```conf
# Store clipboard history
exec-once = wl-paste --type text --watch cliphist store
exec-once = wl-paste --type image --watch cliphist store

# Open clipboard picker with Super+V
bind = SUPER, V, exec, cliphist list | rofi -dmenu | cliphist decode | wl-copy
```

## Fcitx5 (Chinese Input)

### Install

```bash
paru -S fcitx5-im fcitx5-chewing
```

Add to `~/.config/hypr/hyprland.conf`:

```conf
exec-once = fcitx5 &

env = QT_IM_MODULE,fcitx
env = XMODIFIERS,@im=fcitx
env = GLFW_IM_MODULE,fcitx
env = INPUT_METHOD,fcitx
env = IMSETTINGS_MODULE,fcitx
env = SDL_IM_MODULE,fcitx
# env = GTK_IM_MODULE,fcitx   # enable only if GTK apps need it
```

### Enable for Electron and VS Code

Some apps require an explicit flag to use Wayland IME.

**`~/.config/electron-flags.conf`** (applies to all Electron apps):

```conf
--enable-wayland-ime
```

**`~/.config/code-flags.conf`** (VS Code):

```conf
--enable-wayland-ime
```

## Remote Desktop (wayvnc)

[wayvnc](https://github.com/any1/wayvnc) provides VNC access to a running
Hyprland session.

1. Install from AUR:

   ```bash
   yay -S wayvnc
   ```

2. Generate an RSA key for encrypted auth:

   ```bash
   mkdir ~/.config/wayvnc
   ssh-keygen -m pem -f ~/.config/wayvnc/rsa_key.pem -t rsa -N ""
   ```

3. Create `~/.config/wayvnc/config`:

   ```conf
   use_relative_paths=true
   address=0.0.0.0
   enable_auth=true
   username=<your-username>
   password=<your-password>
   rsa_private_key_file=rsa_key.pem
   ```

4. Autostart in `~/.config/hypr/hyprland.conf`:

   ```conf
   exec-once = wayvnc 127.0.0.1 5900 &
   ```

## Useful CLI Tools

References:

- [josean-dev/dev-environment-files](https://github.com/josean-dev/dev-environment-files)
- [7 Amazing CLI Tools You Need To Try](https://www.youtube.com/watch?v=mmqDYw9C30I)

| Tool | Description |
|------|-------------|
| [fzf](https://github.com/junegunn/fzf) | Fuzzy finder |
| [fzf-git](https://github.com/junegunn/fzf-git.sh) | fzf bindings for git |
| [fd](https://github.com/sharkdp/fd) | Fast `find` replacement |
| [bat](https://github.com/sharkdp/bat) | `cat` with syntax highlighting |
| [delta](https://github.com/dandavison/delta) | Syntax-highlighting pager for git diffs |
| [eza](https://github.com/eza-community/eza) | Modern `ls` replacement |
| [tldr](https://github.com/tldr-pages/tldr) | Simplified man pages |
| [thefuck](https://github.com/nvbn/thefuck) | Corrects previous console commands |
