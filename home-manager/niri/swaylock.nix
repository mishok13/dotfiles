{ ... }:

{
  xdg.configFile."swaylock/config".text = ''
    daemonize
    ignore-empty-password
    indicator
    indicator-radius=100
    indicator-thickness=8
    clock
    timestr=%H:%M
    datestr=%a %d %b

    color=1e1e2e
    inside-color=1e1e2e
    ring-color=89b4fa
    text-color=cdd6f4
    line-color=1e1e2e
    separator-color=1e1e2e

    key-hl-color=a6e3a1
    bs-hl-color=f9e2af

    inside-ver-color=1e1e2e
    ring-ver-color=89b4fa
    text-ver-color=cdd6f4

    inside-clear-color=1e1e2e
    ring-clear-color=a6e3a1
    text-clear-color=1e1e2e

    inside-wrong-color=1e1e2e
    ring-wrong-color=f38ba8
    text-wrong-color=f38ba8
  '';
}
