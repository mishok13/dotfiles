# Global agent guidelines

* Never use jargon
* Keep output short
* Aim for brevity if asked for explanations

## Tools

### Git

- Every repository is managed by git.
- NEVER run `git commit` without the user's explicit approval for that specific commit. Staging changes is fine; creating the commit is not, until the user says so.
- Do NOT rebase, merge, push, or otherwise modify commit history without an explicit request from the user.
- When work is ready, stage the changes and ask for approval; propose a commit message and wait for a clear yes before committing.

### gh stack

- Always pass `--base <default-branch>` to `gh stack init`. Get the default branch from GitHub (`gh repo view --json defaultBranchRef -q .defaultBranchRef.name`), never from local `origin/HEAD`.
- Before any `gh stack push` / `submit` / `link`, check `gh stack view --json | jq -r .trunk` matches that branch. Stop if it does not.

### just

- Prefer `just` for common repository tasks.

### mise

- Prefer `mise` to manage and run required tools
- Do NOT modify `mise.toml` or other `mise` configuration without explicit approval

## Codebases

### Common

* YAGNI
* KISS
* Prefer copy over DRY for small code (less than 2 conditionals/loops, single level of nesting, up to 10 LoC)
* Clean Code is a red flag, avoid uncle bob's style
* Never comment code
* Avoid adding defensive guards, unless explicitly asked for
* Flat is better than nested
* Always run formatter, linter and type checker after changing code

### Python

* Never use `staticmethod` decorators
* Avoid types for test code
* Mandate type annotations for application/library code
* Prefer dataclasses over tuples or dicts for return types
* Function/methods should accept protocols/ABCs for arguments and return concrete types
* Avoid authoring docstrings
* `TypedDict` is always preferrable over bare `dict`

### Rust

* Always use latest Rust edition
* Respect and fix clippy warnings
* Prefer `expect()` over `unwrap()`
* Use newtypes
* Use `eyre` for error handling
* Use `tracing` for observability
* Use `axum` for HTTP handling

## Workflow

* Ensure tests and lints are green after making changes
* Every commit must be signed. If signing failures, stop and elicit response from operator
