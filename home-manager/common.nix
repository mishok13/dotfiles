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

  # Make sure the GUI apps installed through Home Manager are available in app launchers. Note that logout-login
  # cycle is required to get the cache update to work, so it's not a perfect solution.
  xdg.mime.enable = true;
  xdg.enable = true;
}
