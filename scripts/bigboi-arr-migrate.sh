#!/usr/bin/env bash
#
# Migrate transmission / sonarr / radarr / prowlarr config data from the old
# Docker containers (bind-mounted under /home/mishok13/.config) into the native
# NixOS service data directories.
#
# Background: on bigboi the media Docker stack and the immich Docker stack both
# resolved to the same docker-compose project name ("store", the basename of
# /nix/store), so each stack's `up -d --remove-orphans` deleted the other stack's
# containers. The sonarr/radarr/prowlarr/transmission *containers* were destroyed,
# but their bind-mounted config data survived intact. We now run these as native
# NixOS services and copy that surviving data into the new data dirs.
#
# Run this AFTER `just nixos-switch bigboi` (which creates the services, users
# and data dirs), ON bigboi, as root:
#
#     sudo /path/to/bigboi-arr-migrate.sh
#
# It is safe to re-run: it stops each service, overwrites the (freshly created,
# empty) data dir with the old config, fixes ownership, then restarts.
# The old Docker config dirs are COPIED, not moved, so they remain as a fallback.

set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "This script must run as root (needs to chown into /var/lib)." >&2
  exit 1
fi

SRC_BASE="/home/mishok13/.config"

log() { printf '\n\033[1;34m==>\033[0m %s\n' "$*"; }

# Copy a config tree, preserving everything except the pid file, without
# preserving source ownership (target ownership is fixed by the caller).
copy_tree() {
  local src="$1" dst="$2"
  mkdir -p "$dst"
  rsync -a --no-owner --no-group --delete \
    --exclude='*.pid' \
    "$src/" "$dst/"
}

migrate_static() {
  # For services running as a fixed user (sonarr, radarr).
  local name="$1" datadir="$2" owner="$3"
  local src="${SRC_BASE}/${name}"

  if [[ ! -f "${src}/${name}.db" ]]; then
    echo "  !! ${src}/${name}.db not found; skipping ${name}" >&2
    return 1
  fi

  log "Migrating ${name} -> ${datadir} (owner ${owner})"
  systemctl stop "${name}.service" || true
  copy_tree "${src}" "${datadir}"
  chown -R "${owner}" "$(dirname "${datadir}")"   # e.g. /var/lib/sonarr
  systemctl start "${name}.service"
}

migrate_prowlarr() {
  # prowlarr uses systemd DynamicUser + StateDirectory, so its real data lives
  # at /var/lib/private/prowlarr and is owned by a dynamically allocated UID.
  local name="prowlarr"
  local src="${SRC_BASE}/${name}"
  local priv="/var/lib/private/prowlarr"

  if [[ ! -f "${src}/${name}.db" ]]; then
    echo "  !! ${src}/${name}.db not found; skipping ${name}" >&2
    return 1
  fi

  log "Migrating ${name} -> ${priv} (DynamicUser)"
  # Start once so systemd creates the private state dir + owner + the
  # /var/lib/prowlarr symlink, then stop before we overwrite it.
  systemctl start "${name}.service"
  systemctl stop "${name}.service"

  local owner
  owner="$(stat -c '%u:%g' "${priv}")"
  echo "  detected DynamicUser owner: ${owner}"

  copy_tree "${src}" "${priv}"
  chown -R "${owner}" "${priv}"
  systemctl start "${name}.service"
}

migrate_transmission() {
  # transmission runs as mishok13:users. Its settings.json is regenerated
  # declaratively by the NixOS module on every start, so we migrate ONLY the
  # torrent state (torrents/ + resume/) and a few stateful extras, never
  # settings.json. The config dir lives under ${home}/.config/transmission-daemon.
  local src="${SRC_BASE}/transmission"
  local dst="/var/lib/transmission/.config/transmission-daemon"

  if [[ ! -d "${src}/resume" ]]; then
    echo "  !! ${src}/resume not found; skipping transmission" >&2
    return 1
  fi

  log "Migrating transmission -> ${dst} (owner mishok13:users)"
  systemctl stop transmission.service || true
  mkdir -p "${dst}"
  # Copy torrent state and extras, but NOT settings.json (module-managed) and
  # NOT the pid file.
  rsync -a --no-owner --no-group \
    --exclude='settings.json' \
    --exclude='*.pid' \
    "${src}/torrents" "${src}/resume" \
    "${src}/blocklists" "${src}/dht.dat" \
    "${src}/stats.json" "${src}/bandwidth-groups.json" \
    "${dst}/" 2>/dev/null || true
  chown -R mishok13:users /var/lib/transmission
  systemctl start transmission.service
}

migrate_transmission
migrate_static "sonarr" "/var/lib/sonarr/.config/NzbDrone" "mishok13:users"
migrate_static "radarr" "/var/lib/radarr/.config/Radarr"   "mishok13:users"
migrate_prowlarr

log "Done. Verify with:"
cat <<'EOF'
  systemctl status transmission sonarr radarr prowlarr --no-pager
  curl -s -o /dev/null -w '%{http_code}\n' http://localhost:9091/transmission/web/  # transmission
  curl -s -o /dev/null -w '%{http_code}\n' http://localhost:8989/  # sonarr
  curl -s -o /dev/null -w '%{http_code}\n' http://localhost:7878/  # radarr
  curl -s -o /dev/null -w '%{http_code}\n' http://localhost:9696/  # prowlarr
  transmission-remote 127.0.0.1:9091 -n admin:admin -l | tail    # torrents loaded

Old Docker config dirs are left in place as a fallback:
  /home/mishok13/.config/{transmission,sonarr,radarr,prowlarr}
Additional full snapshots exist on the media disk:
  /mnt/media/config-backup-20260627  (and .../config-backup-20260620)
EOF
