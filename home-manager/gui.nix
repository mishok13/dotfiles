{
  config,
  pkgs,
  lib,
  nixgl,
  system,
  ...
}:

{
  nixGL.packages = nixgl.packages;
  nixGL.defaultWrapper = "mesa";

  fonts.fontconfig.enable = true;

  programs = {
    kitty = {
      enable = true;
      package = (config.lib.nixGL.wrap pkgs.kitty);
      font = {
        package = pkgs.nerd-fonts.hack;
        name = "Hack Nerd Font Mono";
        size = 14;
      };
      themeFile = "Catppuccin-Macchiato";
      settings = {
        cursor_beam_thickness = 2.0;
        cursor_stop_blinking_after = 10.0;
        scrollback_lines = 9999;
        scrollback_pager_history_size = 10;
        copy_on_select = true;
        macos_option_as_alt = true;
        enabled_layouts = "tall:bias=70;full_size=2,fat:bias=60;full_size=2;mirrored=false";
        hide_window_decorations = false;
        shell = "${pkgs.fish}/bin/fish";
      };
      keybindings = {
        "ctrl+shift+enter" = "launch --cwd=current";
        "ctrl+shift+1" = "launch";
        f1 = "clear_terminal scrollback active";
        f2 = "combine | new_window_with_cwd | new_window_with_cwd | new_window_with_cwd";
        left = "neighboring_window left";
        right = "neighboring_window right";
        up = "neighboring_window up";
        down = "neighboring_window down";
      };
    };
  };

  home.packages = [
    pkgs.aileron
    pkgs.emacs
    pkgs.helvetica-neue-lt-std
    pkgs.inter-nerdfont
    pkgs.kitty-themes
    pkgs.nerd-fonts.hack
    pkgs.uiua386
    pkgs.open-sans
    pkgs.spotifyd
  ];

  home.file = {
    ".config/emacs".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nonwork/emacsen";
  };

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "helvetica-neue-lt-std"
    ];

}
