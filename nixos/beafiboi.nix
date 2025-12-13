{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./common.nix
    ./beafiboi/hardware-configuration.nix
  ];
  networking.hostName = "beafiboi";
  system.stateVersion = "25.05";
}
