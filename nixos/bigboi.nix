{
  config,
  lib,
  pkgs,
  ...
}:

let
  immichCompose = pkgs.writeText "immich-compose.yaml" ''
    services:

      immich-server:
        container_name: immich_server
        image: ghcr.io/immich-app/immich-server:v2.7.5@sha256:c15bff75068effb03f4355997d03dc7e0fc58720c2b54ad6f7f10d1bc57efaa5
        devices:
          - /dev/dri:/dev/dri
        volumes:
          - /mnt/media/immich:/usr/src/app/upload
        environment:
          DB_PASSWORD: "858675bbcdb5101c"
          DB_USERNAME: "postgres"
          DB_DATABASE_NAME: "immich"
          DB_HOSTNAME: "immich-db"
          REDIS_HOSTNAME: "immich-redis"
        ports:
          - "2283:2283"
        depends_on:
          - immich-redis
          - immich-db
        restart: always
        healthcheck:
          disable: false

      immich-machine-learning:
        container_name: immich_machine_learning
        image: ghcr.io/immich-app/immich-machine-learning:v2.7.5@sha256:a2501141440f10516d329fdfba2c68082e19eb9ba6016c061ac80d23beadf7f3
        volumes:
          - model-cache:/cache
        restart: always
        healthcheck:
          disable: false

      immich-redis:
        container_name: immich_redis
        image: docker.io/valkey/valkey:8.1.3-bookworm@sha256:fea8b3e67b15729d4bb70589eb03367bab9ad1ee89c876f54327fc7c6e618571
        healthcheck:
          test: redis-cli ping || exit 1
        restart: always

      immich-db:
        container_name: immich_postgres
        image: ghcr.io/immich-app/postgres:16-vectorchord0.3.0-pgvectors0.2.0@sha256:5b434f184ec644c4e1a4076e2e7d4bee45631646a52e956b5ff74ac51e79cc00
        environment:
          POSTGRES_PASSWORD: "858675bbcdb5101c"
          POSTGRES_USER: postgres
          POSTGRES_DB: immich
          POSTGRES_INITDB_ARGS: "--data-checksums"
        volumes:
          - /mnt/media/immich-db:/var/lib/postgresql/data
        restart: always

    volumes:
      model-cache:
  '';
in

{
  imports = [
    ./common.nix
    ./user.nix
    ./remote-builder.nix
    ./blocky.nix
    ./bigboi/caddy.nix
    ./bigboi/hardware-configuration.nix
  ];

  networking.hostName = "bigboi";

  services.nfs.server = {
    enable = true;
    exports = ''
      /mnt/media/share 100.64.0.0/10(rw,no_subtree_check,fsid=0) 192.168.0.0/24(rw,no_subtree_check,fsid=0) 192.168.0.20(rw,no_subtree_check,insecure,fsid=0)
      /mnt/media 100.64.0.0/10(ro,no_subtree_check,fsid=1) 192.168.0.0/24(ro,no_subtree_check,fsid=1) 192.168.0.20(ro,no_subtree_check,insecure,fsid=1)
    '';
  };

  networking.firewall.allowedTCPPorts = [
    2049
    2283
    7878
    8989
    9091
    9696
    51413
  ];
  networking.firewall.allowedUDPPorts = [
    2049
    51413
  ];

  # Immich via Docker Compose
  # TODO: move DB password to sops secret
  systemd.services.immich = {
    description = "Immich photo management";
    after = [
      "docker.service"
      "network-online.target"
    ];
    wants = [ "network-online.target" ];
    requires = [ "docker.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      # immich is now the only Docker Compose stack on this host, so the old
      # docker-compose project-name collision (both stacks resolved to "store",
      # the basename of /nix/store, and each `--remove-orphans` wiped the other)
      # can no longer happen. The media stack is now native systemd services below.
      ExecStart = "${pkgs.docker-compose}/bin/docker-compose -f ${immichCompose} up -d --remove-orphans";
      ExecStop = "${pkgs.docker-compose}/bin/docker-compose -f ${immichCompose} down";
    };
  };

  # ---------------------------------------------------------------------------
  # Media stack, now fully native NixOS services (was Docker Compose before).
  #
  # transmission, sonarr and radarr run as mishok13:users (uid 1000) to preserve
  # ownership of the existing /mnt/media library, exactly as the old containers
  # did with PUID/PGID=1000. prowlarr never touches the library, so it keeps the
  # module's hardened DynamicUser.
  #
  # Data is migrated from the old Docker bind-mount config dirs under
  # /home/mishok13/.config/{transmission,sonarr,radarr,prowlarr} into the native
  # data dirs by scripts/bigboi-arr-migrate.sh (run once after switching).
  # ---------------------------------------------------------------------------

  # Reproduce the old container bind mounts on the host so that existing state
  # keeps resolving without rewriting it: transmission's 102 .resume files
  # reference /downloads/... and /watch, and sonarr/radarr store their root
  # folders and per-item paths as /tv and /movies (the old container mount
  # points). There were no remote path mappings, so the native services import
  # from and write to exactly these paths.
  fileSystems."/downloads" = {
    device = "/mnt/media/downloads";
    fsType = "none";
    options = [
      "bind"
      "x-systemd.requires-mounts-for=/mnt/media"
    ];
  };
  fileSystems."/watch" = {
    device = "/mnt/media/transmission/watch";
    fsType = "none";
    options = [
      "bind"
      "x-systemd.requires-mounts-for=/mnt/media"
    ];
  };
  fileSystems."/tv" = {
    device = "/mnt/media/tv";
    fsType = "none";
    options = [
      "bind"
      "x-systemd.requires-mounts-for=/mnt/media"
    ];
  };
  fileSystems."/movies" = {
    device = "/mnt/media/movies";
    fsType = "none";
    options = [
      "bind"
      "x-systemd.requires-mounts-for=/mnt/media"
    ];
  };

  services.transmission = {
    enable = true;
    user = "mishok13";
    group = "users";
    # Config (settings.json is regenerated from `settings` on every start; the
    # torrents/ and resume/ state is migrated into the data dir separately).
    settings = {
      download-dir = "/downloads/complete";
      incomplete-dir = "/downloads/incomplete";
      incomplete-dir-enabled = true;
      watch-dir = "/watch";
      watch-dir-enabled = true;

      peer-port = 51413;
      port-forwarding-enabled = true;
      utp-enabled = false;
      umask = "002";

      rpc-enabled = true;
      rpc-bind-address = "0.0.0.0";
      rpc-port = 9091;
      rpc-url = "/transmission/";
      # No RPC auth: transmission is only reachable on the LAN/tailnet and via the
      # transmission.mishok13.me reverse proxy on bigboi, which is a strong enough
      # boundary here. The migrated sonarr/radarr download clients connect fine
      # without credentials (any Basic-auth header they still send is ignored).
      rpc-authentication-required = false;
      rpc-whitelist-enabled = false;
      # Must stay false: the daemon is fronted by the transmission.mishok13.me
      # reverse proxy, and transmission 4 otherwise rejects that Host header.
      rpc-host-whitelist-enabled = false;
    };
  };

  # transmission's sandbox bind-mounts these; make sure they are mounted first.
  systemd.services.transmission.unitConfig.RequiresMountsFor = [
    "/downloads"
    "/watch"
  ];

  services.sonarr = {
    enable = true;
    user = "mishok13";
    group = "users";
  };
  # sonarr's root folder and series paths are /tv (old container mount point).
  systemd.services.sonarr.unitConfig.RequiresMountsFor = [ "/tv" ];

  services.radarr = {
    enable = true;
    user = "mishok13";
    group = "users";
  };
  # radarr's root folder and movie paths are /movies (old container mount point).
  systemd.services.radarr.unitConfig.RequiresMountsFor = [ "/movies" ];

  # prowlarr only manages indexers and never touches the media library, so the
  # module's default hardened DynamicUser is fine here.
  services.prowlarr.enable = true;

  # Samba server configuration
  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        workgroup = "WORKGROUP";
        "server role" = "standalone server";
        "log file" = "/var/log/samba/log.%m";
        "max log size" = 1000;
        "logging" = "file";
        "map to guest" = "bad user";
        "usershare allow guests" = "yes";
      };
      public = {
        browseable = "yes";
        comment = "Public samba share.";
        "guest ok" = "yes";
        path = "/mnt/media";
        "read only" = "yes";
      };
    };
  };

  # Enable winbind for Samba
  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };

  system.stateVersion = "26.05";
}
