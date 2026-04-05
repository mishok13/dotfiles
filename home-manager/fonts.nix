{
  config,
  pkgs,
  lib,
  nixgl,
  system,
  ...
}:

{
  fonts.fontconfig.enable = true;

  home.packages = [
    pkgs.aileron
    pkgs.helvetica-neue-lt-std
    pkgs.inter-nerdfont
    pkgs.nerd-fonts.hack
    # The font has *insane* line height issues, see https://github.com/RedHatOfficial/Overpass/issues/91 and
    # https://github.com/RedHatOfficial/Overpass/issues/56 I will keep it here for now as it seems visually
    # appealing but holy fuck getting 20 lines instead of 32 when switching from hack to overpass is too much.
    pkgs.nerd-fonts.overpass
    pkgs.uiua386
    pkgs.open-sans
  ];

}
