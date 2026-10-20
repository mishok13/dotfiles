{
  config,
  lib,
  pkgs,
  ...
}:

let
  dnsPort = config.services.blocky.settings.ports.dns;

  localRecords = {
    "bigboi.home.mishok13.me" = "192.168.0.51";
    "tiniboi.home.mishok13.me" = "192.168.0.67";
    "beafiboi.home.mishok13.me" = "192.168.0.52";
    "orangepi.home.mishok13.me" = "192.168.0.20";
  };
in
{
  services.blocky = {
    enable = true;
    settings = {
      ports = {
        dns = lib.mkDefault 53;
        http = 4000; # prometheus / REST API
      };

      upstreams = {
        init.strategy = "fast";
        groups.default = [
          "8.8.8.8" # CloudFlare
          "8.8.4.4"
          "9.9.9.11" # Quad9
          "149.112.112.11"
        ];
      };

      bootstrapDns = [
        {
          upstream = "tcp+udp:1.1.1.1";
          ips = [ "1.1.1.1" ];
        }
      ];

      customDNS = {
        customTTL = "1h";
        mapping = localRecords;
      };

      # Reverse lookup hostnames for tailnet devices
      clientLookup.upstream = "100.100.100.100";

      blocking = {
        loading.strategy = "fast";
        denylists = {
          ads = [
            "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
          ];
        };
        clientGroupsBlock.default = [
          "ads"
        ];
      };

      caching = {
        minTime = "5m";
        prefetching = true;
      };

      prometheus = {
        enable = true;
        path = "/metrics";
      };

      log.level = "info";
    };
  };

  # DNS on 53, plus blocky's metrics/REST port 4000. Tailnet scrapes (Prometheus
  # hits bigboi:4000 / tiniboi:4000 over MagicDNS) are already accepted by
  # tailscale's own ts-input chain before nixos-fw runs, so this open is really
  # just for ad-hoc LAN access to the metrics; the only non-tailscale ingress is
  # the LAN interface anyway.
  networking.firewall.allowedTCPPorts = [
    dnsPort
    4000
  ];
  networking.firewall.allowedUDPPorts = [ dnsPort ];
}
