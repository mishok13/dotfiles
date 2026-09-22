{
  config,
  lib,
  pkgs,
  pkgsCaddy,
  ...
}:

let
  hostname = config.networking.hostName;
in
{
  sops.secrets.cloudflareApiToken = { };

  sops.templates."caddy-env" = {
    content = ''
      CF_API_TOKEN=${config.sops.placeholder.cloudflareApiToken}
    '';
    restartUnits = [ "caddy.service" ];
  };

  services.caddy = {
    enable = true;
    package = pkgsCaddy.caddy.withPlugins {
      plugins = [ "github.com/caddy-dns/cloudflare@v0.2.4" ];
      # Run `nix build .#nixosConfigurations.<host>.config.services.caddy.package` to get the correct hash
      hash = "sha256-bzMqxWTqrJ1skZmRTXyEMCKStXpljbqe5r0Ve2cnBfM=";
    };
    globalConfig = ''
      acme_dns cloudflare {env.CF_API_TOKEN}
    '';

    virtualHosts = lib.mkIf config.services.syncthing.enable {
      "syncthing.${hostname}.mishok13.me".extraConfig = ''
        reverse_proxy ${config.services.syncthing.guiAddress} {
          header_up Host {upstream_hostport}
        }
      '';
    };
  };

  systemd.services.caddy.serviceConfig.EnvironmentFile = config.sops.templates."caddy-env".path;

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
