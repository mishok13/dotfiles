---
name: create-pr
description: Create a pull request (GitHub) or merge request (GitLab) for the current git branch using the forge's CLI (gh/glab). Detects the forge from git remotes, diffs the current branch against the default branch, and drafts a title and body for the human to review. Use when the user asks to open/create a PR, MR, pull request, or merge request.
---

# Create PR / MR

Open a pull request (GitHub) or merge request (GitLab) for the current branch
using the forge's CLI, after drafting a title/body from the branch diff for the
operator to review and approve.

## Core rules

- **Never proceed without explicit human approval** of the drafted title and body.
- **Do not verify whether the branch was pushed.** Use a try-and-see approach:
  just run the CLI create command. If the CLI complains the branch is missing on
  the remote, report that and let the user decide whether to push.
- **Bail if the required CLI tool cannot be found** in `~/.nix-profile/bin`, via
  `mise exec`, or system-wide (`/usr/local/bin`, `/usr/bin`).
- **If the forge is unclear, stop and ask the user.** Do not guess.
- **If the diff is empty, stop and ask the user.** Do not open an empty PR/MR.

All scripts below live in this skill's `scripts/` directory. Invoke them with
their path relative to this SKILL.md.

## Workflow

### 1. Detect the forge

```bash
./scripts/detect-forge.sh          # prints: github | gitlab | unknown
git remote -v                      # for context / self-hosted inspection
```

If the result is `unknown` (e.g. a self-hosted instance whose hostname does not
contain `github`/`gitlab`), **elicit feedback from the user**: show them the
remotes and ask which forge this is. Do not continue until it is clear.

### 2. Resolve the CLI tool

- GitHub → `gh`
- GitLab → `glab`

```bash
./scripts/resolve-tool.sh gh       # or: ./scripts/resolve-tool.sh glab
```

The script prints the command prefix to use (an absolute path, or
`mise exec -- gh`). **If it exits non-zero, bail** and tell the user the tool is
not installed in any allowed location. Use exactly the printed prefix for every
CLI invocation.

### 3. Determine branches and compute the diff

```bash
CURRENT=$(git rev-parse --abbrev-ref HEAD)
DEFAULT=$(./scripts/default-branch.sh)     # e.g. main; empty if undetermined
```

If `DEFAULT` is empty, ask the user for the target/base branch.

Compute the diff of the current branch against the default branch. Prefer the
merge-base so only this branch's changes are considered:

```bash
git diff --stat "$DEFAULT"...HEAD
git log --oneline "$DEFAULT"..HEAD
git diff "$DEFAULT"...HEAD          # full diff for drafting the body
```

**If the diff is empty** (no changes and no commits between the branches),
**elicit feedback from the user** — the branch may not have diverged, may be the
wrong branch, or the base may be wrong. Do not proceed.

### 4. Draft title and body

From the commits and diff, draft:

- A concise, imperative **title** (mirror the commit subject if there is a single
  commit; otherwise summarize the branch).
- A **body** with a short summary of what changed and why, plus a brief bullet
  list of notable changes. Keep it factual to the diff.

Present the forge, target branch, tool invocation, drafted title, and body to the
user and **ask for explicit approval**. Offer them the chance to edit before
proceeding.

### 5. Create the PR/MR (only after approval)

Use the resolved tool prefix. Try-and-see — do not pre-check the push state.

GitHub (`gh`):

```bash
gh pr create --base "$DEFAULT" --head "$CURRENT" \
  --title "<approved title>" --body "<approved body>"
```

GitLab (`glab`):

```bash
glab mr create --target-branch "$DEFAULT" --source-branch "$CURRENT" \
  --title "<approved title>" --description "<approved body>"
```

If the command fails because the branch is not on the remote, report the exact
error and ask the user whether to push (e.g. `git push -u origin "$CURRENT"`) and
retry. Do not push automatically unless the user approves.

On success, share the PR/MR URL returned by the CLI.

## Notes

- Pass multi-line bodies safely, e.g. write the body to a temp file and use
  `--body-file` (gh) / `--description "$(cat file)"` (glab), or a quoted heredoc.
- `gh`/`glab` handle authentication themselves; do not attempt to manage tokens.
