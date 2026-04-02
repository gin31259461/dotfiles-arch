# Arch Linux Disk Migration

Guide for migrating an existing Arch Linux installation to a new drive using a
Live USB and `rsync`. Useful when replacing an old disk or moving to a larger one.

**Prerequisites**

- Booted into a recent Arch Linux Live USB
- Both the old and new drives connected to the machine

<!-- markdownlint-disable -->
<!-- toc -->

- [1. Identify Disks and Partition the New Drive](#1-identify-disks-and-partition-the-new-drive)
- [2. Format and Mount](#2-format-and-mount)
- [3. Copy System Files](#3-copy-system-files)
- [4. Update System Configuration (chroot)](#4-update-system-configuration-chroot)
- [5. Unmount and Reboot](#5-unmount-and-reboot)

<!-- tocstop -->
<!-- markdownlint-enable -->

## 1. Identify Disks and Partition the New Drive

**Check current disk layout:**

```bash
lsblk
```

Identify the old disk (e.g. `/dev/nvme0n1`) and the new disk (e.g. `/dev/nvme1n1`).

**Partition the new disk with `cfdisk`:**

```bash
cfdisk /dev/nvme1n1
```

Recommended GPT layout:

| Partition | Type | Size |
|-----------|------|------|
| `nvme1n1p1` | EFI System | 512 MB – 1 GB |
| `nvme1n1p2` | Linux swap | Optional |
| `nvme1n1p3` | Linux filesystem | Remaining space (root) |

## 2. Format and Mount

**Format the new partitions:**

```bash
mkfs.fat -F 32 /dev/nvme1n1p1   # EFI
mkswap /dev/nvme1n1p2            # Swap (if created)
swapon /dev/nvme1n1p2
mkfs.ext4 /dev/nvme1n1p3         # Root (or mkfs.btrfs for Btrfs)
```

**Mount old and new disks:**

```bash
mkdir -p /mnt/old /mnt/new

mount /dev/nvme0n1p2 /mnt/old    # old root partition (adjust as needed)

mount /dev/nvme1n1p3 /mnt/new    # new root
mkdir -p /mnt/new/boot
mount /dev/nvme1n1p1 /mnt/new/boot
```

## 3. Copy System Files

Sync the old root to the new disk, excluding pseudo-filesystems and temporary paths:

```bash
rsync -avAXHP \
  --exclude={"/dev/*","/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","/lost+found"} \
  /mnt/old/ /mnt/new/
```

## 4. Update System Configuration (chroot)

**Regenerate fstab** with the new disk's UUIDs:

```bash
genfstab -U /mnt/new > /mnt/new/etc/fstab
```

Open the file and remove any leftover UUIDs from the old drive:

```bash
nano /mnt/new/etc/fstab
```

**Chroot into the new system:**

```bash
arch-chroot /mnt/new
```

**Rebuild initramfs:**

```bash
mkinitcpio -P
```

**Reinstall the bootloader:**

```bash
# GRUB
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
```

> For **systemd-boot**, run `bootctl install` and update the UUIDs in
> `/boot/loader/entries/`.

## 5. Unmount and Reboot

```bash
exit
umount -R /mnt/old
umount -R /mnt/new
reboot
```

After rebooting, verify the system boots from the new drive. Once confirmed, the
old drive can be reformatted or repurposed.
