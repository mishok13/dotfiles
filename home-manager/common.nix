{
  config,
  pkgs,
  lib,
  system,
  commitSignProgram,
  sshCommand,
  ...
}:

{
  terminal.commitSignProgram = commitSignProgram;
  terminal.sshCommand = sshCommand;

  home.stateVersion = "25.05";

  home.sessionVariables = {
    ANSIBLE_NOCOWS = "1";
    EDITOR = "vim";
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
