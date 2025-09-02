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
    ANSIBLE_NOCOWS = "1"; # Mooooot the cows

    # EDITOR = "emacs";
    # SHELL = "${pkgs.fish}/bin/fish";
  };

  programs.home-manager.enable = true;
}
