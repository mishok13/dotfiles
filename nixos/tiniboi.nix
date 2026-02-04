{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./common.nix
    ./grafana.nix
    ./tiniboi/hardware-configuration.nix
  ];
  networking.hostName = "tiniboi";
  system.stateVersion = "25.05";
}
