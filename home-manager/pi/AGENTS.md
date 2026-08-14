# Global agent guidelines

## Git
- Every repository is managed by git.
- Do NOT commit, rebase, merge, or otherwise modify commit history without an explicit request from the user.

## just
- Prefer `just` for common repository tasks.
- Only use other tools when the `Justfile` (or other `just` config) does not cover what's needed.

## mise
- Prefer `mise` to manage and run required tools.
- Do NOT modify `mise.toml` or other `mise` configuration without explicit approval.
