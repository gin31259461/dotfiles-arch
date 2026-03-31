# System Maintenance

<!-- markdownlint-disable -->
<!-- toc -->

- [System Cleaning](#system-cleaning)
- [Known Upgrade Issues](#known-upgrade-issues)
- [Notes](#notes)

<!-- tocstop -->
<!-- markdownlint-enable -->

## System Cleaning

```bash
# Remove old cached pacman packages (keep last 3 versions)
sudo paccache -r

# Clean pacman + AUR (yay) cache
yay -Sc

# Truncate system journal logs older than 2 weeks
journalctl --vacuum-time=2weeks
```

## Known Upgrade Issues

| Error | Fix |
|-------|-----|
| `signature from "..." is unknown trust` during upgrade | Refresh keyring: see [archlinux-keyring](https://wiki.archlinux.org/title/Pacman/Package_signing#Upgrade_system_regularly) |
| `linux-firmware >= 20250613.12fe085f-5` upgrade fails | Requires manual intervention: see [announcement](https://archlinux.org/news/linux-firmware-2025061312fe085f-5-upgrade-requires-manual-intervention/) |

## Notes

- **Electron apps (e.g. Discord, VS Code)** cannot share screens under Hyprland
  by default. Use a Wayland-aware screen share portal or check app-specific flags.
