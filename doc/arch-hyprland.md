# Arch Linux and Hyprland

<!-- markdownlint-disable -->

<!-- toc -->

- [Setup Arch Linux + Hyprland](#setup-arch-linux--hyprland)
- [System Upgrade Issue](#system-upgrade-issue)
- [System Cleaning](#system-cleaning)
- [Note](#note)
- [Zsh](#zsh)
- [Clipboard Manager](#clipboard-manager)
- [Fcitx5 (Chinese Input)](#fcitx5-chinese-input)
    * [Setup](#setup)
    * [Enable Fcitx5 for Some Apps](#enable-fcitx5-for-some-apps)
- [Remote Desktop using VNC (wayvnc)](#remote-desktop-using-vnc-wayvnc)
- [Useful CLI Tools](#useful-cli-tools)

<!-- tocstop -->

<!-- markdownlint-enable -->

## Setup Arch Linux + Hyprland

> **Full installation walkthrough:** follow
> [JaKooLit/Arch-Hyprland](https://github.com/JaKooLit/Arch-Hyprland) for an
> automated installer, or refer to
> [this step-by-step guide](https://zhuanlan.zhihu.com/p/138951848) for a manual
> setup covering partitioning, base system, GPU drivers, and Hyprland.

Key points for a dual-boot setup alongside Windows:

- Reuse the existing Windows **EFI partition** for the Arch bootloader.
- Allocate a dedicated partition for Arch root (`/`).
- Use a **swap file** instead of a swap partition.
- When writing the ISO with [Rufus](https://rufus.ie), choose **DD** write mode
  and **GPT** partition scheme.

## System Upgrade Issue

error: libngtcp2: signature from "..." is unknown trust
[archlinux-keyring](https://wiki.archlinux.org/title/Pacman/Package_signing#Upgrade_system_regularly)

linux-firmware >= 20250613.12fe085f-5 upgrade requires manual intervention
[linux-firmware](https://archlinux.org/news/linux-firmware-2025061312fe085f-5-upgrade-requires-manual-intervention/)

## System Cleaning

```bash
# pacman pkg
sudo paccache -r

# pacman + yay pkg
yay -Sc

# system journal log
journalctl --vacuum-time=2weeks
```

## Note

1. Electron based apps have screen share issue

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

## Clipboard Manager

Using [`cliphist`](https://wiki.hyprland.org/Useful-Utilities/Clipboard-Managers/)
as clipboard manager.

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

## Remote Desktop using VNC (wayvnc)

- [wayvnc](https://github.com/any1/wayvnc)

1. Install `wayvnc` from AUR

   ```bash
   yay -S wayvnc
   ```

2. Encryption & Authentication (RSA-AES)

   ```bash
   mkdir ~/.config/wayvnc

   ssh-keygen -m pem -f ~/.config/wayvnc/rsa_key.pem -t rsa -N ""

   nvim ~/.config/wayvnc/config
   ```

3. Setting parameters

   ```conf
   use_relative_paths=true
   address=0.0.0.0
   enable_auth=true
   username=user
   password=****
   rsa_private_key_file=rsa_key.pem
   ```

4. Finally, setting autostart

   ```conf
   exec-once = wayvnc 127.0.0.1 5900 &
   ```

5. Now we can access hyprland using vnc viewer

## Useful CLI Tools

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
