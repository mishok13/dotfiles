{
  config,
  pkgs,
  lib,
  ...
}:

let
  isLinux = pkgs.stdenv.isLinux;
in
{
  imports = [
    ./fonts.nix
  ];

  programs = {
    ghostty = {
      enable = true;
      enableFishIntegration = true;
      enableBashIntegration = true;

      package = if pkgs.stdenv.isDarwin then pkgs.ghostty-bin else pkgs.ghostty;

      settings = {
        font-family = "Hack Nerd Font Mono";
        font-size = 14;
        adjust-cursor-thickness = "50%";
        theme = "Catppuccin Mocha";

        fullscreen = true;

        copy-on-select = true;
        right-click-action = "paste";
        command = "${pkgs.fish}/bin/fish";

        keybind = [
          "left=goto_split:left"
          "right=goto_split:right"
          "up=goto_split:up"
          "down=goto_split:down"
        ];
      };
    };
  };

}
