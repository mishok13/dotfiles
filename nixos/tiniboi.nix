{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./common.nix
    ./tiniboi/caddy.nix
    ./grafana.nix
    ./prometheus.nix
    ./tiniboi/hardware-configuration.nix
  ];

  networking.hostName = "tiniboi";
  system.stateVersion = "25.05";
}
