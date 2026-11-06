#!/usr/bin/env bash
# Commit and/or push changes from the repos listed in a plain text file.
# Usage: git-autopush.sh [-p] [REPOS_FILE]
#   -p   actually push; without it nothing is sent
#
# REPOS_FILE defaults to repos-auto-push next to this script. That file is
# gitignored; copy repos-auto-push.example to create it.
#
# Lines of REPOS_FILE: "<path> <mode>", mode is "commit" or "push".
#   commit   commit all changes (git add -A) before pushing
#   push     never commit; refuse to run if the tree is dirty
# Blank lines and lines starting with # are ignored. Every entry is attempted;
# the script exits non-zero if any of them failed.
#
# Refuses on divergence, and refuses to push commits that look like they
# contain secrets. Never pulls, merges, rebases, or resets.

set -euo pipefail

DRY_RUN=true

usage() {
  printf 'usage: %s [-p] [REPOS_FILE]\n' "${0##*/}" >&2
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

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
REPOS_FILE="${1:-$SCRIPT_DIR/repos-auto-push}"

die() { printf 'error: %s\n' "$1" >&2; exit 1; }
info() { printf '%s\n' "$*"; }

if [[ ! -f $REPOS_FILE ]]; then
  printf 'error: no repo list: %s\n' "$REPOS_FILE" >&2
  printf 'copy %s.example to %s and edit it\n' "${REPOS_FILE%.example}" "$REPOS_FILE" >&2
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

# Scan files that are not in git yet: only their current contents exist, so the
# whole file is read. Binary files are skipped.
scan_paths() {
  local found=0 file

  for file in "$@"; do
    case "${file##*/}" in
      *.example|*.sample|*.template) continue ;;
    esac
    if grep -Iq . -- "$file" 2>/dev/null && grep -Eq -- "$SECRET_RE" "$file" 2>/dev/null; then
      printf '  secret-risk: %s\n' "$file"
      found=1
    fi
  done

  return "$found"
}

# --- one repo ------------------------------------------------------------------
process_repo() {
    local DIR=$1 DO_COMMIT=$2
    local COMMIT_PENDING=false

    [[ -d $DIR ]] || { printf 'error: not a directory: %s\n' "$DIR" >&2; return 1; }
    cd -- "$DIR" || { printf 'error: cannot enter %s\n' "$DIR" >&2; return 1; }
    git rev-parse --git-dir >/dev/null 2>&1 \
      || { printf 'error: not a git repository: %s\n' "$DIR" >&2; return 1; }

    local REMOTE BRANCH
    REMOTE=$(git config --get remote.origin.url) \
      || { printf "error: no 'origin' remote in %s\n" "$DIR" >&2; return 1; }
    BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null) \
      || { printf 'error: detached HEAD in %s; check out a branch first\n' "$DIR" >&2; return 1; }

    info "repo:   $DIR"
    info "remote: $REMOTE"
    info "branch: $BRANCH"

  # --- commit (only when the entry says "commit") --------------------------------
  # A "push" entry never creates commits. A dirty tree usually means you forgot
  # to commit, so stop and say what is pending.
  if [[ -n $(git status --porcelain) ]]; then
    if ! $DO_COMMIT; then
      printf 'error: uncommitted changes in %s\n\n' "$DIR" >&2
      git status --short | sed 's/^/  /' >&2
      printf '\nCommit or discard them first; re-run with a repo listed as "commit".\n' >&2
      return 1
    fi

    # Check the worktree before it becomes history: once committed, a secret in
    # it needs a history rewrite to remove, not just an edit.
    if [[ -n $(git ls-files --others --exclude-standard) ]]; then
      info ""
      info "checking new untracked files for secrets"
      if ! scan_paths $(git ls-files --others --exclude-standard); then
        printf '\nrefusing to commit: possible secrets in the files above.\n' >&2
        printf 'Remove them, or add them to .gitignore.\n' >&2
        return 1
      fi
    fi

    MSG="sync: $(hostname -s) $(date '+%Y-%m-%d %H:%M') ($(git status --porcelain | wc -l | tr -d ' ') files)"

    if $DRY_RUN; then
      info ""
      info "would commit: $MSG"
      COMMIT_PENDING=true
    else
      git add -A
      git commit --quiet -m "$MSG" || { printf 'error: commit failed in %s\n' "$DIR" >&2; return 1; }
      info ""
      info "committed: $MSG"
    fi
  fi

  # --- state -------------------------------------------------------------------
  # A concurrent git command holding the index means the tree is moving under
  # us. Wait for it rather than committing a half-updated index.
  LOCK=$(git rev-parse --git-path index.lock)
  for _ in 1 2 3 4 5 6; do
    [[ -e $LOCK ]] || break
    sleep 10
  done
  if [[ -e $LOCK ]]; then
    printf 'error: index.lock still held by another git process in %s; giving up\n' "$DIR" >&2
    return 1
  fi

  git fetch --quiet origin || { printf 'error: cannot reach remote %s\n' "$REMOTE" >&2; return 1; }

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

  # --- divergence is a hard stop ------------------------------------------------
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
    return 1
  fi

  # --- nothing to push ----------------------------------------------------------
  if (( AHEAD == 0 )); then
    info ""
    info "nothing to push: in sync with $UPSTREAM"
    if $DRY_RUN; then
      if $COMMIT_PENDING; then
        info "dry run: the commit above was not made."
      fi
      info "dry run: nothing sent. Re-run with -p to push."
    fi
    return 0
  fi

  info ""
  info "outgoing commits:"
  git --no-pager log --oneline --no-decorate "$RANGE" | sed 's/^/  /'

  info ""
  info "checking outgoing changes for secrets"
  if ! scan_outgoing "$RANGE"; then
    printf '\nrefusing to push: possible secrets in the commits above.\n' >&2
    printf 'Fix the history (or delete the local commits) before pushing.\n' >&2
    return 1
  fi

  if $DRY_RUN; then
    info ""
    info "would push: $AHEAD commit(s) to $UPSTREAM"
    if $COMMIT_PENDING; then
      info "dry run: the commit above was not made."
    fi
    info "dry run: nothing sent. Re-run with -p to push."
    return 0
  fi

  if $NEW_REMOTE_BRANCH; then
    git push --set-upstream origin "$BRANCH"
  else
    git push origin "$BRANCH"
  fi

  info "pushed: $AHEAD commit(s) to $UPSTREAM"
}

# --- every listed repo -----------------------------------------------------------
FAILED=()
ENTRY=0

while IFS= read -r line || [[ -n $line ]]; do
  ENTRY=$((ENTRY + 1))
  line="${line#"${line%%[![:space:]]*}"}"
  line="${line%"${line##*[![:space:]]}"}"
  [[ -z $line || $line == \#* ]] && continue

  read -r path mode extra <<<"$line"
  if [[ -z ${mode:-} || -n ${extra:-} ]]; then
    printf '%s:%d: expected "<path> <commit|push>", got: %s\n' "$REPOS_FILE" "$ENTRY" "$line" >&2
    FAILED+=("$REPOS_FILE:$ENTRY")
    continue
  fi
  case "$mode" in
    commit) do_commit=true ;;
    push)   do_commit=false ;;
    *)
      printf '%s:%d: unknown mode '%s' (expected commit or push)\n' "$REPOS_FILE" "$ENTRY" "$mode" >&2
      FAILED+=("$path")
      continue
      ;;
  esac

  info ""
  info "=== $path ($mode) ==="
  if ! process_repo "$path" "$do_commit"; then
    FAILED+=("$path")
  fi
done <"$REPOS_FILE"

info ""
if (( ${#FAILED[@]} )); then
  printf 'failed: %s\n' "${FAILED[*]}" >&2
  exit 1
fi
info "all listed repos handled"
