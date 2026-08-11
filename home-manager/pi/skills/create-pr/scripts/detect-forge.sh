#!/usr/bin/env bash
# Best-effort forge detection from git remotes.
# Prints one of: github | gitlab | unknown
#
# "unknown" means the caller MUST elicit feedback from the user rather
# than guessing. Self-hosted instances often do not carry github/gitlab
# in the hostname, so treat "unknown" as an expected outcome.
set -euo pipefail

remote="${1:-origin}"

url="$(git remote get-url "$remote" 2>/dev/null || true)"
if [ -z "$url" ]; then
  # Fall back to the first configured remote, if any.
  first="$(git remote 2>/dev/null | head -n1 || true)"
  if [ -n "$first" ]; then
    url="$(git remote get-url "$first" 2>/dev/null || true)"
  fi
fi

if [ -z "$url" ]; then
  echo "unknown"
  exit 0
fi

case "$url" in
  *github.com*) echo "github" ;;
  *gitlab*)     echo "gitlab" ;;
  *)            echo "unknown" ;;
esac
