#!/usr/bin/env bash
# Resolve the invocation for a forge CLI tool (e.g. gh, glab).
#
# Search order (per skill requirements):
#   1. ~/.nix-profile/bin/<tool>
#   2. mise (via `mise exec -- <tool>`)
#   3. system-wide (/usr/local/bin, /usr/bin)
#
# On success prints the command prefix to invoke the tool and exits 0.
# On failure prints an error to stderr and exits 1 (caller MUST bail).
set -euo pipefail

tool="${1:?usage: resolve-tool.sh <tool-name>}"

# 1. Nix profile
if [ -x "$HOME/.nix-profile/bin/$tool" ]; then
  printf '%s\n' "$HOME/.nix-profile/bin/$tool"
  exit 0
fi

# 2. mise
if command -v mise >/dev/null 2>&1; then
  if mise which "$tool" >/dev/null 2>&1; then
    printf 'mise exec -- %s\n' "$tool"
    exit 0
  fi
fi

# 3. System-wide
for p in "/usr/local/bin/$tool" "/usr/bin/$tool"; do
  if [ -x "$p" ]; then
    printf '%s\n' "$p"
    exit 0
  fi
done

echo "ERROR: '$tool' not found in ~/.nix-profile/bin, via mise, or in /usr/local/bin /usr/bin" >&2
echo "Install '$tool' in one of those locations before creating a PR/MR." >&2
exit 1
