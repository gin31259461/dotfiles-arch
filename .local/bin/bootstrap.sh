#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
#  bootstrap  ·  New machine setup for arch-dotfiles
#  Arch Linux + Hyprland
#
#  Usage:
#    bash <(curl -fsSL https://raw.githubusercontent.com/gin31259461/arch-dotfiles/main/.local/bin/bootstrap.sh)
#    bootstrap.sh [--yes|-y]
#
#    --yes   non-interactive — accept all defaults (skip optional steps)
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

# ── Constants ─────────────────────────────────────────────────────────────────
REPO_SSH="git@github.com:gin31259461/arch-dotfiles.git"
REPO_HTTPS="https://github.com/gin31259461/arch-dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"
OPT_YES=false

# shellcheck source=../.local/lib/tui.sh
source "$HOME/.local/lib/tui.sh"

# ── Argument parsing ──────────────────────────────────────────────────────────
for arg in "$@"; do
  case "$arg" in
    --yes|-y) OPT_YES=true ;;
    --help|-h)
      printf 'Usage: %s [--yes]\n  -y, --yes  non-interactive (accept all defaults)\n' \
        "$(basename "$0")"
      exit 0 ;;
    *) die "Unknown option: $arg" ;;
  esac
done

# ── Bare repo helper ──────────────────────────────────────────────────────────
dot() { git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" "$@"; }

# ── Confirm prompt ────────────────────────────────────────────────────────────
# Returns 0 (yes) or 1 (no). --yes flag always answers yes.
confirm() {
  $OPT_YES && return 0
  printf "  ${BLU}?${RST}  %s  ${DIM}[y/N]${RST} " "$1"
  read -r yn
  [[ "${yn,,}" =~ ^y(es)?$ ]]
}

# ── Main ──────────────────────────────────────────────────────────────────────
main() {
  [[ -f /etc/arch-release ]] || die "This script targets Arch Linux only"

  printf "\n  ${BOLD}Dotfiles Bootstrap${RST}  ${DIM}Arch Linux · Hyprland${RST}\n"
  printf "  ${DIM}%s${RST}\n" "$(printf '─%.0s' {1..44})"

  # ── Prerequisites ───────────────────────────────────────────────────────────
  section "Prerequisites"
  local -a missing=()
  for pkg in git rsync base-devel; do
    if pacman -Qi "$pkg" &>/dev/null; then
      ok "$pkg"
    else
      missing+=("$pkg")
    fi
  done
  if [[ ${#missing[@]} -gt 0 ]]; then
    step "Installing: ${missing[*]}"
    sudo pacman -S --needed --noconfirm "${missing[@]}"
    ok "Prerequisites ready"
  fi

  # ── Clone & deploy ──────────────────────────────────────────────────────────
  section "Dotfiles repository"
  if [[ -d "$DOTFILES_DIR" ]]; then
    ok "Bare repo already present at $DOTFILES_DIR — skipping clone"
  else
    # Prefer SSH; fall back to HTTPS when no GitHub SSH access
    local clone_url="$REPO_SSH"
    if ! ssh -T git@github.com -o BatchMode=yes -o ConnectTimeout=5 &>/dev/null 2>&1; then
      warn "No SSH access to GitHub — using HTTPS"
      clone_url="$REPO_HTTPS"
    fi

    step "Cloning $clone_url"
    local tmp; tmp=$(mktemp -d)
    git clone --separate-git-dir="$DOTFILES_DIR" "$clone_url" "$tmp/dotfiles" \
      || { rm -rf "$tmp"; die "Clone failed — check URL and network"; }

    section "Deploying to \$HOME"
    step "Copying files…"
    rsync --recursive --exclude '.git' "$tmp/dotfiles/" "$HOME/"
    rm -rf "$tmp"
    ok "Files deployed to $HOME"
  fi

  # ── Configure ───────────────────────────────────────────────────────────────
  section "Configuration"

  dot config --local status.showUntrackedFiles no
  ok "status.showUntrackedFiles = no"

  # Ensure dot alias is present in .zshrc
  local alias_line="alias dot='git --git-dir=\$HOME/.dotfiles/ --work-tree=\$HOME'"
  if [[ -f "$HOME/.zshrc" ]] && grep -q 'alias dot=' "$HOME/.zshrc"; then
    ok "dot alias already in .zshrc"
  else
    printf '\n# dotfiles bare repo\n%s\n' "$alias_line" >> "$HOME/.zshrc"
    ok "dot alias added to .zshrc"
  fi

  # Make all bin scripts executable
  chmod +x "$HOME/.local/bin/"*.sh 2>/dev/null || true
  ok "Scripts in ~/.local/bin made executable"

  # ── Submodules ──────────────────────────────────────────────────────────────
  section "Submodules"
  step "Initialising submodules…"
  dot submodule update --init --recursive
  ok "Submodules ready"

  # ── Oh My Zsh ───────────────────────────────────────────────────────────────
  section "Oh My Zsh"
  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    ok "Oh My Zsh already installed"
  elif confirm "Install Oh My Zsh? (required by .zshrc)"; then
    step "Installing Oh My Zsh…"
    RUNZSH=no KEEP_ZSHRC=yes \
      sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    ok "Oh My Zsh installed"

    local custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

    step "Installing zsh-autosuggestions…"
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions \
      "$custom/plugins/zsh-autosuggestions"

    step "Installing zsh-syntax-highlighting…"
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting \
      "$custom/plugins/zsh-syntax-highlighting"

    step "Installing Powerlevel10k theme…"
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
      "$custom/themes/powerlevel10k"

    ok "Zsh plugins and theme ready"
  else
    warn "Skipped — .zshrc expects Oh My Zsh; install manually: https://ohmyz.sh"
  fi

  # ── Packages ────────────────────────────────────────────────────────────────
  section "Install packages"
  if confirm "Run install-packages now?"; then
    "$HOME/.local/bin/install-packages.sh"
  else
    note "Run install-packages.sh later to install dotfile dependencies"
  fi

  # ── Done ────────────────────────────────────────────────────────────────────
  section "Done"
  ok "Bootstrap complete"
  note "Restart your shell or run: exec zsh"
  note "Use 'dot status' to inspect your dotfiles"
  note "Use 'dotfiles.sh' to sync config changes back to the repo"
  printf '\n'
}

main
