{
  config,
  pkgs,
  lib,
  ...
}:

let
  onePasswordAgentSocket = "${config.home.homeDirectory}/.1password/agent.sock";
in
{
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

    // niri children inherit this block. A GDM-launched compositor does not source
    // the shell profile, so the 1Password agent socket is set explicitly here too.
    environment {
        SSH_AUTH_SOCK "${onePasswordAgentSocket}"
    }

    prefer-no-csd

    spawn-at-startup "/opt/1Password/1password" "--silent"

    binds {
        Mod+Return { spawn "${config.programs.ghostty.package}/bin/ghostty"; }

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
