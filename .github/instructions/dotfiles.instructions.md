---
description: 'Guidelines for managing abner''s Arch Linux + Hyprland dotfiles.'
applyTo: '**'
---

# Dotfiles Management Guidelines

## Repository Layout

These dotfiles are managed with a **bare git repository** — no symlinks, no
stow. The working tree is `$HOME`.

| Path | Purpose |
|---|---|
| `~/.dotfiles/` | Bare git repository |
| `~` | Working tree (all tracked files live here directly) |
| `~/.local/bin/` | User scripts — all are in `$PATH` |
| `~/.local/lib/` | Shared shell libraries (sourced by scripts, not executed) |
| `~/.config/hypr/` | Hyprland compositor configuration |
| `~/.github/` | Copilot instructions, agents, skills |

**Always use the `dot` alias** (or its full form) for git operations:

```bash
alias dot='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# equivalently
git --git-dir=$HOME/.dotfiles --work-tree=$HOME <command>
```

Never run plain `git` in `$HOME` — it will target the wrong repository.

---

## Core Scripts

### `dotfiles.sh` — sync changes to the repo

Stages all tracked paths, commits, and pushes to `origin main`.

```bash
dotfiles.sh                   # opens gum write for interactive commit message
dotfiles.sh -m "update hypr"  # skip prompt, use provided message
```

When `-m` is omitted and `gum` is available, a multi-line editor opens
(`Ctrl+D` to confirm). Falls back to `"sync dotfiles"` if left empty or
`gum` is not installed.

To add a new file to tracking: add it to the relevant `dot add` block in
`~/.local/bin/dotfiles.sh`, then run `dotfiles.sh`.

### `bootstrap.sh` — new machine setup

Full one-command setup on a fresh Arch install:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/gin31259461/arch-dotfiles/main/.local/bin/bootstrap.sh)
```

What it does: installs prereqs → clones bare repo → rsync deploys to `$HOME` →
configures `dot` alias → init submodules → optional Oh My Zsh (via `gum confirm`) →
optional `install-packages`. Long operations show `gum spin` spinners.

### `install-packages.sh` — interactive package installer

fzf-powered multi-select installer for all dotfile dependencies.
Groups: core, shell, terminal, files, bar, audio, network, capture, theming,
fonts, input, utils, wallpaper, session, gtk, sync, apps, neovim, noctalia,
asus, amd, dev.

```bash
install-packages.sh      # interactive (fzf: TAB=toggle, ENTER=confirm)
install-packages.sh -y   # skip confirmation
```

AUR packages use `yay` (auto-installed if missing via `gum spin`).
Final install is confirmed with `gum confirm`.

### `cleanup.sh` — interactive system cleanup

Frees disk space: pacman cache, AUR cache, orphaned packages, systemd journal,
npm cache, thumbnail cache. Shows reclaimable size before confirming.

```bash
cleanup.sh      # interactive (fzf task selection, gum confirm)
cleanup.sh -y   # skip confirmations
```

---

## TUI Style Convention

All scripts share the same visual language via **`~/.local/lib/tui.sh`** —
source it at the top of any new script:

```bash
# shellcheck source=../.local/lib/tui.sh
source "$HOME/.local/lib/tui.sh"
```

### Print helpers

```bash
# Colors: RED GRN YLW BLU DIM BOLD RST  (disabled when stdout is not a TTY)

die()     # "  ✗  message"  — fatal error, exits
ok()      # "  ✔  message"  — success (green)
warn()    # "  !  message"  — warning (yellow)
note()    # "     message"  — dim note
step()    # "  ›  message"  — in-progress step (blue)
section() # "  ◆  Heading"  — bold section header (blue diamond)
```

### `gum_confirm` — confirmation prompt

```bash
gum_confirm "Question?"   # gum confirm UI when available, else [y/N] readline
```

Returns 0 (yes) or 1 (no). Scripts with a `--yes` flag check it before calling:

```bash
confirm() {
  $OPT_YES && return 0
  gum_confirm "$1"
}
```

### `spin` — loading spinner

```bash
spin "Cloning repo…" git clone "$url" "$dest"
spin "Installing packages…" sudo pacman -S --needed --noconfirm "${pkgs[@]}"
```

Uses `gum spin --spinner dot` for external binaries. Falls back to `step` +
direct call for shell functions/builtins, or when `gum` is not installed.

### `gum write` — multi-line text input

Used in `dotfiles.sh` to collect a commit message interactively:

```bash
MSG=$(gum write --placeholder "Describe your changes…" \
  --header "Commit message  (Ctrl+D to confirm)" --width 72 --height 6)
```

### fzf — multi-select list

`cleanup.sh` and `install-packages.sh` use fzf for task/group selection:

```
TAB = toggle  ·  ENTER = confirm  ·  CTRL-A = select all  ·  ESC = exit
```

fzf color scheme: `header:dim,prompt:blue,pointer:green,marker:green`

---

## Hyprland Configuration

### Entry point

`~/.config/hypr/hyprland.conf` sources everything else. Never put settings
directly in it — use the appropriate `conf.d/` file.

### Config structure

| File | What goes here |
|---|---|
| `conf.d/env.conf` | Environment variables (`$term`, `$files`, Wayland/Qt/fcitx5 vars) |
| `conf.d/appearance.conf` | Borders, gaps, rounding, shadows, blur |
| `conf.d/autostart.conf` | `exec-once` services and apps |
| `conf.d/input.conf` | Keyboard, mouse, touchpad settings |
| `conf.d/layout.conf` | Active layout, dwindle/master/scrolling config |
| `conf.d/keybinds.conf` | All keybinds (`$mainMod = SUPER`) |
| `conf.d/misc.conf` | Misc Hyprland options |
| `conf.d/window-rules.conf` | `windowrule` / `windowrulev2` entries |
| `conf.d/laptops.conf` | Lid switch, battery, laptop-specific rules |
| `conf.d/animations.conf` | Active animation preset (sources from `animations/`) |
| `monitors.conf` | Monitor layout — managed by `nwg-displays` |
| `noctalia/noctalia-colors.conf` | Noctalia theme color overrides |

### Scripts

Scripts live under `~/.config/hypr/scripts/` organised by function:

| Dir | Purpose |
|---|---|
| `display/` | Window layout, wallpaper, brightness, themes, bar |
| `input/` | Keybind init, keyboard layout, key hints |
| `services/` | Polkit, drop terminal |
| `session/` | Logout, game mode, overview |
| `rofi/` | App launcher, emoji, search, quick settings, clipboard |
| `media/` | Online music |

### Layout cycling

`scripts/display/change-layout.sh` cycles: **dwindle → master → scrolling → dwindle**

- Called at startup with `init` arg: applies keybinds for current layout without switching
- Toggles `SUPER+J/K` behaviour per layout:
  - dwindle: `cyclenext` / `cyclenext prev`
  - master: `layoutmsg cyclenext` / `layoutmsg cycleprev`
  - scrolling: `layoutmsg focus d` / `layoutmsg focus u`
- Also binds `SUPER+O` (togglesplit) only when in dwindle
- Bind: `SUPER ALT L`

### Default layout

`conf.d/layout.conf` — `general { layout = scrolling }` is the startup default.

### Scrolling layout config (in `layout.conf`)

```ini
scrolling {
  column_width = 0.5
  fullscreen_on_one_column = true
  explicit_column_widths = 0.333, 0.5, 0.667, 1.0
  follow_focus = true
  focus_fit_method = 1
}
```

---

## Git Operations

```bash
# Status — always suppress untracked file noise
dot status

# Diff before committing
dot diff

# Stage a specific file
dot add ~/.config/hypr/conf.d/keybinds.conf

# Commit manually
dot commit -m "describe change"

# Push
dot push origin main

# Sync everything at once (runs dotfiles.sh)
dotfiles.sh -m "your message"
```

**Submodules** — NvChad (`.config/nvim`) is a submodule pointing to
`github.com/gin31259461/nvchad`.

```bash
dot submodule update --init --recursive   # pull submodule code after clone
dot submodule sync --recursive            # sync after .gitmodules changes
```

---

## Package Management

- `pacman` for official packages, `yay` for AUR
- Add packages to the correct group in `~/.local/bin/install-packages.sh`
- Run `install-packages.sh` to install; it skips already-installed packages
- Official packages go in the 3rd `|`-field; AUR packages in the 4th field

---

## Shell

- Shell: `zsh` with Oh My Zsh + Powerlevel10k (`~/.zshrc`, `~/.p10k.zsh`)
- Plugins: `zsh-autosuggestions`, `zsh-syntax-highlighting`
- `$PATH` includes `~/.local/bin` — all scripts are directly runnable by name
- `dot` alias defined in `~/.zshrc`

---

## Commit Style

- Use lowercase imperative subject lines: `fix:`, `add`, `update`, `scripts:`
- No co-author trailers unless explicitly requested
- After changes: always run `dotfiles.sh` (or `dot add … && dot commit && dot push`)
