# Create Arch Linux Live USB

How to download the Arch Linux ISO, verify it, and write it to a USB drive on
Windows or Linux.

**Requirements**

- A USB drive ≥ 2 GB (all data will be erased)
- A machine with internet access

<!-- markdownlint-disable -->
<!-- toc -->

- [1. Download the ISO](#1-download-the-iso)
- [2. Verify the ISO](#2-verify-the-iso)
- [3. Write to USB — Windows (Rufus)](#3-write-to-usb--windows-rufus)
- [4. Write to USB — Linux (dd)](#4-write-to-usb--linux-dd)
- [Alternative: Ventoy (multi-boot USB)](#alternative-ventoy-multi-boot-usb)

<!-- tocstop -->
<!-- markdownlint-enable -->

## 1. Download the ISO

Get the latest ISO from [archlinux.org/download](https://archlinux.org/download/).
Pick a mirror geographically close to you for faster speeds (e.g. Tsinghua,
BFSU, or NetEase for China).

The download page also provides a **Torrent** and **Magnet link** — these are
the fastest options if you have a torrent client.

## 2. Verify the ISO

Verifying the ISO guards against a corrupted or tampered download.

**On Windows** (PowerShell):

```powershell
Get-FileHash archlinux-x86_64.iso -Algorithm SHA256
```

Compare the output against the `sha256sums.txt` file on the download page.

**On Linux:**

```bash
sha256sum archlinux-x86_64.iso
```

Or use the PGP signature for a stronger check:

```bash
gpg --auto-key-retrieve --verify archlinux-x86_64.iso.sig archlinux-x86_64.iso
```

A valid result shows `Good signature from "Pierre Schmitz <pierre@archlinux.org>"`
(or the current release signer). Ignore the "trust" warning if the key is not
in your local keyring.

## 3. Write to USB — Windows (Rufus)

1. Download [Rufus](https://rufus.ie) and open it.
2. Select your USB drive under **Device**.
3. Click **SELECT** and choose the Arch ISO.
4. Set the following options:
   - **Partition scheme:** GPT
   - **Target system:** UEFI (non-CSM)
   - **Write mode:** when prompted, choose **DD Image** (not ISO Image)
5. Click **START** → **OK** to confirm the drive will be wiped.

> Using **ISO Image** mode may produce a non-bootable drive. Always choose
> **DD Image** for Arch Linux.

## 4. Write to USB — Linux (dd)

**Identify your USB drive** (do not confuse it with your system disk):

```bash
lsblk
```

**Write the ISO** (replace `/dev/sdX` with your actual USB device — e.g. `/dev/sdb`):

```bash
sudo dd bs=4M if=archlinux-x86_64.iso of=/dev/sdX conv=fsync oflag=direct status=progress
```

Wait for `dd` to finish and return to the prompt before unplugging the drive.

> ⚠️ Double-check the target device. Writing to the wrong disk will destroy data.

## Alternative: Ventoy (multi-boot USB)

[Ventoy](https://www.ventoy.net) lets you store multiple ISOs on a single USB
drive and boot any of them from a menu — no re-flashing needed.

**Install Ventoy onto the USB (Linux):**

```bash
# Download the latest release from https://github.com/ventoy/Ventoy/releases
tar -xf ventoy-*.tar.gz
cd ventoy-*
sudo ./Ventoy2Disk.sh -i /dev/sdX   # -i installs; -u updates
```

**Install Ventoy onto the USB (Windows):**

Run `Ventoy2Disk.exe` from the extracted archive and select your USB drive.

Once installed, copy any `.iso` file directly onto the USB's data partition.
Ventoy detects and lists them automatically at boot.
