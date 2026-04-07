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

# ── UI helpers ────────────────────────────────────────────────────────────────
die()     { printf "\n  ${RED}✗${RST}  %s\n\n" "$*" >&2; exit 1; }
ok()      { printf "  ${GRN}✔${RST}  %s\n" "$*"; }
warn()    { printf "  ${YLW}!${RST}  %s\n" "$*"; }
note()    { printf "     ${DIM}%s${RST}\n" "$*"; }
step()    { printf "  ${BLU}›${RST}  %s\n" "$*"; }
section() { printf "\n  ${BOLD}${BLU}◆${RST}  ${BOLD}%s${RST}\n\n" "$*"; }

# gum_confirm QUESTION — gum confirm if available, else readline y/N prompt
# Returns 0 (yes) or 1 (no).
gum_confirm() {
  if command -v gum &>/dev/null; then
    gum confirm "$1"
  else
    printf "  ${BLU}?${RST}  %s  ${DIM}[y/N]${RST} " "$1"
    read -r _yn
    [[ "${_yn,,}" =~ ^y(es)?$ ]]
  fi
}

# spin TITLE CMD [ARGS…] — run CMD with a gum spinner.
# Falls back to step+run when gum is absent or CMD is a shell function/builtin.
spin() {
  local title="$1"; shift
  if command -v gum &>/dev/null && [[ "$(type -t "$1" 2>/dev/null)" == "file" ]]; then
    gum spin --spinner dot --title "  $title" -- "$@"
  else
    step "$title"
    "$@"
  fi
}
