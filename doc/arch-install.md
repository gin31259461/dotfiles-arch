# Arch Linux Installation (Dual-Boot)

Step-by-step guide for installing Arch Linux alongside Windows on a UEFI system.

> **Reference:** [2021 Archlinux双系统安装教程（超详细）](https://zhuanlan.zhihu.com/p/138951848)

**Prerequisites**

- UEFI boot mode (not legacy BIOS)
- Dual-boot alongside Windows — reuse the existing Windows EFI partition
- One dedicated partition for Arch root (`/`)
- Swap file instead of a swap partition

<!-- markdownlint-disable -->
<!-- toc -->

- [0. Download ISO](#0-download-iso)
- [1. Disk Partitioning](#1-disk-partitioning)
- [2. Create Bootable USB](#2-create-bootable-usb)
- [3. BIOS Settings](#3-bios-settings)
- [4. Check Network](#4-check-network)
- [5. Set Mirrors](#5-set-mirrors)
- [6. Disk Setup](#6-disk-setup)
- [7. Install Base System](#7-install-base-system)
- [8. Generate fstab](#8-generate-fstab)
- [9. Configure New System](#9-configure-new-system)
- [10. Exit and Reboot](#10-exit-and-reboot)
- [11. Activate Network](#11-activate-network)
- [12. Create User](#12-create-user)
- [13. Install GPU Drivers](#13-install-gpu-drivers)
- [14. Add archlinuxcn Repository](#14-add-archlinuxcn-repository)
- [15. Install Hyprland](#15-install-hyprland)

<!-- tocstop -->
<!-- markdownlint-enable -->

## 0. Download ISO

Get the latest ISO from [archlinux.org/download](https://archlinux.org/download/).
Use a mirror close to you (e.g. Tsinghua, BFSU, NetEase).

## 1. Disk Partitioning

Use **Windows Disk Management** to shrink an existing volume and leave unallocated
free space for Arch.

Recommended layout:

| Mount  | Filesystem | Notes |
|--------|------------|-------|
| `/boot` | FAT32 | Reuse existing Windows EFI partition |
| `/`    | ext4       | New partition from free space (e.g. 250 GB) |
| swap   | —          | Swap file on `/`, not a separate partition |

> If the Windows EFI partition is only 100 MB, consider expanding it with a
> partition tool (e.g. 傲梅分區助手 in WinPE) before proceeding.

## 2. Create Bootable USB

Use [Rufus](https://rufus.ie):

- Write mode: **DD** (not ISO)
- Partition scheme: **GPT** (not MBR)

## 3. BIOS Settings

Reboot into BIOS (e.g. **F12** on Dell) with the USB plugged in:

1. Disable **Secure Boot**
2. If the target disk is NVMe, set the disk mode to **AHCI**
3. Move the USB drive to the **top** of the boot order

Save, exit, and boot into the Arch ISO.

## 4. Check Network

```bash
ip a
```

**Wired:** should be connected automatically.

**Wireless:** use `iwctl`:

```bash
iwctl
device list                       # note interface name, e.g. wlan0
station wlan0 scan
station wlan0 get-networks
station wlan0 connect <SSID>      # enter password when prompted
exit
```

Verify connectivity:

```bash
pacman -Syyy
```

## 5. Set Mirrors

```bash
nano /etc/pacman.d/mirrorlist
```

Press `Ctrl-W`, search `## China`, cut (`Ctrl-K`) a few nearby mirrors (Tsinghua,
BFSU, NetEase) and paste (`Ctrl-U`) them at the top of the file. Remove the
leading `#`. Save with `Ctrl-X → Y → Enter`.

## 6. Disk Setup

**Check current layout:**

```bash
lsblk
```

**Create the root partition** from the unallocated free space:

```bash
cfdisk /dev/nvme0n1   # adjust device name to match your disk
```

Select **New → Enter size (e.g. 250G) → Write → yes → Quit**.

**Format the new partition:**

```bash
mkfs.ext4 /dev/nvme0n1p5   # adjust partition number as shown by lsblk
```

**Mount the partitions:**

```bash
mount /dev/nvme0n1p5 /mnt          # root partition

mkdir /mnt/boot
mount /dev/nvme0n1p2 /mnt/boot     # Windows EFI partition
```

## 7. Install Base System

```bash
pacstrap /mnt base linux linux-firmware nano
```

> Alternative kernels: `linux-lts`, `linux-zen`, `linux-hardened`.

## 8. Generate fstab

```bash
genfstab -U /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab    # verify the output looks correct
```

## 9. Configure New System

Chroot into the new system:

```bash
arch-chroot /mnt
```

**Swap file** (use `dd`, not `fallocate`, to avoid ext4 holes bug):

```bash
dd if=/dev/zero of=/swapfile bs=2048 count=1048576 status=progress
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap defaults 0 0' >> /etc/fstab
```

**Timezone:**

```bash
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
hwclock --systohc
```

**Locale:**

```bash
nano /etc/locale.gen
# Uncomment: en_US.UTF-8 UTF-8  and  zh_CN.UTF-8 UTF-8
locale-gen
echo 'LANG=en_US.UTF-8' > /etc/locale.conf
```

**Hostname:**

```bash
echo 'arch' > /etc/hostname
```

**`/etc/hosts`:**

```
127.0.0.1   localhost
::1         localhost
127.0.1.1   arch.localdomain   arch
```

**Root password:**

```bash
passwd
```

**Bootloader (GRUB):**

Install required packages:

```bash
pacman -S grub efibootmgr networkmanager network-manager-applet dialog \
  wireless_tools wpa_supplicant os-prober mtools dosfstools ntfs-3g \
  base-devel linux-headers reflector git sudo
```

Install CPU microcode:

```bash
pacman -S intel-ucode   # Intel CPU
# pacman -S amd-ucode   # AMD CPU
```

Enable `os-prober` so GRUB detects Windows:

```bash
nano /etc/default/grub
# Add or uncomment:
# GRUB_DISABLE_OS_PROBER=false
```

Install and generate GRUB config:

```bash
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=Arch
grub-mkconfig -o /boot/grub/grub.cfg
```

## 10. Exit and Reboot

```bash
exit
umount -a
reboot    # remove the USB drive when the screen goes blank
```

## 11. Activate Network

Log in as `root`, then:

```bash
systemctl enable --now NetworkManager
nmtui    # connect to Wi-Fi if needed
```

## 12. Create User

```bash
useradd -m -G wheel <username>
passwd <username>
EDITOR=nano visudo
# Uncomment: %wheel ALL=(ALL:ALL) ALL
```

## 13. Install GPU Drivers

```bash
# Intel integrated (modesetting via mesa — xf86-video-intel not needed)
pacman -S mesa

# AMD integrated / discrete
pacman -S xf86-video-amdgpu

# NVIDIA discrete
pacman -S nvidia nvidia-utils

# NVIDIA Optimus (switch between iGPU and dGPU)
# sudo pacman -S optimus-manager
```

> **AMD users:** after booting into the installed system, follow the
> [AMD GPU Setup](amd-gpu.md) guide to verify drivers, enable Vulkan, configure
> VA-API hardware acceleration, and set Hyprland environment variables.

## 14. Add archlinuxcn Repository

```bash
nano /etc/pacman.conf
```

Append at the end:

```ini
[archlinuxcn]
Server = https://mirrors.bfsu.edu.cn/archlinuxcn/$arch
```

Also uncomment the `[multilib]` section. Then:

```bash
pacman -Syu && pacman -S archlinuxcn-keyring
```

Install Chinese fonts:

```bash
pacman -S noto-fonts-cjk ttf-sarasa-gothic
```

## 15. Install Hyprland

Use [JaKooLit/Arch-Hyprland](https://github.com/JaKooLit/Arch-Hyprland) for an
automated Hyprland installer (includes dotfiles, Wayland components, and optional
extras):

```bash
git clone https://github.com/JaKooLit/Arch-Hyprland.git ~/Arch-Hyprland
cd ~/Arch-Hyprland
chmod +x install.sh
./install.sh
```
