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
      hash = "sha256-bJO2RIa6hYsoVl3y2L86EM34Dfkm2tlcEsXn2+COgzo=";
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
