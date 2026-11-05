#!/usr/bin/env bash
# Enable or disable the hourly maintenance timers (organize-folder, push-dotfiles).
# Usage: enable-timers.sh [--disable] [--status]
#   (default)   stow the units, reload systemd, enable both timers now
#   --disable   stop and disable both timers
#   --status    show enabled/active state, change nothing

set -euo pipefail

TIMERS=(organize-download.timer push-dotfiles.timer)
MODE=enable

usage() {
  printf 'usage: %s [--disable|--status]\n' "${0##*/}" >&2
  exit "${1:-0}"
}

while (( $# )); do
  case "$1" in
    --disable) MODE=disable ;;
    --status)  MODE=status ;;
    -h|--help) usage 0 ;;
    *) usage 1 ;;
  esac
  shift
done

die()  { printf 'error: %s\n' "$1" >&2; exit 1; }
info() { printf '%s\n' "$*"; }

DOTFILES_DIR=${DOTFILES_DIR:-$HOME/dotfiles}

# --- preflight -----------------------------------------------------------------
[[ -d $DOTFILES_DIR ]] || die "dotfiles directory not found: $DOTFILES_DIR"
[[ -d $DOTFILES_DIR/systemd/.config/systemd/user ]] \
  || die "no systemd units in $DOTFILES_DIR/systemd/.config/systemd/user"

command -v stow >/dev/null 2>&1 || die "stow is not installed"

for t in "${TIMERS[@]}"; do
  [[ -f $DOTFILES_DIR/systemd/.config/systemd/user/$t ]] \
    || die "missing unit: $t"
done

command -v systemctl >/dev/null 2>&1 || die "systemctl is not available"
systemctl --user show-environment >/dev/null 2>&1 \
  || die "no systemd user session (are you in a graphical session?)"

info "repo:   $DOTFILES_DIR"

# --- status ---------------------------------------------------------------------
if [[ $MODE == status ]]; then
  for t in "${TIMERS[@]}"; do
    enabled=$(systemctl --user is-enabled "$t" 2>/dev/null || true)
    active=$(systemctl --user is-active "$t" 2>/dev/null || true)
    printf '  %-26s enabled=%-8s active=%s\n' \
      "$t" "${enabled:-unknown}" "${active:-unknown}"
  done
  exit 0
fi

# --- disable ---------------------------------------------------------------------
if [[ $MODE == disable ]]; then
  for t in "${TIMERS[@]}"; do
    systemctl --user disable --now "$t" 2>/dev/null || true
    info "disabled: $t"
  done
  exit 0
fi

# --- enable ----------------------------------------------------------------------
# Units are stowed, so ~/.config/systemd/user mirrors the repo directory.
cd -- "$DOTFILES_DIR" || die "cannot enter $DOTFILES_DIR"
stow systemd
info "stowed: systemd"

systemctl --user daemon-reload

for t in "${TIMERS[@]}"; do
  systemctl --user enable --now "$t"
  info "enabled: $t"
done

info ""
info "next runs:"
systemd-analyze --user calendar hourly 2>/dev/null | head -1 || true
