# Global agent guidelines

* Never use jargon when replying to operator
* Aim for brevity when replying to operator

## Tools

### Git

- Every repository is managed by git.
- Never run `git commit` without the operator's explicit approval for that specific commit. Adding changes to
  staging area is allowed.
- Never rebase, merge, push, or otherwise modify commit history without an explicit request from the operator.
- When work is ready, stage the changes and ask for approval; propose a commit message and wait for a clear yes
  before committing.

### gh stack

- Always pass `--base <default-branch>` to `gh stack init`. Get the default branch from GitHub (`gh repo view --json defaultBranchRef -q .defaultBranchRef.name`), never from local `origin/HEAD`.
- Before any `gh stack push` / `submit` / `link`, check `gh stack view --json | jq -r .trunk` matches that branch. Stop if it does not.

### just

- Prefer `just` for common repository tasks.

### mise

- Prefer to access tools via `mise exec`
- Never modify `mise.toml` or other `mise` configuration without explicit approval
- Never use `mise` "tasks"

### Benchmarking

- Use `hyperfine` for benchmarking CLI scripts/tools

## Codebases

### Common

* YAGNI + KISS
* Functional core, imperative shell
* Prefer copy over DRY for simple or small code (e.g. less than 2 conditionals/loops, single level of nesting or
  up to 10 LoC)
* Clean Code is a red flag, avoid Uncle Bob's style
* Never add comments to new or existing code
* Avoid adding defensive guards anywhere but system boundaries
* Flat is better than nested
* Always run formatter, linter and type checker after changing code
* When fixing reported issues, start by writing test cases reproducing the issue on existing code before
  proceeding to fix the issue
* Use "boyscout rule" of improving existing code around the scoped changes.

### Python

* Never use `staticmethod` decorators
* Always add type annotations for application/library code
* Prefer dataclasses over tuples or dicts for return types
* Functions/methods should accept protocols/ABCs for arguments and return concrete types
* Functions with arity over 2 (except `self`/`cls`) should be written to accept only keyword-only parameters
  (e.g. `def x(*, foo, bar, baz)`)
* Avoid authoring docstrings unless explicitly prompted
* `TypedDict` is always preferable over bare `dict`
* Encode invariants using types
* Prefer unions of `Literal[str]` over `StrEnum`
* Use `py-spy` or `profiling.sampling` for profiling

### Rust

* Always use latest Rust edition for new projects
* Respect and fix clippy warnings
* Prefer `expect()` over `unwrap()`
* Use newtypes
* Use `eyre` for error handling
* Use `tracing` for observability
* Use `axum` for HTTP serving
* Use `criterion` for benchmarking
* Use `cargo flamegraph` for profiling

## Workflow

* Ensure tests and lints are green after making changes
* Every commit must be signed. If signing fails, stop and elicit response from operator. Don't bypass signing.
