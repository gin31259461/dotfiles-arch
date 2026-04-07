#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
#  install-packages  ·  Interactive dotfile dependency installer
#  Arch Linux + Hyprland
#
#  Usage: install-packages.sh [--yes]
#    --yes   skip the final confirmation prompt
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

# shellcheck source=../.local/lib/tui.sh
source "$HOME/.local/lib/tui.sh"

# ── Package helpers ───────────────────────────────────────────────────────────
is_installed() { pacman -Qi "$1" &>/dev/null; }

# count_installed "pkg1 pkg2 ..." → "installed/total"
count_installed() {
  local ins=0 tot=0
  local -a pkgs; read -ra pkgs <<< "$1"
  for p in "${pkgs[@]}"; do
    [[ -z "$p" ]] && continue
    tot=$((tot + 1))
    if is_installed "$p"; then ins=$((ins + 1)); fi
  done
  printf '%d/%d' "$ins" "$tot"
}

# missing_pkgs "pkg1 pkg2 ..." → prints one missing package per line
missing_pkgs() {
  local -a pkgs; read -ra pkgs <<< "$1"
  for p in "${pkgs[@]}"; do
    [[ -z "$p" ]] && continue
    if ! is_installed "$p"; then printf '%s\n' "$p"; fi
  done
}

# color_ratio "2/7" → fixed-width (8 visible chars) colored badge
# Padding is computed from char count (not bytes) — correct in a UTF-8 locale.
color_ratio() {
  local ratio="$1"
  local ins="${ratio%/*}" tot="${ratio#*/}"
  local text color
  if   [[ "$ins" -eq "$tot" && "$tot" -gt 0 ]]; then
    text="${ratio} ✔"; color="$GRN"
  elif [[ "$ins" -gt 0 ]]; then
    text="$ratio";     color="$YLW"
  else
    text="$ratio";     color="$RED"
  fi
  local pad=$(( 8 > ${#text} ? 8 - ${#text} : 0 ))
  printf '%s%s%s%*s' "$color" "$text" "$RST" "$pad" ''
}

# strip_ansi — remove ANSI escape codes from a string
strip_ansi() { sed 's/\x1b\[[0-9;]*m//g' <<< "$1"; }

# ── Package group definitions ─────────────────────────────────────────────────
# Each entry: "key|Display Label|official packages (space-sep)|AUR packages"
declare -a PKG_GROUPS=(
  "core|Core Hyprland\
|hyprland hyprpolkitagent hyprlock hypridle hyprsunset \
xdg-desktop-portal-hyprland xdg-desktop-portal-gtk\
|"
  "shell|Shell & Prompt\
|zsh zsh-completions fzf lsd fastfetch\
|"
  "terminal|Terminals\
|kitty ghostty\
|"
  "files|File Manager\
|thunar thunar-archive-plugin thunar-volman tumbler gvfs gvfs-mtp ffmpegthumbnailer\
|"
  "bar|Bar & Notifications\
|waybar\
|"
  "audio|Audio\
|pipewire pipewire-alsa pipewire-audio pipewire-pulse wireplumber \
pamixer pavucontrol playerctl mpv mpv-mpris\
|"
  "network|Network & Bluetooth\
|networkmanager network-manager-applet bluez bluez-utils blueman\
|"
  "capture|Screenshot & Clipboard\
|grim slurp swappy cliphist wl-clipboard libnotify\
|"
  "theming|Qt Theming\
|kvantum qt5ct qt6ct qt6-5compat nwg-look nwg-displays \
papirus-icon-theme gtk-engine-murrine\
|"
  "fonts|Fonts\
|noto-fonts noto-fonts-emoji otf-font-awesome \
ttf-jetbrains-mono-nerd ttf-firacode-nerd ttf-fantasque-nerd \
adobe-source-code-pro-fonts ttf-droid ttf-fira-code ttf-jetbrains-mono\
|ttf-victor-mono noto-fonts-tc-vf"
  "input|Input Method (fcitx5)\
|fcitx5 fcitx5-chewing fcitx5-gtk fcitx5-qt fcitx5-configtool\
|"
  "utils|Utilities\
|btop cava brightnessctl bc jq imagemagick chafa \
xdg-user-dirs yad rofi xdotool rsync wget unzip pacman-contrib\
|"
  "wallpaper|Wallpaper & Colors\
|\
|swww wallust"
  "session|Session & Logout\
|\
|wlogout"
  "gtk|GTK Theme & Cursor\
|\
adw-gtk-theme"
  "sync|Cloud Sync\
|tailscale\
|onedrive-abraunegg"
  "apps|Applications\
|obsidian remmina vlc\
|vesktop-bin zen-browser-bin"
  "neovim|Neovim Editor\
|lazygit\
|neovim-nightly-bin"
  "noctalia|Noctalia Shell\
|\
|noctalia-shell noctalia-qs"
  "asus|ASUS ROG\
|\
|asusctl rog-control-center supergfxctl"
  "amd|AMD GPU Drivers\
|vulkan-radeon lib32-vulkan-radeon libva-utils amd-ucode\
|"
  "dev|Dev Tools\
|git npm\
|"
)

# ── Group lookups ─────────────────────────────────────────────────────────────
_group_field() {
  local key="$1" field="$2"   # field: 1=key 2=label 3=official 4=aur
  for g in "${PKG_GROUPS[@]}"; do
    IFS='|' read -r k l off aur <<< "$g"
    if [[ "$k" == "$key" ]]; then
      case "$field" in
        label)    printf '%s' "$l" ;;
        official) printf '%s' "$off" ;;
        aur)      printf '%s' "$aur" ;;
      esac
      return
    fi
  done
}

# ── Banner ────────────────────────────────────────────────────────────────────
print_banner() {
  printf '\n'
  printf "  ${BOLD}${BLU}┌─────────────────────────────────────────────────────┐${RST}\n"
  printf "  ${BOLD}${BLU}│${RST}  ${BOLD}Dotfile Package Installer${RST}                          ${BOLD}${BLU}│${RST}\n"
  printf "  ${BOLD}${BLU}│${RST}  ${DIM}Arch Linux + Hyprland${RST}                              ${BOLD}${BLU}│${RST}\n"
  printf "  ${BOLD}${BLU}└─────────────────────────────────────────────────────┘${RST}\n"
  printf '\n'
}

# ── Prerequisite: yay ─────────────────────────────────────────────────────────
ensure_yay() {
  section "Checking prerequisites"
  if command -v yay &>/dev/null; then
    ok "yay AUR helper found  $(yay --version | head -1)"
    return
  fi
  warn "yay not found — building from AUR..."
  command -v git &>/dev/null || die "git is required to build yay: sudo pacman -S git base-devel"
  local tmp
  tmp=$(mktemp -d)
  spin "Cloning yay from AUR…" \
    git clone --depth=1 https://aur.archlinux.org/yay.git "$tmp/yay" \
    || { rm -rf "$tmp"; die "Failed to clone yay repository"; }
  step "Building yay (may prompt for sudo password)…"
  (cd "$tmp/yay" && makepkg -si --noconfirm) \
    || { rm -rf "$tmp"; die "Failed to build yay — check the output above"; }
  rm -rf "$tmp"
  ok "yay installed"
}

# ── Build fzf lines ───────────────────────────────────────────────────────────
build_fzf_lines() {
  for g in "${PKG_GROUPS[@]}"; do
    IFS='|' read -r key label official aur <<< "$g"
    local all="${official} ${aur}"
    local ratio cbadge
    ratio=$(count_installed "$all")
    cbadge=$(color_ratio "$ratio")
    local preview
    preview=$(printf '%s' "${official} ${aur}" \
      | tr ' ' ',' | sed 's/^,//; s/,$//' | cut -c1-55)
    printf "%-12s  [%s]  ${BOLD}%-28s${RST}  ${DIM}%s${RST}\n" \
      "$key" "$cbadge" "$label" "$preview"
  done
}

# ── Group selection: fzf or numbered fallback ─────────────────────────────────
declare -a SELECTED_KEYS=()

select_groups() {
  section "Select package groups"

  if command -v fzf &>/dev/null; then
    _select_fzf
  else
    _select_numbered
  fi
}

_select_fzf() {
  printf "  ${DIM}TAB = toggle  ·  ENTER = confirm  ·  CTRL-A = select all  ·  ESC = exit${RST}\n\n"
  local lines raw_selected
  lines=$(build_fzf_lines)

  raw_selected=$(printf '%s\n' "$lines" \
    | fzf \
        --multi \
        --ansi \
        --no-sort \
        --height='~80%' \
        --border=rounded \
        --prompt='  Groups ❯ ' \
        --header=$'  TAB = toggle  ·  ENTER = confirm  ·  CTRL-A = select all\n' \
        --bind='ctrl-a:toggle-all' \
        --color='header:dim,prompt:blue,pointer:green,marker:green' \
    ) || true   # fzf exits 130 on ESC; || true prevents set -e from firing

  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    local key
    key=$(strip_ansi "$line" | awk '{print $1}')
    [[ -n "$key" ]] && SELECTED_KEYS+=("$key")
  done <<< "$raw_selected"
}

_select_numbered() {
  printf "  ${DIM}Enter numbers (e.g. 1 3 5-7), or ${RST}${BOLD}all${RST}\n\n"
  local i=1
  local -a menu_keys=()

  for g in "${PKG_GROUPS[@]}"; do
    IFS='|' read -r key label official aur <<< "$g"
    local ratio cbadge
    ratio=$(count_installed "${official} ${aur}")
    cbadge=$(color_ratio "$ratio")
    printf "  ${DIM}%2d)${RST}  %-12s  [%s]  %s\n" "$i" "$key" "$cbadge" "$label"
    menu_keys+=("$key")
    i=$((i + 1))
  done

  printf "\n  ${BOLD}Select:${RST} "
  read -r input

  [[ "${input,,}" == "all" ]] && { SELECTED_KEYS=("${menu_keys[@]}"); return; }

  local input_clean="${input//,/ }"
  for token in $input_clean; do
    if [[ "$token" =~ ^([0-9]+)-([0-9]+)$ ]]; then
      local lo="${BASH_REMATCH[1]}" hi="${BASH_REMATCH[2]}"
      for (( n=lo; n<=hi; n++ )); do
        SELECTED_KEYS+=("${menu_keys[$((n-1))]}")
      done
    elif [[ "$token" =~ ^[0-9]+$ ]]; then
      if (( token >= 1 && token <= ${#menu_keys[@]} )); then
        SELECTED_KEYS+=("${menu_keys[$((token-1))]}")
      else
        warn "Skipping $token: out of range (1-${#menu_keys[@]})"
      fi
    fi
  done
}

# ── Build install plan ────────────────────────────────────────────────────────
declare -a PLAN_OFFICIAL=() PLAN_AUR=()

build_plan() {
  section "Scanning installed packages"
  printf "  ${DIM}Checking %d group(s)…${RST}\n" "${#SELECTED_KEYS[@]}"

  local raw_off=() raw_aur=()

  for key in "${SELECTED_KEYS[@]}"; do
    local off aur
    off=$(_group_field "$key" official)
    aur=$(_group_field "$key" aur)

    if [[ -n "$off" ]]; then
      while IFS= read -r pkg; do
        [[ -n "$pkg" ]] && raw_off+=("$pkg")
      done < <(missing_pkgs "$off")
    fi

    if [[ -n "$aur" ]]; then
      while IFS= read -r pkg; do
        [[ -n "$pkg" ]] && raw_aur+=("$pkg")
      done < <(missing_pkgs "$aur")
    fi
  done

  # De-duplicate
  if [[ ${#raw_off[@]} -gt 0 ]]; then
    mapfile -t PLAN_OFFICIAL < <(printf '%s\n' "${raw_off[@]}" | sort -u)
  fi
  if [[ ${#raw_aur[@]} -gt 0 ]]; then
    mapfile -t PLAN_AUR < <(printf '%s\n' "${raw_aur[@]}" | sort -u)
  fi
}

# ── Show plan ─────────────────────────────────────────────────────────────────
# Returns 0 if there's work to do, 1 if everything is already installed.
show_plan() {
  section "Installation plan"

  if [[ ${#PLAN_OFFICIAL[@]} -eq 0 && ${#PLAN_AUR[@]} -eq 0 ]]; then
    ok "All selected packages are already installed — nothing to do."
    return 1
  fi

  if [[ ${#PLAN_OFFICIAL[@]} -gt 0 ]]; then
    printf "\n  ${BOLD}Official (pacman) — %d package(s):${RST}\n" "${#PLAN_OFFICIAL[@]}"
    for p in "${PLAN_OFFICIAL[@]}"; do
      printf "    ${GRN}+${RST}  %s\n" "$p"
    done
  fi

  if [[ ${#PLAN_AUR[@]} -gt 0 ]]; then
    printf "\n  ${BOLD}AUR (yay) — %d package(s):${RST}\n" "${#PLAN_AUR[@]}"
    for p in "${PLAN_AUR[@]}"; do
      printf "    ${YLW}+${RST}  %s\n" "$p"
    done
  fi

  printf '\n'
  return 0
}

# ── Confirm & install ─────────────────────────────────────────────────────────
AUTO_YES=false

do_install() {
  if ! $AUTO_YES; then
    local total=$(( ${#PLAN_OFFICIAL[@]} + ${#PLAN_AUR[@]} ))
    gum_confirm "Install $total package(s)?" || { warn "Aborted."; exit 0; }
  fi

  if [[ ${#PLAN_OFFICIAL[@]} -gt 0 ]]; then
    section "Installing official packages"
    spin "Installing ${#PLAN_OFFICIAL[@]} official package(s)…" \
      sudo pacman -S --needed --noconfirm "${PLAN_OFFICIAL[@]}"
    ok "${#PLAN_OFFICIAL[@]} official package(s) installed"
  fi

  if [[ ${#PLAN_AUR[@]} -gt 0 ]]; then
    section "Installing AUR packages"
    spin "Installing ${#PLAN_AUR[@]} AUR package(s)…" \
      yay -S --needed --noconfirm "${PLAN_AUR[@]}"
    ok "${#PLAN_AUR[@]} AUR package(s) installed"
  fi
}

# ── Summary ───────────────────────────────────────────────────────────────────
show_summary() {
  local total
  total=$(( ${#PLAN_OFFICIAL[@]} + ${#PLAN_AUR[@]} ))
  section "Done"
  ok "$total package(s) installed successfully"
  note "Log out and back in for compositor/env changes to take effect."
  note "Run 'dotfiles.sh' to sync any updated configs."
  printf '\n'
}

# ── Argument parsing ──────────────────────────────────────────────────────────
for arg in "$@"; do
  case "$arg" in
    --yes|-y) AUTO_YES=true ;;
    --help|-h)
      printf 'Usage: %s [--yes]\n' "$(basename "$0")"
      printf '  --yes  skip confirmation prompt\n'
      exit 0
      ;;
    *) die "Unknown option: $arg" ;;
  esac
done

# ── Main ──────────────────────────────────────────────────────────────────────
main() {
  print_banner
  ensure_yay
  select_groups

  if [[ ${#SELECTED_KEYS[@]} -eq 0 ]]; then
    warn "No groups selected — nothing to do."
    exit 0
  fi

  build_plan
  show_plan || exit 0
  do_install
  show_summary
}

main "$@"
