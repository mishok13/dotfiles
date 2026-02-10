{
  config,
  lib,
  pkgs,
  ...
}:

{
  services.caddy = {
    enable = true;
    extraConfig = ''
      :2019 {
        @tailscale {
          remote_ip 100.64.0.0/10
        }
        handle @tailscale {
          metrics /metrics
        }
        handle {
          respond "Forbidden" 403
        }
      }
    '';
  };
}
