{
  config,
  lib,
  pkgs,
  ...
}:

let
  services = {
    grafana = 3000;
    prometheus = 9090;
    rss = 8080;
    atuin = 8888;
  };
in
{
  imports = [ ../caddy.nix ];

  services.caddy.virtualHosts = lib.mapAttrs' (name: port: {
    name = "${name}.mishok13.me";
    value.extraConfig = ''
      reverse_proxy :${toString port}
    '';
  }) services;

  services.caddy.extraConfig = ''
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

}
