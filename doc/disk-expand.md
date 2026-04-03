# Expand an Arch Linux Partition (Online)

How to grow a root partition while the system is running — no Live USB required.
This works because `parted`/`cfdisk` can modify partition tables without
unmounting, and ext4, Btrfs, and XFS all support online filesystem grow.

<!-- markdownlint-disable -->
<!-- toc -->

- [Prerequisites](#prerequisites)
- [0. Check Current Layout](#0-check-current-layout)
- [1. Resize the Partition](#1-resize-the-partition)
  - [Option A — Delete partitions behind the Arch root to claim more space](#option-a--delete-partitions-behind-the-arch-root-to-claim-more-space)
  - [Option B — Extend into adjacent unallocated space only](#option-b--extend-into-adjacent-unallocated-space-only)
- [2. Refresh the Kernel Partition Table](#2-refresh-the-kernel-partition-table)
- [3. Expand the Filesystem](#3-expand-the-filesystem)
- [4. Verify the Result](#4-verify-the-result)

<!-- tocstop -->
<!-- markdownlint-enable -->

## Prerequisites

- The free space (or partitions you plan to delete) must be located **after**
  the target Arch partition on the same disk — `lsblk` will confirm this.
- The target filesystem must support online grow: **ext4**, **Btrfs**, or **XFS**
  (use `lsblk -f` to check which one you have).
- You do **not** need to unmount the partition or boot from a Live USB.

**Choose a strategy before starting:**

| Option | When to use |
|--------|-------------|
| **A** | Unwanted partitions (e.g. Windows recovery partitions) sit between the Arch root and free space — delete them to claim a larger block |
| **B** | Only a small block of unallocated space sits directly after the Arch partition — extend into it without touching anything else |

## 0. Check Current Layout

```bash
lsblk -f
```

Confirm:
- The device name of your disk (e.g. `/dev/nvme0n1`)
- The partition number of your Arch root (e.g. `p6`)
- The filesystem type is `ext4`, `btrfs`, or `xfs`
- What sits between the Arch partition and the end of the disk

```bash
sudo parted /dev/nvme0n1 print free
```

The `print free` output shows unallocated gaps between partitions, which helps
you decide which option to use.

## 1. Resize the Partition

### Option A — Delete partitions behind the Arch root to claim more space

Open `parted` interactively (adjust device name as needed):

```bash
sudo parted /dev/nvme0n1
```

```text
(parted) print           # confirm partition numbers before deleting anything
(parted) rm 4            # delete unwanted partition (e.g. a recovery partition)
(parted) rm 5            # delete another if present
(parted) resizepart 6    # extend the Arch root partition (adjust number)
Warning: Partition /dev/nvme0n1p6 is being used. Are you sure you want to continue?
Yes/No? yes
End? [250GB]? 100%       # [250GB] is parted showing the current end — type 100% to use all free space
(parted) quit
```

> ⚠️ Deleting Windows recovery partitions permanently disables factory restore.
> Only do this if you no longer need Windows or its OEM recovery tools.

### Option B — Extend into adjacent unallocated space only

Use `parted` the same way as Option A, just skip the `rm` commands:

```bash
sudo parted /dev/nvme0n1
```

```text
(parted) print           # confirm the partition number and available free space
(parted) resizepart 6    # extend the Arch root partition (adjust number)
Warning: Partition /dev/nvme0n1p6 is being used. Are you sure you want to continue?
Yes/No? yes
End? [250GB]? 100%       # [250GB] is parted showing the current end — type 100% to use all free space
(parted) quit
```

> Alternatively, `cfdisk` provides a more visual interface for this:
> `sudo cfdisk /dev/nvme0n1` → select the partition → **[ Resize ]** → Enter →
> **[ Write ]** → `yes` → **[ Quit ]**.

## 2. Refresh the Kernel Partition Table

Tell the kernel to re-read the updated partition boundaries:

```bash
sudo partprobe /dev/nvme0n1
sudo udevadm settle
```

> If `partprobe` reports that the partition is still busy, a **reboot** is
> required before proceeding. After rebooting, skip directly to step 3.

## 3. Expand the Filesystem

The partition boundary has moved, but the filesystem still occupies its old
size. Use the command matching your filesystem type (check with `lsblk -f`):

**ext4:**

```bash
sudo resize2fs /dev/nvme0n1p6
```

Example output:

```text
resize2fs 1.47.0
Filesystem at /dev/nvme0n1p6 is mounted on /; on-line resizing required
old_desc_blocks = 4, new_desc_blocks = 18
The filesystem on /dev/nvme0n1p6 is now 36700160 (4k) blocks long.
```

**Btrfs:**

```bash
sudo btrfs filesystem resize max /
```

**XFS** (grow only — XFS cannot shrink):

```bash
sudo xfs_growfs /
```

All three commands are safe to run on a live, mounted filesystem.

## 4. Verify the Result

```bash
df -hT /
lsblk -f /dev/nvme0n1
```

The `df` output should show the increased `Size` and `Avail` for the root
filesystem. `lsblk` confirms the new partition size matches expectations.

