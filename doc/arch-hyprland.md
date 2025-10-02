# Arch Linux and Hyprland

<!-- markdownlint-disable -->

<!-- toc -->

- [Setup Arch Linux + Hyprland](#setup-arch-linux--hyprland)
    * [0. Prepare ISO](#0-prepare-iso)
    * [1. Partition](#1-partition)
    * [2. Booting USB](#2-booting-usb)
    * [3. BIOS Setting](#3-bios-setting)
    * [4. Network](#4-network)
    * [5. Hard Disk](#5-hard-disk)
    * [6. Install Basic System](#6-install-basic-system)
    * [7. Generate fstab File](#7-generate-fstab-file)
    * [8. Setup New System](#8-setup-new-system)
    * [9. Exit New System and Unmount](#9-exit-new-system-and-unmount)
    * [10. Enter Arch System and Activate Network](#10-enter-arch-system-and-activate-network)
    * [11. Create New Account](#11-create-new-account)
    * [12. Install GPU Driver](#12-install-gpu-driver)
    * [13. Install Hyprland (Desktop Environment)](#13-install-hyprland-desktop-environment)
    * [14. Add archlinuxcn Source and System Upgrade](#14-add-archlinuxcn-source-and-system-upgrade)
- [System Upgrade Issue](#system-upgrade-issue)
- [System Cleaning](#system-cleaning)
- [Note](#note)
- [Zsh](#zsh)
- [Clipboard manager](#clipboard-manager)
- [Fcitx5 (Chinese Input)](#fcitx5-chinese-input)
    * [Setup](#setup)
    * [Enable Fcitx5 for Some Apps](#enable-fcitx5-for-some-apps)
- [Remote Desktop using VNC (wayvnc)](#remote-desktop-using-vnc-wayvnc)
- [Useful CLI tools](#useful-cli-tools)

<!-- tocstop -->

<!-- markdownlint-enable -->

## Setup Arch Linux + Hyprland

this instruction is refer to <https://zhuanlan.zhihu.com/p/138951848>

### 0. Prepare ISO

<https://archlinux.org/download/>

### 1. Partition

- Arch Linux 使用 Windows 的 EFI 分區
- 切一個分區給 Arch 目錄使用
- 用 `swap file` 取代 swap partition

### 2. Booting USB

use [Rufus](https://rufus.ie)

1. 寫入方式選擇 DD 非 ISO
1. 選項區域選擇 GPT 非 MBR

### 3. BIOS Setting

### 4. Network

### 5. Hard Disk

### 6. Install Basic System

### 7. Generate fstab File

### 8. Setup New System

### 9. Exit New System and Unmount

### 10. Enter Arch System and Activate Network

### 11. Create New Account

### 12. Install GPU Driver

### 13. Install Hyprland (Desktop Environment)

### 14. Add archlinuxcn Source and System Upgrade

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
