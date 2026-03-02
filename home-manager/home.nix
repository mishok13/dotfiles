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
    ./common.nix
    ./emacs.nix
    ./kitty.nix
    ./gui.nix
    ./syncthing.nix
    ./terminal.nix
  ];
}
