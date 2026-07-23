{
  config,
  lib,
  pkgs,
  ...
}:

let
  mediaCompose = pkgs.writeText "media-compose.yaml" ''
    services:

      transmission:
        image: lscr.io/linuxserver/transmission:4.0.6-r0-ls256@sha256:60f620b6597d1a3c06f3faf0ae1af7385b0f8f793b4d425cd4867423dd0800c7
        container_name: transmission
        restart: unless-stopped
        environment:
          PUID: "1000"
          PGID: "1000"
          TZ: "Etc/UTC"
          USER: "admin"
          PASS: "admin"
        volumes:
          - /mnt/media/downloads:/downloads
          - /mnt/media/transmission/watch:/watch
          - /home/mishok13/.config/transmission:/config
        ports:
          - "9091:9091"
          - "51413:51413"
          - "51413:51413/udp"

      sonarr:
        image: lscr.io/linuxserver/sonarr:4.0.17.2952-ls305@sha256:76414c033f290d3c9f1f9dfad71150abe71d92592369a3377a5903d579e6e2b2
        container_name: sonarr
        restart: unless-stopped
        environment:
          PUID: "1000"
          PGID: "1000"
          TZ: "Etc/UTC"
        volumes:
          - /home/mishok13/.config/sonarr:/config
          - /mnt/media/tv:/tv
          - /mnt/media/downloads:/downloads
        ports:
          - "8989:8989"

      radarr:
        image: lscr.io/linuxserver/radarr:6.0.4.10291-ls295@sha256:ca43905eaf2dd11425efdcfe184892e43806b1ae0a830440c825cecbc2629cfb
        container_name: radarr
        restart: unless-stopped
        environment:
          PUID: "1000"
          PGID: "1000"
          TZ: "Etc/UTC"
        volumes:
          - /home/mishok13/.config/radarr:/config
          - /mnt/media/movies:/movies
          - /mnt/media/downloads:/downloads
        ports:
          - "7878:7878"

      prowlarr:
        image: lscr.io/linuxserver/prowlarr:2.3.0.5236-ls139@sha256:9ef5d8bf832edcacb6082f9262cb36087854e78eb7b1c3e1d4375056055b2d82
        container_name: prowlarr
        restart: unless-stopped
        environment:
          PUID: "1000"
          PGID: "1000"
          TZ: "Etc/UTC"
        volumes:
          - /home/mishok13/.config/prowlarr:/config
        ports:
          - "9696:9696"
  '';

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
      ExecStart = "${pkgs.docker-compose}/bin/docker-compose -f ${immichCompose} up -d --remove-orphans";
      ExecStop = "${pkgs.docker-compose}/bin/docker-compose -f ${immichCompose} down";
    };
  };

  # Media stack (transmission, sonarr, radarr, prowlarr) via Docker Compose
  systemd.services.media = {
    description = "Media stack (transmission/sonarr/radarr/prowlarr)";
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
      ExecStart = "${pkgs.docker-compose}/bin/docker-compose -f ${mediaCompose} up -d --remove-orphans";
      ExecStop = "${pkgs.docker-compose}/bin/docker-compose -f ${mediaCompose} down";
    };
  };

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
