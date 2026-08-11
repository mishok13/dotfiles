{
  config,
  lib,
  pkgs,
  ...
}:

let
  # Every service fronted here lives locally on bigboi, so reverse-proxy straight
  # to localhost instead of tromboning through the Caddy on orangepi. Each entry
  # keeps the three hostname variants that orangepi served so DNS can be
  # repointed 1:1.
  services = {
    radarr = 7878;
    sonarr = 8989;
    prowlarr = 9696;
    transmission = 9091;
    immich = 2283;
  };
  hostnames =
    name:
    lib.concatStringsSep ", " [
      "${name}.mishok13.me"
      "${name}.home.mishok13.me"
      "${name}.tail.mishok13.me"
    ];
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
    package = pkgs.caddy.withPlugins {
      plugins = [ "github.com/caddy-dns/cloudflare@v0.2.4" ];
      # Run `nix build .#nixosConfigurations.bigboi.config.services.caddy.package` to get the correct hash
      hash = "sha256-bzMqxWTqrJ1skZmRTXyEMCKStXpljbqe5r0Ve2cnBfM=";
    };
    globalConfig = ''
      acme_dns cloudflare {env.CF_API_TOKEN}
    '';
    virtualHosts = lib.mapAttrs' (name: port: {
      name = hostnames name;
      value.extraConfig = ''
        reverse_proxy localhost:${toString port}
      '';
    }) services;
  };

  systemd.services.caddy.serviceConfig.EnvironmentFile = config.sops.templates."caddy-env".path;

  # Caddy needs 80 (HTTP -> HTTPS redirect) and 443 (proxied services).
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
