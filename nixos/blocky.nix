{
  config,
  lib,
  pkgs,
  ...
}:

# Shared, declarative local DNS resolver (Tier 2 plan: replaces Pihole-on-orangepi).
# Imported by the resolver hosts (bigboi, tiniboi). Both serve the identical local zone
# so either can answer if the other is down.
#
# Port note: defaults to 53 (real DNS). During Phase 2 validation a host may override
# `services.blocky.settings.ports.dns` with `lib.mkForce 5353` to run alongside anything
# on :53 without impact. The firewall opening follows whatever port is configured.

let
  dnsPort = config.services.blocky.settings.ports.dns;

  # Single source of truth for local A-records. These never existed in Pihole
  # (host resolution was 100% MagicDNS); we create them here.
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
    # keep build-time `blocky validate` on (default) as a safety net
    settings = {
      ports = {
        dns = lib.mkDefault 53;
        http = 4000; # prometheus / REST API
      };

      upstreams = {
        # serve immediately on start; don't fail if an upstream is briefly unreachable
        init.strategy = "fast";
        # mirrors the previous Pihole upstreams (Google + Quad9 filtered)
        groups.default = [
          "8.8.8.8"
          "8.8.4.4"
          "9.9.9.11"
          "149.112.112.11"
        ];
      };

      # Resolve blocklist URLs without depending on the system resolver (which is us).
      # Solves the chicken-and-egg on cold boot.
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

      # Reverse lookups for the LAN go to the Omada gateway (was Pihole `revServers`).
      conditional.mapping = {
        "0.168.192.in-addr.arpa" = "192.168.0.1";
      };

      blocking = {
        # serve immediately; load/refresh lists in the background
        loading.strategy = "fast";
        denylists = {
          ads = [
            "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
          ];
          # the single hand-added block carried over from Pihole's domainlist.
          # trailing newline forces blocky to treat this as an inline list, not a file path.
          custom = [ "ablink.account.etsy.com\n" ];
        };
        clientGroupsBlock.default = [
          "ads"
          "custom"
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

  networking.firewall.allowedTCPPorts = [ dnsPort ];
  networking.firewall.allowedUDPPorts = [ dnsPort ];
}
