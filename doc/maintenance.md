# System Maintenance

<!-- markdownlint-disable -->
<!-- toc -->

- [System Cleaning](#system-cleaning)
- [Known Upgrade Issues](#known-upgrade-issues)
- [Notes](#notes)

<!-- tocstop -->
<!-- markdownlint-enable -->

## System Cleaning

Use the interactive cleanup script for a guided experience:

```bash
~/.local/bin/cleanup.sh
```

It presents a fzf multi-select menu (falls back to numbered list) with current
disk usage per task, then confirms before making any changes.

| Task | What it cleans |
|------|----------------|
| `pacman-cache` | `/var/cache/pacman/pkg` — keeps last 3 versions (`paccache -r`) |
| `yay-cache` | `~/.cache/yay` — AUR build dirs and downloaded tarballs |
| `orphans` | Packages no longer required by any dependency (`pacman -Rns`) |
| `journal` | Systemd journal logs older than 2 weeks |
| `npm-cache` | `~/.npm` — global npm package cache |
| `thumbnails` | `~/.cache/thumbnails` — safe, rebuilds on demand |

Run non-interactively (skips confirmations) with `--yes`:

```bash
~/.local/bin/cleanup.sh --yes
```

### Manual commands

```bash
# Remove old cached pacman packages (keep last 3 versions)
sudo paccache -r

# Remove orphaned packages
sudo pacman -Rns $(pacman -Qdtq)

# Truncate system journal logs older than 2 weeks
sudo journalctl --vacuum-time=2weeks
```

## Known Upgrade Issues

| Error | Fix |
|-------|-----|
| `signature from "..." is unknown trust` during upgrade | Refresh keyring: see [archlinux-keyring](https://wiki.archlinux.org/title/Pacman/Package_signing#Upgrade_system_regularly) |
| `linux-firmware >= 20250613.12fe085f-5` upgrade fails | Requires manual intervention: see [announcement](https://archlinux.org/news/linux-firmware-2025061312fe085f-5-upgrade-requires-manual-intervention/) |

## Notes

- **Electron apps (e.g. Discord, VS Code)** cannot share screens under Hyprland
  by default. Use a Wayland-aware screen share portal or check app-specific flags.
