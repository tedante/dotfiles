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

# --- secret guard ---------------------------------------------------------------
# The package is what becomes public, so inspect the package, not the target.
# Refuse if any file would expose a credential. Only paths are printed.
# Names are anchored and fully escaped: a bare . would also match "serviceXjson".
SECRET_NAMES='^service\.json$|^\.env(\..*)?$|^id_rsa$|^id_ed25519$|^id_ecdsa$|^credentials$|^\.netrc$|^\.(pem|key|p12|pfx)$'
SECRET_CONTENT='-----BEGIN [A-Z ]*PRIVATE KEY-----|(ghp|gho|ghs|ghu)_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,}|(AKIA|ASIA)[0-9A-Z]{16}|sk-[A-Za-z0-9]{20,}|xox[baprs]-[A-Za-z0-9-]{10,}|(api[_-]?key|secret|passwd|password|token)[[:space:]]*[:=][[:space:]]*["'"'"']?[A-Za-z0-9/+_-]{16,}'

package_has_secrets() {
  local found=0 f hit

  while IFS= read -r -d '' f; do
    if printf '%s\n' "${f##*/}" | grep -qE -e "$SECRET_NAMES"; then
      printf '  secret-risk: %s\n' "${f#"$DOTFILES_DIR/"}"
      found=1
      continue
    fi
    while IFS= read -r hit; do
      [[ -n $hit ]] || continue
      printf '  secret-risk: %s:%s\n' "${f#"$DOTFILES_DIR/"}" "$hit"
      found=1
    done < <(grep -nE -e "$SECRET_CONTENT" -- "$f" 2>/dev/null | cut -d: -f1 || true)
  done < <(package_files)

  # Bash convention: success (0) means "has secrets", so `if package_has_secrets`
  # reads naturally at the call site.
  if (( found > 0 )); then return 0; fi
  return 1
}

# --- preflight ------------------------------------------------------------------
[[ -d $DOTFILES_DIR ]] || die "dotfiles directory not found: $DOTFILES_DIR"
[[ -d $PACKAGE_DIR ]] || die "package not found: $PACKAGE_DIR"
command -v stow >/dev/null 2>&1 || die "stow is not installed"

info "repo:    $DOTFILES_DIR"
info "package: $PACKAGE"
info "target:  $TARGET_DIR"

if [[ $MODE == link ]]; then
  if package_has_secrets; then
    printf '\nerror: package contains files that look like credentials (listed above)\n' >&2
    printf 'Remove them from the package before linking. Nothing was changed.\n' >&2
    exit 1
  fi
fi

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

# Back up a real file sitting at a packaged path. Stow links file by file, so a
# plain directory target is expected; only a conflicting non-symlink *file* at a
# packaged path needs moving. Never clobber an existing backup, and never move a
# directory (that would take unrelated files with it).
if [[ -e $TARGET_DIR && ! -L $TARGET_DIR && -d $TARGET_DIR ]]; then
  while IFS= read -r -d '' f; do
    rel=${f#"$PACKAGE_DIR/"}
    [[ -f $HOME/$rel && ! -L $HOME/$rel ]] || continue
    if [[ -e $HOME/$rel.bak ]]; then
      die "backup already exists: $HOME/$rel.bak (move it aside, then re-run)"
    fi
    info "backing up: $HOME/$rel -> $HOME/$rel.bak"
    mv -- "$HOME/$rel" "$HOME/$rel.bak"
  done < <(package_files)
fi

cd -- "$DOTFILES_DIR" || die "cannot enter $DOTFILES_DIR"
# --no-folding keeps the target a real directory and links individual files,
# so later additions to ~/.config/opencode do not land in the repo.
# --target is explicit: when DOTFILES_DIR is overridden, the default target
# (the parent of the repo) is not $HOME.
if ! stow --no-folding --target="$HOME" "$PACKAGE"; then
  printf 'error: stow failed; any files renamed to .bak above were kept\n' >&2
  printf 'Restore them with: mv <file>.bak <file>\n' >&2
  exit 1
fi
info "linked: $PACKAGE"
