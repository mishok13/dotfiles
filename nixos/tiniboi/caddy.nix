{
  config,
  lib,
  pkgs,
  ...
}:

{
  sops.secrets.cloudflareApiToken = { };

  sops.templates."caddy-env".content = ''
    CF_API_TOKEN=${config.sops.placeholder.cloudflareApiToken}
  '';

  services.caddy = {
    enable = true;
    package = pkgs.caddy.withPlugins {
      plugins = [ "github.com/caddy-dns/cloudflare@v0.2.3" ];
      # Run `nix build .#nixosConfigurations.tiniboi.config.services.caddy.package` to get the correct hash
      hash = "sha256-8E6OGxwZsjPofmfi1j8dMXTkCkIRxpzhQ/KTXYIGR0w=";
    };
    globalConfig = ''
      acme_dns cloudflare {env.CF_API_TOKEN}
    '';
    virtualHosts."grafana.mishok13.me" = {
      extraConfig = ''
        reverse_proxy :3000
      '';
    };
    virtualHosts."prometheus.mishok13.me" = {
      extraConfig = ''
        reverse_proxy :9090
      '';
    };
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

  systemd.services.caddy.serviceConfig.EnvironmentFile = config.sops.templates."caddy-env".path;
}
