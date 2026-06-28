# BigBoi NixOS Migration Plan

## Current State Analysis

### System Status
**bigboi** is currently running **Debian 13 (trixie)** with partial NixOS preparation:

**Hardware:**
- CPU: AMD x86_64
- RAM: 16GB total (⚠️ **Swap is 100% full** - 976Mi/976Mi)
- Storage:
  - nvme0n1 (931.5G): Main OS disk (**⚠️ disk-level ZFS label present** — leftover from prior attempt)
    - nvme0n1p1 (512M): EFI boot partition (vfat)
    - nvme0n1p2 (930G): ext4 root (8% used - 65G/804G free)
    - nvme0n1p3 (977M): Swap (100% full)
  - 4x 3.6TB HDDs (sda/sdb/sdc/sdd): **btrfs multi-device array** (UUID `2859e9fb-fac5-4726-acbd-3e2b4a6126fe`), mounted at `/mnt/media` via sdb; 4.2T used / 3.1T free

**Active Services:**
- **Docker containers (via `~/.config/compose.yaml`):** Immich server + ML + postgres + redis, Sonarr, Radarr, Prowlarr, Transmission
- **Web server:** Caddy is installed and running but serves only the default Debian template — it is **not used by bigboi**; the `~/.config/Caddyfile` belongs to another host's dotfiles config and is incidental
- **File sharing:** NFS (active, two exports) + Samba (installed but no custom shares — effectively unused)
- **CI/CD:** GitLab Runner
- **Networking:** Tailscale
- **Monitoring:** Prometheus node exporter, Prometheus server, Grafana (via `~/.config/compose/monitoring.yaml`)

**NixOS Preparation:**
- ✅ `/etc/nixos/configuration.nix` exists (mostly template, stateVersion 26.05)
- ✅ `/etc/nixos/hardware-configuration.nix` auto-generated with current disk layout
- ✅ Nix 2.33.0 is installed and in PATH (single-user installation via `.profile`)
- ✅ `bigboi` configuration exists in dotfiles flake (`nixos/bigboi.nix`, `nixos/bigboi/hardware-configuration.nix`, entry in `flake.nix`)
- ✅ `nixos/common.nix` exists with base config (includes Docker, GitLab Runner, Tailscale, NFS, etc.)
- ✅ `bigboi.nix` already configures NFS exports and Samba (read-only public share at `/mnt/media`)
- ⚠️ `bigboi` age key was missing from `.sops.yaml` — added, secrets need re-encryption
- ⚠️ `hardware-configuration.nix` used `/dev/sdb` for btrfs mount — fixed to use UUID

### Data at Risk on Root Partition
Everything under `/home/mishok13/.config/` will be **wiped** when the root partition is reformatted:

| Path | Contents | Criticality |
|------|----------|-------------|
| `~/.config/share/immich-db/` | Immich PostgreSQL database | **CRITICAL** |
| `~/.config/sonarr/` | Sonarr config + history | High |
| `~/.config/radarr/` | Radarr config + history | High |
| `~/.config/prowlarr/` | Prowlarr config | High |
| `~/.config/transmission/` | Transmission config | Medium |
| `~/.config/Caddyfile` | Caddy config (belongs to another host — back up anyway) | Low |
| `~/.config/compose.yaml` | Root compose file | High |
| `~/.config/compose-bigboi.yaml` | Bigboi-specific compose overrides | High |
| `~/.config/compose/` | All per-service compose definitions | High |
| `~/.config/prometheus.yml` | Prometheus scrape config | Medium |
| `~/.config/grafana.ini` | Grafana config | Medium |
| `~/.config/gitlab-runner.toml.j2` | GitLab Runner config template | Medium |

### NFS Exports (current `/etc/exports`)
```
/mnt/media/share  100.64.0.0/10(rw,no_subtree_check,fsid=0)  192.168.0.0/24(rw,no_subtree_check,fsid=0)  192.168.0.20(rw,no_subtree_check,insecure,fsid=0)
/mnt/media        100.64.0.0/10(ro,no_subtree_check,fsid=1)   192.168.0.0/24(ro,no_subtree_check,fsid=1)  192.168.0.20(ro,no_subtree_check,insecure,fsid=1)
```

### Secrets Needed in SOPS
- Immich DB password (`858675bbcdb5101c` — currently plaintext in compose file)
- Transmission username/password (currently `admin`/`admin` in compose — change on migration)
- GitLab Runner registration token (in `/etc/gitlab-runner/config.toml`)

## Action Plan

### Phase 0: Pre-Migration Data Safety (do this first, before anything else)

0. **Move critical data off root partition to `/mnt/media/`**
   ```bash
   ssh bigboi "cp -a ~/.config /mnt/media/config-backup-$(date +%Y%m%d)"
   ```
   This ensures all service configs and the Immich DB survive root partition wipe.

1. **Move Immich DB to data drive** (so it's safe AND available post-install without restore)
   - Stop Immich containers
   - Move `~/.config/share/immich-db/` to `/mnt/media/immich-db/`
   - Update `~/.config/compose/immich.yaml` volume path
   - Restart and verify Immich works from new path

2. **Add secrets to SOPS**
   - Immich DB password (rotate while at it)
   - GitLab Runner token

### Phase 1: Pre-Migration Preparation

3. **Create bigboi NixOS configuration in dotfiles**
   - Add `bigboi` to `flake.nix` nixosConfigurations
   - Create `nixos/bigboi.nix` importing `common.nix`
   - Configure services: NFS exports (copy from above), Docker Compose setup
   - Include all services: Immich, Sonarr, Radarr, Prowlarr, Transmission, Prometheus, Grafana
   - **Do not include Caddy** — not used on bigboi
   - **Do not include Samba** — smb.conf is the Debian default with no custom shares; confirm it's unused before adding

4. **Handle ZFS label on nvme0n1**
   - The block device (not its partitions) carries a `zfs_member` label from a prior attempt
   - This may confuse nixos-anywhere's disko or disk detection
   - Wipe it before migration: `ssh bigboi "sudo zpool labelclear -f /dev/nvme0n1"` (or handle in disko config)

5. **Fix swap / memory pressure**
   - Top consumers: immich ML (~580MB), postgres (~530MB), immich-api (~430MB), radarr/sonarr/prowlarr (~200MB each), tailscaled (~175MB), transmission (~155MB)
   - Restarting containers may free swap without any deeper fix
   - kexec needs available RAM — ensure swap is not exhausted before attempting

### Phase 2: NixOS Installation via kexec

6. **Use nixos-anywhere or manual kexec**
   - Option A: Use `nixos-anywhere` tool (recommended, automated)
   - Option B: Manual kexec approach:
     ```bash
     curl -L https://github.com/nix-community/nixos-images/releases/latest/download/nixos-kexec-installer-noninteractive-x86_64-linux.tar.gz | tar -xzf- -C /root
     /root/kexec/run
     ```

7. **After kexec boots into NixOS installer (running in RAM)**
   - System will be running NixOS entirely from RAM
   - Original disk remains untouched
   - Can SSH back in to continue installation

### Phase 3: NixOS Installation

8. **Partition and format**
   - Reuse existing EFI partition (nvme0n1p1)
   - Reformat nvme0n1p2 as ext4 (or btrfs) for root
   - Keep nvme0n1p3 as swap
   - btrfs data array (sda/sdb/sdc/sdd) is untouched — mount by UUID in hardware config

9. **Install NixOS from flake**
   ```bash
   nixos-install --flake github:mishok13/dotfiles#bigboi
   ```

10. **Reboot into NixOS**

### Phase 4: Service Restoration

11. **Restore service configs from backup**
    - Copy `~/.config/` back from `/mnt/media/config-backup-*/` (or use the live path if Phase 0 step 1 was done)
    - Verify Immich DB is at `/mnt/media/immich-db/` (or restore from backup)

12. **Start Docker containers**
    ```bash
    docker compose -f ~/.config/compose.yaml up -d
    ```
    - Verify Immich, Sonarr, Radarr, Prowlarr, Transmission start correctly

13. **Configure and test services**
    - NFS: verify exports match `/etc/exports` above
    - GitLab Runner: re-register or restore `config.toml`
    - Tailscale: `tailscale up` and verify

14. **Verify data integrity**
    - Check btrfs array mounts correctly (all 4 drives, by UUID)
    - Verify NFS exports accessible from clients
    - Test Immich photo library

## Critical Risks

### HIGH RISK

1. **Immich DB on root partition**
   - `~/.config/share/immich-db/` is wiped when root is reformatted
   - **Mitigation:** Phase 0 step 1 — move DB to `/mnt/media/immich-db/` before any migration work

2. **All service configs on root partition**
   - `~/.config/` contains configs for every service
   - **Mitigation:** Phase 0 step 0 — `cp -a ~/.config /mnt/media/config-backup-$(date +%Y%m%d)` immediately

3. **Swap is 100% full**
   - kexec requires booting into RAM-only environment
   - May cause instability during migration
   - **Mitigation:** Restart containers to reclaim swap before kexec

4. **ZFS label on nvme0n1 may confuse disk tooling**
   - nixos-anywhere / disko may fail or behave unexpectedly
   - **Mitigation:** `zpool labelclear -f /dev/nvme0n1` before starting, or handle in disko config

5. **Running services during migration**
   - All services go offline during kexec/install
   - **Mitigation:** Plan maintenance window, complete Phase 0 first

### MEDIUM RISK

6. **SSH access loss**
   - If kexec fails, SSH might not reconnect
   - **Mitigation:** Physical access required as backup; no IPMI/BMC mentioned — confirm physical access

7. **Complex service surface**
   - More services than originally documented (Prometheus, Grafana)
   - **Mitigation:** Use `~/.config/compose/` as source of truth; restore via compose files

9. **btrfs multi-device mount**
   - All 4 drives share one UUID; NixOS hardware config must mount by UUID (not device name)
   - Device names (sda/sdb/sdc/sdd) may change across reboots
   - **Mitigation:** Mount by UUID in `hardware-configuration.nix`

### LOW RISK

10. **Boot configuration**
    - Switching from GRUB to systemd-boot
    - **Mitigation:** Usually fine; have USB recovery stick ready

11. **Samba**
    - `smb.conf` is the unmodified Debian default — no custom shares configured
    - Confirm with `net usershare list` before deciding whether to include in NixOS config

## Recommended Next Steps

1. **Immediate (before anything else):** `ssh bigboi "cp -a ~/.config /mnt/media/config-backup-$(date +%Y%m%d)"`
2. **Move Immich DB** to `/mnt/media/immich-db/` and update compose volume path
3. **Add secrets to SOPS** (Immich DB password)
4. **Wipe ZFS label:** `ssh bigboi "sudo zpool labelclear -f /dev/nvme0n1"`
5. **Create bigboi NixOS configuration** in dotfiles flake
6. **Schedule maintenance window** and execute migration

## Sources
- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Quickstart - nixos-anywhere](https://nix-community.github.io/nixos-anywhere/quickstart.html)
- [GitHub - nixos-anywhere](https://github.com/nix-community/nixos-anywhere)
- [kexec-based installer gist](https://gist.github.com/Mic92/4fdf9a55131a7452f97003f445294f97)
- [NixOS Wiki - Install on Server](https://nixos.wiki/wiki/Install_NixOS_on_a_Server_With_a_Different_Filesystem)
