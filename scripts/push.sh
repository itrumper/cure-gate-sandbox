#!/usr/bin/env sh
# The one way to push: runs the full scripts/check.sh, then `git push -u origin HEAD`. Red gate: nothing pushed.
# Why a script and not a `pre-push` hook (#619): git runs that hook after it opens the connection, so a long
# gate times it out. The gate's output is not redirected: callers quote it. Usage: scripts/push.sh (no arguments).
# It also scans the outgoing commits with gitleaks (a merge's resolution included) and refuses on a finding; without
# gitleaks it refuses any repo `gh` doesn't call PRIVATE.
set -eu
[ $# -eq 0 ] || { echo "usage: scripts/push.sh (no arguments)" >&2; exit 2; }
cd "$(git rev-parse --show-toplevel)"
dirty=$(git status --porcelain --untracked-files=all)
if [ -n "$dirty" ]; then
  echo "push.sh: the tree is not clean; commit or remove: $(printf '%s\n' "$dirty" | cut -c4- | tr '\n' ' ')" >&2
  exit 1
fi
# Secret scan of the outgoing commits (plan #1599 O5): gitleaks when installed; without it only a repo gh calls PRIVATE
# may push (a failed read refuses too).
if base=$(git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null); then :
else
  base=$(git symbolic-ref -q --short refs/remotes/origin/HEAD 2>/dev/null) || base=origin/main
  git rev-parse -q --verify "$base" >/dev/null 2>&1 || base=
fi
if command -v gitleaks >/dev/null 2>&1; then
  if ! gitleaks git -v --no-banner --redact --log-opts="--diff-merges=first-parent ${base:+$base..}HEAD" .; then
    echo "push.sh: gitleaks found a secret in the outgoing commits; nothing pushed" >&2
    exit 1
  fi
else
  vis=$(gh repo view --json visibility -q .visibility 2>/dev/null) || vis=
  if [ "$vis" != PRIVATE ]; then
    echo "push.sh: gitleaks is required to push a repo that is not PRIVATE (visibility: ${vis:-unknown}); brew install gitleaks" >&2
    exit 1
  fi
fi
if ! scripts/check.sh; then
  echo "push.sh: scripts/check.sh is red; nothing pushed" >&2
  exit 1
fi
git push -u origin HEAD
echo "push.sh: gate green, pushed $(git rev-parse --abbrev-ref HEAD)"
