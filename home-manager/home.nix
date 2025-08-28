{
  config,
  pkgs,
  lib,
  nixgl,
  system,
  ...
}:

{
  imports = [
    ./gui.nix
    ./terminal.nix
  ];

  home.username = "mishok13";
  home.homeDirectory = "/home/mishok13";

  home.stateVersion = "25.05";

  home.sessionVariables = {
    # EDITOR = "emacs";
    # SHELL = "${pkgs.fish}/bin/fish";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
