{
  config,
  lib,
  pkgs,
  ...
}:

let
  services = {
    radarr = 7878;
    sonarr = 8989;
    prowlarr = 9696;
    transmission = 9091;
    immich = 2283;
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
}
