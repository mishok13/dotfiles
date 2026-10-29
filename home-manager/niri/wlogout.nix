{ ... }:

{
  xdg.configFile."wlogout/layout".text = ''
    { "label": "lock", "action": "swaylock -f", "text": "Lock", "keybind": "l" }
    { "label": "logout", "action": "niri msg action quit", "text": "Logout", "keybind": "e" }
    { "label": "suspend", "action": "systemctl suspend", "text": "Suspend", "keybind": "s" }
    { "label": "reboot", "action": "systemctl reboot", "text": "Reboot", "keybind": "r" }
    { "label": "shutdown", "action": "systemctl poweroff", "text": "Shutdown", "keybind": "p" }
  '';

  xdg.configFile."wlogout/style.css".text = ''
    * {
        font-family: "Hack Nerd Font", sans-serif;
        font-size: 16px;
        color: #cdd6f4;
    }

    window {
        background-color: rgba(30, 30, 46, 0.9);
    }

    button {
        background-color: #313244;
        border: 2px solid #45475a;
        border-radius: 12px;
        margin: 12px;
        padding: 20px;
    }

    button:focus,
    button:hover {
        background-color: #89b4fa;
        color: #1e1e2e;
        border-color: #89b4fa;
    }
  '';
}
