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
    ./editors.nix
    ./terminal.nix
    ./kitty.nix
    ./ghostty.nix
    ./terminal/llm.nix
  ];
}
