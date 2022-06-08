export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

export PATH="$HOME/.poetry/bin:$PATH"

export COMPOSE_DOCKER_CLI_BUILD=1
export DOCKER_BUILDKIT=1

export RUST_SRC_PATH="$(rustc --print sysroot)/lib/rustlib/src/rust/library"
export ANSIBLE_NOCOWS=1
