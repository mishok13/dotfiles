# NixOS Dotfiles Repository

## Repository Structure

- `home-manager/` — Home Manager configurations per profile
- `nixos/` — NixOS system configurations per host
- `nixos/<host>/hardware-configuration.nix` — Host-specific hardware config
- `nixos/common.nix` — Shared NixOS config (docker, tailscale, gitlab-runner, etc.)
- `orchestration/` — Ansible playbooks and Docker Compose templates (legacy, being migrated to NixOS)
- `flake.nix` — Nix flake entry point
- `Justfile` — Task runner commands

## Building and Deploying

### Home Manager (user environment)

```
just build <profile>    # Build home-manager config (default: current hostname)
just apply <profile>    # Apply home-manager config (default: current hostname)
```

### NixOS (system configuration)

```
just nixos-build <host>   # Build NixOS config on remote host
just nixos-switch <host>  # Build and apply NixOS config on remote host
```

These commands SSH into the target host, build remotely, and apply with sudo.
The `<host>` must be resolvable via SSH (either DNS, Tailscale, or SSH config).

### Docker Services (legacy, prefer NixOS systemd services)

```
just docker-services [hosts...]  # Deploy compose files via rsync+ssh
```

## NixOS Host Conventions

- Each host has a `nixos/<host>.nix` file and a `nixos/<host>/hardware-configuration.nix`
- Docker Compose stacks are embedded in nix config via `pkgs.writeText` and managed as systemd oneshot services
- Secrets use SOPS with age keys (`sops.secrets.*` in nix, `.sops.yaml` for key config)
- All hosts import `common.nix` (docker, tailscale, openssh, gitlab-runner, prometheus node exporter)

## Current Hosts

- **bigboi** — NixOS media server (immich, transmission, sonarr, radarr, prowlarr, NFS, Samba)
- **beafiboi** — NixOS (nvidia/CUDA, ollama, jellyfin, syncthing, NFS client)
- **tiniboi** — NixOS (caddy, grafana, prometheus, alertmanager, syncthing, NFS client)
- **orangepi** — Debian-based (managed via Ansible/compose)

## Known Issues

- `/etc/localtime` on NixOS is a symlink — do not bind-mount it into Docker containers; use `TZ` env var instead
- The `--exit-node=orangepi` in `common.nix` requires Tailscale to be connected first

## Workflow

- Use `just` for all build/deploy commands, not raw nix/nixos-rebuild
- Run `just nixos-build <host>` to verify changes before `just nixos-switch <host>`
- NixOS switch exits non-zero if any service fails (including tailscale) — check actual service status via `ssh <host> systemctl status <service>`
