{
  config,
  lib,
  pkgsCaddy,
  ...
}:

let
  cfg = config.caddy;
in
{
  options.caddy = {
    services = lib.mkOption {
      type = lib.types.attrsOf lib.types.port;
      default = { };
    };

    extraConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
    };
  };

  config = lib.mkIf (cfg.services != { } || cfg.extraConfig != "") {
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
      virtualHosts = lib.mapAttrs' (name: port: {
        name = "${name}.mishok13.me";
        value.extraConfig = ''
          reverse_proxy localhost:${toString port}
        '';
      }) cfg.services;
      inherit (cfg) extraConfig;
    };

    systemd.services.caddy.serviceConfig.EnvironmentFile = config.sops.templates."caddy-env".path;

    networking.firewall.allowedTCPPorts = [
      80
      443
    ];
  };
}
