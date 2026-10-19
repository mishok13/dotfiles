{
  config,
  pkgs,
  lib,
  ...
}:

# Provision on fedora:
# sudo dnf install niri fuzzel waybar mako swayidle swaylock swaybg wl-clipboard cliphist grim slurp brightnessctl pavucontrol wlr-randr wlogout playerctl libnotify

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

  screenshotRegion = pkgs.writeShellScript "niri-screenshot-region" ''
    dir="$HOME/Pictures/Screenshots"
    mkdir -p "$dir"
    file="$dir/screenshot-$(date +%Y%m%d-%H%M%S).png"
    geom=$(slurp) || exit 1
    grim -g "$geom" - | tee "$file" | wl-copy
    notify-send "Screenshot saved" "$file"
  '';

  screenshotFull = pkgs.writeShellScript "niri-screenshot-full" ''
    dir="$HOME/Pictures/Screenshots"
    mkdir -p "$dir"
    file="$dir/screenshot-$(date +%Y%m%d-%H%M%S).png"
    grim - | tee "$file" | wl-copy
    notify-send "Screenshot saved" "$file"
  '';
in
{
  imports = [
    ./waybar.nix
    ./mako.nix
    ./swaylock.nix
    ./wlogout.nix
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

        Print       { spawn "${screenshotRegion}"; }
        Shift+Print { spawn "${screenshotFull}"; }

        Mod+Shift+Q { spawn "wlogout"; }

        XF86AudioRaiseVolume  allow-when-locked=true { spawn "wpctl" "set-volume" "-l" "1.0" "@DEFAULT_AUDIO_SINK@" "5%+"; }
        XF86AudioLowerVolume  allow-when-locked=true { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-"; }
        XF86AudioMute         allow-when-locked=true { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"; }
        XF86AudioMicMute      allow-when-locked=true { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle"; }

        XF86MonBrightnessUp   allow-when-locked=true { spawn "brightnessctl" "set" "5%+"; }
        XF86MonBrightnessDown allow-when-locked=true { spawn "brightnessctl" "set" "5%-"; }

        XF86AudioPlay  { spawn "playerctl" "play-pause"; }
        XF86AudioNext  { spawn "playerctl" "next"; }
        XF86AudioPrev  { spawn "playerctl" "previous"; }

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
