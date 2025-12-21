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

  hardware.graphics.enable = true;

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    open = false;
    modesetting.enable = true;
  };
  hardware.nvidia-container-toolkit.enable = true;

  nixpkgs.config.allowUnfree = true;
}
