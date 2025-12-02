{
  config,
  pkgs,
  lib,
  nixgl,
  system,
  commitSignProgram,
  sshCommand,
  ...
}:

{
  terminal.commitSignProgram = commitSignProgram;
  terminal.sshCommand = sshCommand;

  home.username = "mishok13";
  home.homeDirectory = "/home/mishok13";

  home.stateVersion = "25.05";

  home.sessionVariables = {
    ANSIBLE_NOCOWS = "1";
    EDITOR = "emacs";
  };

  programs.home-manager.enable = true;

  news.display = "silent";

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "claude-code"
      "helvetica-neue-lt-std"
    ];
}
