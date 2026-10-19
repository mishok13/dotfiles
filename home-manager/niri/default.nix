{
  config,
  pkgs,
  lib,
  ...
}:

let
  onePasswordAgentSocket = "${config.home.homeDirectory}/.1password/agent.sock";

  idleScript = pkgs.writeShellScript "niri-swayidle" ''
    exec swayidle -w \
      timeout 180 'swaylock -f' \
      timeout 300 'niri msg action power-off-monitors' \
      timeout 600 'systemctl suspend' \
      before-sleep 'swaylock -f'
  '';

  clipPicker = pkgs.writeShellScript "niri-clip-picker" ''
    cliphist list | fuzzel --dmenu | cliphist decode | wl-copy
  '';
in
{
  imports = [
    ./waybar.nix
    ./mako.nix
    ./swaylock.nix
  ];

  home.sessionVariables = {
    SSH_AUTH_SOCK = onePasswordAgentSocket;
  };

  xdg.configFile."niri/config.kdl".text = ''
    input {
        keyboard {
            xkb {
                layout "us"
            }
        }

        touchpad {
            tap
            natural-scroll
        }
    }

    environment {
        SSH_AUTH_SOCK "${onePasswordAgentSocket}"
    }

    prefer-no-csd

    spawn-at-startup "/opt/1Password/1password" "--silent"
    spawn-at-startup "waybar"
    spawn-at-startup "mako"
    spawn-at-startup "swaybg" "-c" "#1e1e2e"
    spawn-at-startup "wl-paste" "--watch" "cliphist" "store"
    spawn-at-startup "wl-paste" "--type" "image" "--watch" "cliphist" "store"
    spawn-at-startup "${idleScript}"

    binds {
        Mod+Return { spawn "${config.programs.ghostty.package}/bin/ghostty"; }
        Mod+R      { spawn "fuzzel"; }
        Mod+V      { spawn "${clipPicker}"; }
        Mod+Escape { spawn "swaylock" "-f"; }

        Mod+Q       { close-window; }
        Mod+Shift+E { quit; }

        Mod+Left  { focus-column-left; }
        Mod+Right { focus-column-right; }
        Mod+Up    { focus-window-up; }
        Mod+Down  { focus-window-down; }

        Mod+Shift+Left  { move-column-left; }
        Mod+Shift+Right { move-column-right; }

        Mod+F       { maximize-column; }
        Mod+Shift+F { fullscreen-window; }
    }
  '';
}
