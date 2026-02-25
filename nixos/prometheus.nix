{
  config,
  lib,
  pkgs,
  ...
}:

{
  sops.secrets.hassToken = {
    owner = "prometheus";
    group = "prometheus";
  };

  services.prometheus.exporters.blackbox = {
    enable = true;
    configFile = pkgs.writeText "blackbox.yml" ''
      modules:
        http_2xx:
          prober: http
          timeout: 5s
          http:
            preferred_ip_protocol: ip4
            fail_if_not_ssl: true
    '';
  };

  services.prometheus = {
    enable = true;
    port = 9090;
    checkConfig = "syntax-only";

    globalConfig = {
      scrape_interval = "30s";
    };

    alertmanagers = [
      {
        scheme = "http";
        static_configs = [
          {
            targets = [ "localhost:${toString config.services.prometheus.alertmanager.port}" ];
          }
        ];
      }
    ];

    rules = [
      ''
        groups:
          - name: instance_health
            rules:
              - alert: InstanceDown
                expr: up == 0
                for: 5m
                labels:
                  severity: critical
                annotations:
                  summary: "Instance {{ $labels.instance }} down"
                  description: "{{ $labels.instance }} of job {{ $labels.job }} has been down for more than 5 minutes."

          - name: blackbox
            rules:
              - alert: BlackboxProbeFailed
                expr: probe_success == 0
                for: 5m
                labels:
                  severity: critical
                annotations:
                  summary: "Probe failed for {{ $labels.instance }}"
                  description: "HTTP probe for {{ $labels.instance }} has been failing for more than 5 minutes."

          - name: node
            rules:
              - alert: HighCpuUsage
                expr: 100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 90
                for: 10m
                labels:
                  severity: warning
                annotations:
                  summary: "High CPU usage on {{ $labels.instance }}"
                  description: "CPU usage on {{ $labels.instance }} has been above 90% for more than 10 minutes."

              - alert: FilesystemAlmostFull
                expr: (node_filesystem_avail_bytes{fstype!~"tmpfs|nfs|ramfs",mountpoint!~"/boot|/boot/.+"} / node_filesystem_size_bytes{fstype!~"tmpfs|nfs|ramfs",mountpoint!~"/boot|/boot/.+"}) * 100 < 15
                for: 10m
                labels:
                  severity: warning
                annotations:
                  summary: "Filesystem almost full on {{ $labels.instance }}"
                  description: "Filesystem {{ $labels.mountpoint }} on {{ $labels.instance }} has less than 15% free space."
      ''
    ];

    scrapeConfigs = [
      {
        job_name = "caddy";
        static_configs = [
          {
            targets = [ "127.0.0.1:2019" ];
          }
        ];
      }
      {
        job_name = "nodes";
        file_sd_configs = [
          {
            files = [ "/etc/prometheus/targets/nodes.json" ];
          }
        ];
      }
      {
        job_name = "gpus";
        static_configs = [
          {
            targets = [ "beafiboi:9400" ];
          }
        ];
      }
      {
        job_name = "blackbox";
        metrics_path = "/probe";
        params = {
          module = [ "http_2xx" ];
        };
        static_configs = [
          {
            targets = [
              "https://mishok13.me"
              "https://mishkovskyi.net"
              "https://hass.mishok13.me"
            ];
          }
        ];
        relabel_configs = [
          {
            source_labels = [ "__address__" ];
            target_label = "__param_target";
          }
          {
            source_labels = [ "__param_target" ];
            target_label = "instance";
          }
          {
            target_label = "__address__";
            replacement = "127.0.0.1:9115";
          }
        ];
      }
      {
        job_name = "blackbox_exporter";
        static_configs = [
          {
            targets = [ "127.0.0.1:9115" ];
          }
        ];
      }
      {
        job_name = "hass";
        scrape_interval = "60s";
        metrics_path = "/api/prometheus";
        bearer_token_file = config.sops.secrets.hassToken.path;
        scheme = "https";
        static_configs = [
          {
            targets = [ "hass.mishok13.me" ];
          }
        ];
      }
    ];
  };

  environment.etc."prometheus/targets/.keep".text = "";

  networking.firewall.allowedTCPPorts = [ 9090 ];

  systemd.services.prometheus-tailscale-targets = {
    description = "Update Prometheus targets from Tailscale";
    after = [
      "prometheus.service"
      "tailscaled.service"
    ];
    requires = [
      "prometheus.service"
      "tailscaled.service"
    ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.tailscale}/bin/tailscale status --json | ${pkgs.uv}/bin/uv run ${./prometheus/tailscale_prometheus_sd.py} > /etc/prometheus/targets/nodes.json'";
    };
  };

  systemd.timers.prometheus-tailscale-targets = {
    description = "Update Prometheus targets from Tailscale every 5 minutes";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "1min";
      OnUnitActiveSec = "5min";
    };
  };

}
