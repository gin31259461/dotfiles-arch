# Hyprland Config

Personal Hyprland configuration. Themed around [noctalia-shell](https://github.com/nickcoutsos/noctalia-shell) with Material Design colors via noctalia.

## Structure

```
~/.config/hypr/
├── conf.d/                  # Modular config (loaded by hyprland.conf)
│   ├── animations.conf      # Animation presets (managed by scripts/display/animations.sh)
│   ├── appearance.conf      # Decoration, blur, shadow, rounding
│   ├── autostart.conf       # Exec-once entries
│   ├── env.conf             # Environment variables
│   ├── input.conf           # Keyboard, touchpad, mouse settings
│   ├── keybinds.conf        # All keybindings
│   ├── laptops.conf         # Laptop-specific overrides (ASUS ROG)
│   ├── layout.conf          # Dwindle / Master layout settings
│   ├── misc.conf            # Misc Hyprland options
│   └── window-rules.conf    # Window rules and workspace assignments
│
├── scripts/                 # Shell scripts by category
│   ├── display/             # Themes, blur, brightness, animations, monitor profiles
│   ├── input/               # Keyboard layout, keybind search, key hints
│   ├── media/               # Volume, sounds, media controls, music player
│   ├── rofi/                # Rofi-based menus (launcher, emoji, search, settings)
│   ├── services/            # Background services (polkit, portal, hypridle, weather)
│   └── session/             # Session management (lock, logout, game mode, screenshots)
│
├── monitor-profiles/        # Monitor config presets (switch via SUPER SHIFT E)
├── wallpaper-effects/       # Wallpaper cache for hyprlock (.wallpaper_current / _modified)
├── wallust/                 # Wallust color theme integration
├── monitors.conf            # Active monitor config (symlinked from monitor-profiles/)
├── workspaces.conf          # Workspace rules
├── hyprlock.conf            # Lock screen config
├── hypridle.conf            # Idle / auto-lock config
└── initial-boot.sh          # First-login setup script
```

## Theming

Colors are driven by **noctalia** (Material Design). Two workflows:

| Trigger | What happens |
|---|---|
| Change theme in noctalia UI | Run `SUPER SHIFT T` to sync colors to rofi, noctalia-shell, and wallpaper-effects |
| Change wallpaper in noctalia | Colors auto-update via wallust on next wallpaper change |

Color targets: `~/.config/rofi/wallust/colors-rofi.rasi`, `~/.config/quickshell/qml_color.json`, `wallpaper-effects/`

## Key Keybinds

| Key | Action |
|---|---|
| `SUPER D` | Application launcher |
| `SUPER Return` | Terminal |
| `SUPER SHIFT Return` | Dropdown terminal |
| `SUPER H` | This cheat sheet |
| `SUPER SHIFT K` | Search all keybinds |
| `SUPER SHIFT E` | Quick settings menu |
| `SUPER T` | Global theme switcher |
| `SUPER SHIFT T` | Apply noctalia Material Design colors |
| `SUPER S` | Web search |
| `SUPER ALT V` | Clipboard manager |
| `SUPER Print` | Screenshot |
| `CTRL ALT L` | Session menu (lock / logout) |

Full list: `SUPER H` or `SUPER SHIFT K`

## Monitor Profiles

Add `.conf` files to `monitor-profiles/` — one profile per file (e.g. `home.conf`, `office.conf`).
Switch profiles via `SUPER SHIFT E → Monitor Profiles`. The active profile is written to `monitors.conf`.

Tip: generate a profile with `nwg-displays`, then copy `monitors.conf` into `monitor-profiles/` with a descriptive name.

