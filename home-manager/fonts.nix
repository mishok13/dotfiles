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
    pkgs.uiua386
    pkgs.open-sans
  ];

}
