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

Flags:
- `--yes` / `-y` — non-interactive, accept all defaults
- `--repo <ssh-url>` / `-r` — SSH URL of the user's own dotfiles remote

What it does: installs prereqs → clones repo → rsync deploys to `$HOME` →
configures `dot` alias → init submodules → optional Oh My Zsh (via `gum confirm`) →
optional `install-packages`. Long operations show `gum spin` spinners.

**Repo selection (memory file `~/.dotfiles-repo`):**

`bootstrap.sh` writes `~/.dotfiles-repo` after every successful clone to
remember which SSH remote URL this machine uses. The file is **tracked in the
repo** so it is deployed to every new machine via rsync.

`DEFAULT_REPO_SSH`/`HTTPS` are initialised from `~/.dotfiles-repo` at startup
(if it exists), so the correct fork is targeted without any flags.

| Condition | Action |
|---|---|
| No `--repo`, memory file present or DEFAULT updated | SSH clone from that URL (HTTPS fallback if no key) |
| `--repo` differs from current DEFAULT | HTTPS clone of the DEFAULT repo as base; set `--repo` URL as `origin`; **update `DEFAULT_REPO_SSH`/`HTTPS` in the deployed `bootstrap.sh`** so future machines need no flag |

**Fork owner workflow:**
1. First machine: `bootstrap.sh --repo git@github.com:you/arch-dotfiles.git`
   → clones default, sets remote, bakes your URL into `bootstrap.sh`, writes `~/.dotfiles-repo`
2. Run `dotfiles.sh` to commit and push (both `bootstrap.sh` and `.dotfiles-repo` are tracked)
3. All subsequent machines: `bash <(curl ... your-fork/bootstrap.sh)` — no `--repo` needed

### `install-packages.sh` — interactive package installer

fzf-powered multi-select installer for all dotfile dependencies.
Groups: core, shell, terminal, files, bar, audio, network, capture, theming,
fonts, input, utils, wallpaper, session, gtk, sync, apps, neovim, noctalia,
asus, amd, dev, msi, razer, sddm.

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

### Noctalia theme

`tui.sh` exports the Noctalia colour palette for both gum and fzf automatically
upon sourcing. No extra setup is needed in scripts.

**Palette** (Tokyo Night):

| Role | Hex |
|---|---|
| primary (blue) | `#7aa2f7` |
| secondary (purple) | `#bb9af7` |
| tertiary (green) | `#9ece6a` |
| error (red) | `#f7768e` |
| fg | `#c0caf5` |
| surface | `#1a1b26` |

### Print helpers

No left padding — all output starts at column 0. `section()` adds a blank line
before and after the heading. `gum_confirm` and `gum write` print `\n` before
opening for top margin.

```bash
# Colors: RED GRN YLW BLU DIM BOLD RST  (disabled when stdout is not a TTY)

die()     # "✗  message"  — fatal error, exits
ok()      # "✔  message"  — success (green)
warn()    # "!  message"  — warning (yellow)
note()    # "message"     — dim note
step()    # "›  message"  — in-progress step (blue)
section() # "\n◆  Heading\n\n"  — bold section header (blue diamond)
```

### `gum_confirm` — confirmation prompt

```bash
gum_confirm "Question?"   # gum confirm UI when available, else [y/N] readline
```

Returns 0 (yes) or 1 (no). Prints `\n` before the prompt for top margin. Theme
set via `GUM_CONFIRM_*` env vars in `tui.sh`. Scripts with a `--yes` flag check
it before calling:

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

Uses `gum spin --spinner dot` for external binaries. Theme set via
`GUM_SPIN_*` env vars. Falls back to `step` + direct call for shell
functions/builtins, or when `gum` is not installed.

### `gum write` — multi-line text input

Used in `dotfiles.sh` to collect a commit message interactively:

```bash
printf "\n"
MSG=$(gum write --placeholder "Describe your changes…" \
  --header "Commit message  (Ctrl+D to confirm)" --width 72 --height 6)
```

Always print `\n` before `gum write` for top margin. Theme set via
`GUM_WRITE_*` env vars in `tui.sh`.

### fzf — multi-select list

`cleanup.sh` and `install-packages.sh` use fzf for task/group selection.
Use `$FZF_COLORS` from `tui.sh` and `--margin='1,0,0,0'` for top margin:

```bash
fzf --color="$FZF_COLORS" --margin='1,0,0,0' ...
```

```
TAB = toggle  ·  ENTER = confirm  ·  CTRL-A = select all  ·  ESC = exit
```

fzf colour scheme (Noctalia): `bg+:#1a1b26,bg:#1c1d2a,spinner:#bb9af7,hl:#7aa2f7,fg:#a9b1d6,header:#565f89,info:#9ece6a,pointer:#7aa2f7,marker:#9ece6a,fg+:#c0caf5,prompt:#7aa2f7,hl+:#bb9af7,border:#414868`

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

### Package groups structure

Packages are defined in `~/.local/lib/packages.sh` with per-group format:
```
"key|Display Label|official packages (space-sep)|AUR packages (space-sep)"
```

### Core vs Extra setup

**Core setup** (`~/.local/lib/core/*.sh`): Essential services and configurations sourced automatically by `install-packages.sh`.
- `autologin.sh` — Handles automatic login configuration for specific display managers

**Extra setup** (`~/.local/lib/extra/*.sh`): Optional device-specific or service-specific configurations.
- `msi.sh` — MSI laptop power management and control center setup
- `razer.sh` — Razer laptop support (OpenRazer daemon, RazerGenie)
- `sddm.sh` — SDDM login manager configuration
- `sunshine.sh` — Sunshine self-hosted game streaming setup

To add a new package: append to the official or AUR field in `~/.local/lib/packages.sh`.
To add new setup logic: create a `.sh` file in `core/` or `extra/` — it will be sourced automatically.

---

## Shell

- Shell: `zsh` with Oh My Zsh + Powerlevel10k (`~/.zshrc`, `~/.p10k.zsh`)
- Plugins: `zsh-autosuggestions`, `zsh-syntax-highlighting`
- `$PATH` includes `~/.local/bin` — all scripts are directly runnable by name
- `dot` alias defined in `~/.zshrc`

---

## Commit Style

- Use lowercase imperative subject lines: `fix:`, `add`, `update`, `scripts:`
- **Never include co-authored-by trailers** — not for any commit in this repo
- After every task: automatically run `dotfiles.sh` (or `dot add … && dot commit && dot push`) — do not wait to be asked

---

## Review Before Completing

Before marking any task done, always:

1. **Re-read every file you changed** — check for leftover debug lines, wrong indentation, missed substitutions, or stale references
2. **Run syntax checks** — `bash -n <script>` for shell scripts
3. **Look for related bugs** — if you changed a function used in multiple scripts, check all call sites
4. **Verify consistency** — confirm that docs, instructions, and README still accurately describe the code

Only call a task complete after this review passes.

---

## After Modifying Dotfiles

**You must update `README.md` and/or `doc/` whenever you add, update, or remove
any script, feature, or flag.** Never mark a task complete without syncing docs.

Whenever you change scripts, configs, or add new functionality, keep these in sync:

| What changed | What to update |
|---|---|
| New script or feature added | `README.md` — add description to the relevant section |
| Existing script or feature updated | `README.md` and/or `doc/<script>.md` — reflect the change |
| Script or feature removed | `README.md` and/or `doc/<script>.md` — remove stale entries |
| New flag or option added | `README.md` (usage table/examples) and script `--help` text |
| New file added to dotfiles tracking | `dotfiles.sh` — add the path to the relevant `dot add` block |
| Dotfiles file removed from tracking | `dotfiles.sh` — remove the path from the relevant `dot add` block |
| TUI conventions changed | `~/.github/instructions/dotfiles.instructions.md` — update TUI Style Convention |
| Instructions file itself | Re-read after editing to confirm accuracy |

Always run `dotfiles.sh` after updating any of the above so the changes are committed and pushed.
