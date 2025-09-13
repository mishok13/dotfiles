{
  config,
  pkgs,
  lib,
  nixgl,
  system,
  pkgsLLM,
  commitSignProgram,
  sshCommand,
  ...
}:

{
  imports = [
    ./gui.nix
    ./terminal.nix
  ];

  terminal.commitSignProgram = commitSignProgram;
  terminal.sshCommand = sshCommand;

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
