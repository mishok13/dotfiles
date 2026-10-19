{ ... }:

{
  xdg.configFile."waybar/config".text = ''
    {
        "layer": "top",
        "position": "top",
        "height": 30,
        "spacing": 6,

        "modules-left": ["niri/workspaces", "niri/window"],
        "modules-center": ["clock"],
        "modules-right": ["pulseaudio", "network", "backlight", "battery", "tray"],

        "niri/workspaces": {
            "format": "{index}"
        },

        "niri/window": {
            "format": "{title}",
            "max-length": 60
        },

        "clock": {
            "format": "{:%a %d %b  %H:%M}",
            "tooltip-format": "<tt>{calendar}</tt>"
        },

        "pulseaudio": {
            "format": "{icon} {volume}%",
            "format-muted": "󰝟 muted",
            "format-icons": { "default": ["󰕿", "󰖀", "󰕾"] },
            "scroll-step": 5,
            "on-click": "pavucontrol"
        },

        "network": {
            "format-wifi": "󰤨 {essid}",
            "format-ethernet": "󰈀 wired",
            "format-disconnected": "󰤭 offline",
            "tooltip-format": "{ifname}: {ipaddr}"
        },

        "backlight": {
            "format": "{icon} {percent}%",
            "format-icons": ["󰃞", "󰃟", "󰃠"],
            "scroll-step": 5
        },

        "battery": {
            "format": "{icon} {capacity}%",
            "format-charging": "󰂄 {capacity}%",
            "format-icons": ["󰁺", "󰁼", "󰁾", "󰂀", "󰁹"],
            "states": { "warning": 25, "critical": 10 }
        },

        "tray": {
            "spacing": 8
        }
    }
  '';

  xdg.configFile."waybar/style.css".text = ''
    * {
        font-family: "Hack Nerd Font", sans-serif;
        font-size: 11pt;
        min-height: 0;
    }

    window#waybar {
        background: #1e1e2e;
        color: #cdd6f4;
    }

    #workspaces button {
        padding: 0 8px;
        color: #cdd6f4;
        background: transparent;
    }

    #workspaces button.active {
        color: #1e1e2e;
        background: #89b4fa;
        border-radius: 6px;
    }

    #workspaces button.urgent {
        color: #1e1e2e;
        background: #f38ba8;
        border-radius: 6px;
    }

    #window {
        color: #a6adc8;
    }

    #clock,
    #pulseaudio,
    #network,
    #backlight,
    #battery,
    #tray {
        padding: 0 10px;
    }

    #battery.warning {
        color: #f9e2af;
    }

    #battery.critical {
        color: #f38ba8;
    }
  '';
}
