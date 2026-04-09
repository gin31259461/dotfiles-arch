#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
#  tui.sh  ·  Shared TUI helpers for dotfile scripts
#
#  Source this file; do not execute it directly:
#    source "$HOME/.local/lib/tui.sh"
# ─────────────────────────────────────────────────────────────────────────────

# ── Colors (disabled when not a TTY) ─────────────────────────────────────────
if [[ -t 1 ]]; then
  RED=$'\e[31m'; GRN=$'\e[32m'; YLW=$'\e[33m'; BLU=$'\e[34m'
  DIM=$'\e[2m';  BOLD=$'\e[1m'; RST=$'\e[0m'
else
  RED=''; GRN=''; YLW=''; BLU=''; DIM=''; BOLD=''; RST=''
fi

# ── Noctalia theme — gum (env vars) ──────────────────────────────────────────
# primary=#7aa2f7  secondary=#bb9af7  fg=#c0caf5  surface=#1a1b26
export GUM_CONFIRM_PROMPT_FOREGROUND="#7aa2f7"
export GUM_CONFIRM_SELECTED_FOREGROUND="#1a1b26"
export GUM_CONFIRM_SELECTED_BACKGROUND="#7aa2f7"
export GUM_CONFIRM_UNSELECTED_FOREGROUND="#bb9af7"

export GUM_SPIN_SPINNER_FOREGROUND="#7aa2f7"
export GUM_SPIN_TITLE_FOREGROUND="#c0caf5"

export GUM_WRITE_CURSOR_FOREGROUND="#7aa2f7"
export GUM_WRITE_PROMPT_FOREGROUND="#bb9af7"
export GUM_WRITE_HEADER_FOREGROUND="#9ece6a"
export GUM_WRITE_BASE_FOREGROUND="#c0caf5"
export GUM_WRITE_END_OF_BUFFER_FOREGROUND="#1a1b26"

export GUM_INPUT_CURSOR_FOREGROUND="#7aa2f7"
export GUM_INPUT_PROMPT_FOREGROUND="#bb9af7"
export GUM_INPUT_HEADER_FOREGROUND="#9ece6a"
export GUM_INPUT_PLACEHOLDER_FOREGROUND="#565f89"

# ── Noctalia theme — fzf ─────────────────────────────────────────────────────
# Use as: fzf --color="$FZF_COLORS" ...
FZF_COLORS='bg+:#1a1b26,bg:#1c1d2a,spinner:#bb9af7,hl:#7aa2f7,fg:#a9b1d6,header:#565f89,info:#9ece6a,pointer:#7aa2f7,marker:#9ece6a,fg+:#c0caf5,prompt:#7aa2f7,hl+:#bb9af7,border:#414868'

# ── UI helpers ────────────────────────────────────────────────────────────────
die()     { printf "\n${RED}✗${RST}  %s\n\n" "$*" >&2; exit 1; }
ok()      { printf "${GRN}✔${RST}  %s\n" "$*"; }
warn()    { printf "${YLW}!${RST}  %s\n" "$*"; }
note()    { printf "${DIM}%s${RST}\n" "$*"; }
step()    { printf "${BLU}›${RST}  %s\n" "$*"; }
section() { printf "\n${BOLD}${BLU}◆${RST}  ${BOLD}%s${RST}\n\n" "$*"; }

# gum_confirm QUESTION — gum confirm if available, else readline y/N prompt
# Returns 0 (yes) or 1 (no).
gum_confirm() {
  if command -v gum &>/dev/null; then
    printf "\n"
    gum confirm "$1"
  else
    printf "${BLU}?${RST}  %s  ${DIM}[y/N]${RST} " "$1"
    read -r _yn
    [[ "${_yn,,}" =~ ^y(es)?$ ]]
  fi
}

# spin TITLE CMD [ARGS…] — run CMD with a gum spinner.
# Falls back to step+run when gum is absent or CMD is a shell function/builtin.
spin() {
  local title="$1"; shift
  if command -v gum &>/dev/null && [[ "$(type -t "$1" 2>/dev/null)" == "file" ]]; then
    gum spin --spinner dot --title "$title" --show-error -- "$@"
  else
    step "$title"
    "$@"
  fi
}
