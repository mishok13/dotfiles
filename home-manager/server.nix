# Config used for servers (homelab and cloud alike)

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
    ./terminal.nix
  ];
}
