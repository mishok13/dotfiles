{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./common.nix
    ./user.nix
    ./remote-builder.nix
    ./nfs.nix
    ./blocky.nix
    ./caddy.nix
    ./tiniboi/services.nix
    ./alertmanager.nix
    ./grafana.nix
    ./prometheus.nix
    ./syncthing.nix
    ./tiniboi/hardware-configuration.nix
  ];

  networking.hostName = "tiniboi";
  system.stateVersion = "25.05";

  caddy = {
    services = {
      grafana = 3000;
      prometheus = 9090;
      rss = 8080;
      atuin = 8888;
    };
    extraConfig = ''
      :2019 {
        @tailscale {
          remote_ip 100.64.0.0/10
        }
        handle @tailscale {
          metrics /metrics
        }
        handle {
          respond "Forbidden" 403
        }
      }
    '';
  };
}
