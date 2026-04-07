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
