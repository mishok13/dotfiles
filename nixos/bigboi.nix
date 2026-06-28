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
    ./bigboi/hardware-configuration.nix
  ];

  networking.hostName = "bigboi";

  # NFS Server configuration
  services.nfs.server = {
    enable = true;
    exports = ''
      /mnt/media/share 100.64.0.0/10(rw,no_subtree_check,fsid=0) 192.168.0.0/24(rw,no_subtree_check,fsid=0) 192.168.0.20(rw,no_subtree_check,insecure,fsid=0)
      /mnt/media 100.64.0.0/10(ro,no_subtree_check,fsid=1) 192.168.0.0/24(ro,no_subtree_check,fsid=1) 192.168.0.20(ro,no_subtree_check,insecure,fsid=1)
    '';
  };

  # Open NFS + Immich ports
  networking.firewall.allowedTCPPorts = [
    2049
    2283
  ];
  networking.firewall.allowedUDPPorts = [ 2049 ];

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
