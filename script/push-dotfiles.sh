#!/usr/bin/env bash
# Push committed changes from a dotfiles repo to its remote.
# Usage: push-dotfiles.sh [-p] [DIR]
#   -p   actually push; without it nothing is sent
#
# Never commits. Refuses to run with uncommitted changes, refuses on
# divergence, and refuses to push commits that look like they contain secrets.

set -euo pipefail

DRY_RUN=true

usage() {
  printf 'usage: %s [-p] [DIR]\n' "${0##*/}" >&2
  exit "${1:-0}"
}

while getopts ':ph' opt; do
  case "$opt" in
    p) DRY_RUN=false ;;
    h) usage 0 ;;
    *) usage 1 ;;
  esac
done
shift $((OPTIND - 1))

DIR="${1:-$HOME/dotfiles}"

die() { printf 'error: %s\n' "$1" >&2; exit 1; }
info() { printf '%s\n' "$*"; }

[[ -d $DIR ]] || die "not a directory: $DIR"
cd -- "$DIR" || die "cannot enter $DIR"
git rev-parse --git-dir >/dev/null 2>&1 || die "not a git repository: $DIR"

REMOTE=$(git config --get remote.origin.url) || die "no 'origin' remote configured"
BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null) || die "detached HEAD; check out a branch first"

info "repo:   $DIR"
info "remote: $REMOTE"
info "branch: $BRANCH"

# --- refuse to run on a dirty tree ---------------------------------------------
# This script pushes commits; it does not create them. A dirty tree usually means
# you forgot to commit, so stop and say what is pending.
if [[ -n $(git status --porcelain) ]]; then
  printf 'error: uncommitted changes in %s\n\n' "$DIR" >&2
  git status --short | sed 's/^/  /' >&2
  printf '\nCommit or discard them first; this script does not commit.\n' >&2
  exit 1
fi

# --- secret guard on outgoing commits ------------------------------------------
# Only the commits that would actually be pushed are inspected. Prints
# file:line, never the matched text.
SECRET_RE='-----BEGIN [A-Z ]*PRIVATE KEY-----|(ghp|gho|ghs|ghu)_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,}|(AKIA|ASIA)[0-9A-Z]{16}|sk-[A-Za-z0-9]{20,}|xox[baprs]-[A-Za-z0-9-]{10,}|(api[_-]?key|secret|passwd|password|token)[[:space:]]*[:=][[:space:]]*["'"'"']?[A-Za-z0-9/+_-]{16,}'

scan_outgoing() {
  local range=$1 found=0 hit

  # Walk every commit in the range, not the endpoint diff: a secret added in one
  # commit and deleted in the next is invisible to `git diff A..B`, but it still
  # ships in history.
  while IFS= read -r hit; do
    [[ -n $hit ]] || continue
    printf '  secret-risk: %s\n' "$hit"
    found=1
  done < <(
    git log -p --no-color --no-merges --unified=0 \
      --format='commit %h' "$range" 2>/dev/null |
      awk '
        /^commit / { sha = $2; file = ""; next }
        /^diff --git / { next }
        /^\+\+\+ b\// { file = substr($0, 7); next }
        /^\+\+\+ \/dev\/null/ { file = ""; next }
        /^@@ / { match($0, /\+[0-9]+/); ln = substr($0, RSTART + 1, RLENGTH - 1) + 0; next }
        /^\+/ && file != "" { print sha "\t" file ":" ln "\t" substr($0, 2); ln++; next }
      ' |
      grep -E -- "$SECRET_RE" 2>/dev/null |
      cut -f1,2 || true
  )

  # Filename check across every commit too: `.env` committed and deleted in the
  # same range still becomes public once it is in history.
  while IFS= read -r hit; do
    [[ -n $hit ]] || continue
    local path=${hit#*$'\t'}
    # Templates are meant to be committed.
    case "${path##*/}" in
      *.example|*.sample|*.template) continue ;;
    esac
    printf '  secret-risk file: %s\n' "$hit"
    found=1
  done < <(
    git log --no-color --no-merges --name-only --format='commit %h' "$range" 2>/dev/null |
      awk '
        /^commit / { sha = $2; next }
        /^$/ { next }
        { print sha "\t" $0 }
      ' |
      grep -E '(^|[[:space:]/])(\.env(\..*)?|\.netrc|credentials|id_rsa|id_ed25519|id_ecdsa)$|\.(pem|key|p12|pfx)$' |
      cut -f1,2 || true
  )

  return "$found"
}

# --- state ---------------------------------------------------------------------
git fetch --quiet origin || die "cannot reach remote '$REMOTE'"

UPSTREAM="origin/$BRANCH"
if git rev-parse --verify --quiet "$UPSTREAM" >/dev/null; then
  read -r BEHIND AHEAD < <(git rev-list --left-right --count "$UPSTREAM...HEAD")
  NEW_REMOTE_BRANCH=false
  RANGE="$UPSTREAM..HEAD"
else
  info "note: remote branch '$BRANCH' does not exist yet; everything reachable will be pushed"
  BEHIND=0
  AHEAD=$(git rev-list --count HEAD)
  NEW_REMOTE_BRANCH=true
  RANGE="HEAD"
fi

# --- divergence is a hard stop --------------------------------------------------
if (( BEHIND > 0 )); then
  if (( AHEAD > 0 )); then
    printf 'error: branch diverged from %s (%d behind, %d ahead)\n' "$UPSTREAM" "$BEHIND" "$AHEAD" >&2
  else
    printf 'error: local branch is behind %s by %d commit(s); pull first\n' "$UPSTREAM" "$BEHIND" >&2
  fi
  printf '\ncommits only on the remote:\n' >&2
  git --no-pager log --oneline --no-decorate "HEAD..$UPSTREAM" | sed 's/^/  /' >&2
  if (( AHEAD > 0 )); then
    printf '\ncommits only local:\n' >&2
    git --no-pager log --oneline --no-decorate "$UPSTREAM..HEAD" | sed 's/^/  /' >&2
  fi
  printf '\nThis script never merges or rebases. Resolve manually, then re-run.\n' >&2
  exit 1
fi

# --- nothing to push ------------------------------------------------------------
if (( AHEAD == 0 )); then
  info ""
  info "nothing to push: in sync with $UPSTREAM"
  exit 0
fi

info ""
info "outgoing commits:"
git --no-pager log --oneline --no-decorate "$RANGE" | sed 's/^/  /'

info ""
info "checking outgoing changes for secrets"
if ! scan_outgoing "$RANGE"; then
  printf '\nrefusing to push: possible secrets in the commits above.\n' >&2
  printf 'Fix the history (or delete the local commits) before pushing.\n' >&2
  exit 1
fi

if $DRY_RUN; then
  info ""
  info "would push: $AHEAD commit(s) to $UPSTREAM"
  info "dry run: nothing sent. Re-run with -p to push."
  exit 0
fi

if $NEW_REMOTE_BRANCH; then
  git push --set-upstream origin "$BRANCH"
else
  git push origin "$BRANCH"
fi

info "pushed: $AHEAD commit(s) to $UPSTREAM"
