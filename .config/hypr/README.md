# Hyprland Config

Personal Hyprland configuration. Themed around [noctalia-shell](https://github.com/noctalia-dev/noctalia-shell) with Material Design colors via noctalia.

## Structure

```
~/.config/hypr/
├── conf.d/                  # Modular config (loaded by hyprland.conf)
│   ├── animations.conf      # Animation presets (managed by scripts/display/animations.sh)
│   ├── appearance.conf      # Decoration, blur, shadow, rounding
│   ├── autostart.conf       # Exec-once entries
│   ├── env.conf             # Environment variables ($term, $files, $edit, etc.)
│   ├── input.conf           # Keyboard, touchpad, mouse settings
│   ├── keybinds.conf        # All keybindings
│   ├── laptops.conf         # Laptop-specific overrides (ASUS ROG)
│   ├── layout.conf          # Dwindle / Master layout settings
│   ├── misc.conf            # Misc Hyprland options
│   └── window-rules.conf    # Window rules and workspace assignments
│
├── scripts/
│   ├── display/
│   │   ├── animations.sh           # Animation preset picker (rofi)
│   │   ├── brightness.sh           # Brightness control
│   │   ├── brightness-kbd.sh       # Keyboard brightness control
│   │   ├── change-blur.sh          # Toggle blur
│   │   ├── dark-light.sh           # Dark/light theme toggle
│   │   ├── hyprsunset.sh           # Blue light filter
│   │   ├── kitty-themes.sh         # Kitty theme picker (rofi)
│   │   ├── monitor-profiles.sh     # Monitor profile switcher (rofi)
│   │   ├── noctalia-theme.sh       # Sync noctalia Material colors to rofi, quickshell, hyprlock
│   │   ├── theme-changer.sh        # Global wallust theme switcher (rofi)
│   │   ├── wallpaper-select.sh     # Wallpaper picker — images + videos (rofi + swww/mpvpaper)
│   │   ├── wallpaper-effects.sh    # ImageMagick wallpaper effects picker (rofi)
│   │   ├── wallpaper-random.sh     # Apply random wallpaper from wallDIR
│   │   ├── wallpaper-auto.sh       # Daemon: auto-cycle wallpapers every 30 min
│   │   ├── wallust-swww.sh         # Sync wallust colors after wallpaper change
│   │   ├── waybar-layout.sh        # Waybar layout picker (rofi)
│   │   ├── waybar-style.sh         # Waybar CSS style picker (rofi)
│   │   └── zsh-change-theme.sh     # oh-my-zsh theme picker (rofi)
│   │
│   ├── input/
│   │   ├── change-layout.sh        # Toggle Dwindle/Master layout
│   │   ├── key-hints.sh            # Keybind cheat sheet (yad)
│   │   ├── keyboard-layout.sh      # Global keyboard layout switch
│   │   ├── keybinds.sh             # Searchable keybinds (rofi)
│   │   ├── keybinds-layout-init.sh # Layout-aware keybinds initialiser
│   │   ├── keybinds-parser.py      # Keybind parser for rofi search
│   │   ├── tak0-autodispatch.sh    # Workspace auto-dispatcher
│   │   └── tak0-per-window-switch.sh # Per-window keyboard layout switch
│   │
│   ├── media/
│   │   ├── media-ctrl.sh           # Media player controls (play/pause/next/prev)
│   │   ├── rofi-beats.sh           # Online music player (mpv + rofi)
│   │   ├── sounds.sh               # UI sound effects
│   │   ├── volume.sh               # Volume control
│   │   └── waybar-cava.sh          # Cava bar-glyph streamer for waybar modules
│   │
│   ├── rofi/
│   │   ├── app-launcher.sh         # Rofi app launcher (drun + filebrowser + run + window)
│   │   ├── clip-manager.sh         # Clipboard manager (cliphist + rofi)
│   │   ├── quick-settings.sh       # Quick settings menu
│   │   ├── rofi-calc.sh            # Calculator (qalc + rofi)
│   │   ├── rofi-emoji.sh           # Emoji picker
│   │   ├── rofi-search.sh          # Web search
│   │   ├── rofi-theme-selector.sh  # Rofi theme picker
│   │   └── rofi-theme-selector-modified.sh
│   │
│   ├── services/
│   │   ├── battery.sh              # Battery status notifications
│   │   ├── distro-update.sh        # Package update notifier
│   │   ├── dropterminal.sh         # Dropdown terminal (scratchpad)
│   │   ├── hypridle.sh             # Hypridle daemon launcher
│   │   ├── polkit.sh               # Polkit agent launcher
│   │   ├── portal-hyprland.sh      # XDG desktop portal launcher
│   │   ├── refresh.sh              # Reload ags / qs / swaync / waybar
│   │   ├── refresh-theme.sh        # Reload theme targets after changes
│   │   ├── touchpad.sh             # Touchpad toggle
│   │   ├── waybar-scripts.sh       # Waybar click-handler (btop/nvtop/nmtui/files)
│   │   ├── weather.sh              # Weather fetch
│   │   ├── weather-wrap.sh         # Weather wrapper (used by lock screen)
│   │   └── weather.py              # Weather data formatter
│   │
│   └── session/
│       ├── airplane-mode.sh        # Airplane mode toggle
│       ├── game-mode.sh            # Game mode (disables animations)
│       ├── kill-active-process.sh  # Kill active window process
│       ├── lock-screen.sh          # Lock screen launcher
│       ├── overview-toggle.sh      # Desktop overview toggle
│       ├── screenshot.sh           # Screenshots (grim / slurp / swappy)
│       └── wlogout.sh              # Session menu (logout/lock/reboot/shutdown)
│
├── monitor-profiles/        # Monitor config presets
├── wallpaper-effects/       # Wallpaper cache for hyprlock
│   ├── .wallpaper_current   # Raw copy of active wallpaper
│   └── .wallpaper_modified  # Blurred + tinted version (used by hyprlock)
├── wallust/                 # Wallust color theme integration
├── animations/              # Animation preset files
├── monitors.conf            # Active monitor config
├── workspaces.conf          # Workspace rules
├── hyprlock.conf            # Lock screen config
├── hyprlock-2k.conf         # Lock screen config (2K variant)
├── hypridle.conf            # Idle / auto-lock config
└── initial-boot.sh          # First-login setup script
```

## Theming

Colors are driven by **noctalia** (Material Design). Two workflows:

| Trigger | What happens |
|---|---|
| Change wallpaper/theme in noctalia | Colors auto-update via wallust |
| `SUPER SHIFT T` | Manually sync noctalia colors to rofi, noctalia-shell, wallpaper-effects |

Color targets: `~/.config/rofi/wallust/colors-rofi.rasi`, `~/.config/quickshell/qml_color.json`, `wallpaper-effects/`

## Key Keybinds

| Key | Action |
|---|---|
| `SUPER D` | Application launcher |
| `SUPER Return` | Terminal |
| `SUPER SHIFT Return` | Dropdown terminal |
| `SUPER H` | Keybind cheat sheet |
| `SUPER SHIFT K` | Search all keybinds |
| `SUPER SHIFT E` | Quick settings menu |
| `SUPER T` | Global theme switcher |
| `SUPER SHIFT T` | Apply noctalia Material Design colors |
| `SUPER S` | Web search |
| `SUPER ALT V` | Clipboard manager |
| `SUPER Print` | Screenshot |
| `CTRL ALT L` | Session menu (lock / logout / reboot) |

Full list: `SUPER H` or `SUPER SHIFT K`

## Monitor Profiles

Add `.conf` files to `monitor-profiles/` — one profile per file (e.g. `home.conf`, `office.conf`).
Switch via `SUPER SHIFT E -> Monitor Profiles`. The active profile is written to `monitors.conf`.

Tip: generate a profile with `nwg-displays`, then copy `monitors.conf` into `monitor-profiles/` with a descriptive name.

## Rofi App Launcher (optional)

The default launcher is **noctalia-shell** (`SUPER D`). Rofi `drun` is available as a drop-in alternative — useful if noctalia-shell is not running or you prefer a classic rofi launcher.

**To enable:** in `conf.d/keybinds.conf`, comment out the noctalia-shell launcher line and uncomment the rofi alternative directly below it.

The launcher uses `~/.config/rofi/config.rasi` (inherits the active rofi theme). Change the theme with `SUPER CTRL R` or `SUPER CTRL SHIFT R`.

**Modes available:** `drun` (installed apps) · `filebrowser` · `run` (commands) · `window` (open windows)

## Wallpaper (optional)

Wallpaper management is **disabled by default**. noctalia handles wallpaper via its own workflow. Enable swww for full wallpaper management with effects and auto-cycling.

**To enable:**
1. Uncomment `exec-once = swww-daemon --format xrgb` in `conf.d/autostart.conf`
2. Uncomment the wallpaper keybinds in `conf.d/keybinds.conf`

**Wallpaper keybinds (when enabled):**

| Key | Action |
|---|---|
| `SUPER W` | Wallpaper picker — browse images and videos |
| `SUPER SHIFT W` | Wallpaper effects — apply ImageMagick filter to current wallpaper |
| `CTRL ALT W` | Random wallpaper from `~/Pictures/wallpapers` |

**Wallpaper directory:** `~/Pictures/wallpapers` (configurable in each script)

**Video wallpapers:** requires `mpvpaper`. Uncomment the `$livewallpaper` lines in `conf.d/autostart.conf` and set the video path.

**Auto-cycling:** uncomment `wallpaper-auto.sh` in `conf.d/autostart.conf` to cycle wallpapers every 30 minutes.

## Waybar (optional)

Waybar is supported but **disabled by default**. noctalia-shell is the primary bar.

**To enable:**
1. Uncomment `exec-once = waybar` in `conf.d/autostart.conf`
2. Uncomment the 3 waybar keybinds in `conf.d/keybinds.conf`

**Waybar keybinds (when enabled):**

| Key | Action |
|---|---|
| `SUPER CTRL B` | Waybar style picker |
| `SUPER ALT B` | Waybar layout picker |
| `SUPER CTRL ALT B` | Toggle waybar visibility |

Style/layout pickers are also accessible from `SUPER SHIFT E -> Waybar`.
Waybar reloads automatically on theme changes if it is running.
