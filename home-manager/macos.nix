{
  config,
  pkgs,
  lib,
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
    ./terminal.nix
    ./kitty.nix
  ];
}
