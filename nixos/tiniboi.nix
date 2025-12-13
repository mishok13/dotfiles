{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./common.nix
    ./tiniboi/hardware-configuration.nix
  ];
  networking.hostName = "tiniboi";
  system.stateVersion = "25.05";
}
