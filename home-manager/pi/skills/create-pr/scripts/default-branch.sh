#!/usr/bin/env bash
# Print the default branch of the repo without hitting the network.
# Prints the short branch name (e.g. "main") or nothing on failure.
set -euo pipefail

remote="${1:-origin}"

# 1. Symbolic ref set by `git remote set-head` / clone.
if ref="$(git symbolic-ref -q --short "refs/remotes/$remote/HEAD" 2>/dev/null)"; then
  printf '%s\n' "${ref#"$remote"/}"
  exit 0
fi

# 2. Common conventional names that exist locally as remote-tracking refs.
for b in main master trunk develop; do
  if git show-ref -q --verify "refs/remotes/$remote/$b" 2>/dev/null; then
    printf '%s\n' "$b"
    exit 0
  fi
done

# 3. Local branches as a last resort.
for b in main master trunk develop; do
  if git show-ref -q --verify "refs/heads/$b" 2>/dev/null; then
    printf '%s\n' "$b"
    exit 0
  fi
done

exit 1
