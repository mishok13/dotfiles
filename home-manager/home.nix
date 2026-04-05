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
    ./terminal.nix
    ./terminal/llm.nix
  ];

  targets.genericLinux = lib.mkIf pkgs.stdenv.isLinux {
    nixGL.packages = nixgl.packages;
    nixGL.defaultWrapper = "mesa";
    enable = false;
    gpu.enable = false;
  };
}
