# Home Manager config

## Overview

This is a Nix Home Manager flake-based configuration for home dir.

## Common Commands

Build and apply configurations using the Justfile:
- `just build [profile]` - Build a home-manager profile (default: mishok13)
- `just apply [profile]` - Apply (switch to) a home-manager profile (default: mishok13)

Direct home-manager commands:
- `home-manager build --flake .#mishok13` - Build the default profile
- `home-manager switch --flake .#mishok13` - Build and activate the profile

## Architecture

### Multi-Platform Configuration

The flake defines 2 home configurations:
- `mishok13` (default) - x86_64-linux configuration, can be built for other platforms via `mkHomeConfiguration`
- `wsl` - WSL2-specific with custom 1Password and SSH paths

Platform-specific differences are handled via:
- `commitSignProgram` - 1Password SSH signing path differs between macOS
  (`/Applications/1Password.app/Contents/MacOS/op-ssh-sign`), Linux (`/opt/1Password/op-ssh-sign`), and WSL
  (`/mnt/c/Users/mishok13/AppData/Local/1Password/app/8/op-ssh-sign-wsl`)
- `sshCommand` - WSL uses `ssh.exe`, all other platforms use `ssh`

### Module Structure

Configuration is split into modular files imported by `home.nix`:
- `gui.nix` - GUI applications (kitty terminal, fonts, emacs)
- `terminal.nix` - CLI tools and shell configuration (fish, git, atuin, ripgrep, etc.)

### Dependencies

External inputs:
- `nixpkgs` (nixos-unstable channel)
- `home-manager` (nix-community)
- `nixgl` (for OpenGL support on non-NixOS systems)
- `nix-ai-tools` (provides LLM CLI tools like claude-code, amp, goose-cli, etc.)

The `pkgsLLM` variable exposes AI tools from nix-ai-tools to the configuration.

## Development

### Testing

All changes to nix files MUST be followed by `just build`. Any change that breaks the output must be fixed
before proceeding.

After build suceeds, run `pre-commit run -a` or (better) `pre-commit run --files path/to/changed/file.nix`.

## Documentation

Use the following:

* Home Manager docs https://nix-community.github.io/home-manager/
* Nix language reference https://nix.dev/manual/nix/2.32/
