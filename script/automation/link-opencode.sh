#!/usr/bin/env bash
# Link, unlink, or inspect the opencode configuration package.
# Usage: link-opencode.sh [--unlink|--status]
#   (default)   back up an existing real directory, then stow the package
#   --unlink    remove the package's symlinks
#   --status    report linked/not linked, change nothing
#
# DOTFILES_DIR overrides the repo location, which makes the script testable
# against a throwaway home.

set -euo pipefail

PACKAGE=opencode
TARGET_REL=.config/opencode

MODE=link

usage() {
  printf 'usage: %s [--unlink|--status]\n' "${0##*/}" >&2
  exit "${1:-0}"
}

while (( $# )); do
  case "$1" in
    --unlink)  MODE=unlink ;;
    --status)  MODE=status ;;
    -h|--help) usage 0 ;;
    *) usage 1 ;;
  esac
  shift
done

die()  { printf 'error: %s\n' "$1" >&2; exit 1; }
info() { printf '%s\n' "$*"; }

DOTFILES_DIR=${DOTFILES_DIR:-$HOME/dotfiles}
TARGET_DIR=$HOME/$TARGET_REL
PACKAGE_DIR=$DOTFILES_DIR/$PACKAGE

# --- linked check ---------------------------------------------------------------
# The package counts as linked when every packaged file is a symlink pointing
# into the repo. Anything else means not linked.
package_files() {
  find "$PACKAGE_DIR/$TARGET_REL" -type f -print0 | sort -z
}

is_linked() {
  local any=false f rel link
  while IFS= read -r -d '' f; do
    any=true
    rel=${f#"$PACKAGE_DIR/"}
    link=$HOME/$rel
    [[ -L $link ]] || return 1
    [[ $(readlink -f "$link") == $(readlink -f "$f") ]] || return 1
  done < <(package_files)
  $any
}

# --- preflight ------------------------------------------------------------------
[[ -d $DOTFILES_DIR ]] || die "dotfiles directory not found: $DOTFILES_DIR"
[[ -d $PACKAGE_DIR ]] || die "package not found: $PACKAGE_DIR"
command -v stow >/dev/null 2>&1 || die "stow is not installed"

info "repo:    $DOTFILES_DIR"
info "package: $PACKAGE"
info "target:  $TARGET_DIR"

# --- status ---------------------------------------------------------------------
if [[ $MODE == status ]]; then
  if is_linked; then
    info "linked"
    exit 0
  fi
  info "not linked"
  exit 1
fi

# --- unlink ---------------------------------------------------------------------
if [[ $MODE == unlink ]]; then
  if ! is_linked; then
    info "not linked, nothing to do"
    exit 0
  fi
  cd -- "$DOTFILES_DIR" || die "cannot enter $DOTFILES_DIR"
  stow --delete --target="$HOME" "$PACKAGE"
  info "unlinked: $PACKAGE"
  exit 0
fi

# --- link -----------------------------------------------------------------------
if is_linked; then
  info "already linked, nothing to do"
  exit 0
fi

# Back up a real directory sitting at the target. Stow links file by file, so a
# plain directory target is expected; only a conflicting non-symlink entry at a
# packaged path would make stow refuse.
if [[ -e $TARGET_DIR && ! -L $TARGET_DIR && -d $TARGET_DIR ]]; then
  local_file=""
  while IFS= read -r -d '' f; do
    rel=${f#"$PACKAGE_DIR/"}
    if [[ -e $HOME/$rel && ! -L $HOME/$rel ]]; then
      info "backing up: $HOME/$rel -> $HOME/$rel.bak"
      mv "$HOME/$rel" "$HOME/$rel.bak"
    fi
  done < <(package_files)
fi

cd -- "$DOTFILES_DIR" || die "cannot enter $DOTFILES_DIR"
# --no-folding keeps the target a real directory and links individual files,
# so later additions to ~/.config/opencode do not land in the repo.
# --target is explicit: when DOTFILES_DIR is overridden, the default target
# (the parent of the repo) is not $HOME.
stow --no-folding --target="$HOME" "$PACKAGE"
info "linked: $PACKAGE"
