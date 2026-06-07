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
    ./editors.nix
    ./kitty.nix
    ./terminal.nix
    ./terminal/llm.nix
    ./syncthing.nix
  ];

  targets.genericLinux = lib.mkIf pkgs.stdenv.isLinux {
    nixGL.packages = nixgl.packages;
    nixGL.defaultWrapper = "mesa";
    enable = false;
    gpu.enable = false;
  };

  # Make sure the GUI apps installed through Home Manager are available in app launchers. Note that logout-login
  # cycle is required to get the cache update to work, so it's not a perfect solution.
  xdg.mime.enable = true;
  xdg.enable = true;
}
