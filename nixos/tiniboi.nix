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
    ./tiniboi/caddy.nix
    ./tiniboi/services.nix
    ./alertmanager.nix
    ./grafana.nix
    ./prometheus.nix
    ./syncthing.nix
    ./tiniboi/hardware-configuration.nix
  ];

  networking.hostName = "tiniboi";
  system.stateVersion = "25.05";
}
