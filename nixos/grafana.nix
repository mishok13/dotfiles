{
  config,
  lib,
  pkgs,
  ...
}:

let
  sourceDashboardDir = ./grafana/dashboards;
  targetDashboardDir = "grafana-dashboards";
  dashboards = [
    "blackbox.json"
    "caddy.json"
    "node-exporter.json"
    "nvidia-gpu.json"
  ];

  makeDashboardPath = name: {
    name = "${targetDashboardDir}/${name}";
    value = {
      source = "${sourceDashboardDir}/${name}";
      mode = "0444";
    };
  };
in
{
  environment.etc = builtins.listToAttrs (map makeDashboardPath dashboards);

  services.grafana = {
    enable = true;
    openFirewall = true;

    provision = {
      enable = true;

      datasources.settings = {
        datasources = [
          {
            name = "Prometheus";
            type = "prometheus";
            uid = "deheily5a2tj4f";
            access = "proxy";
            url = "https://prometheus.mishok13.me";
            jsonData = {
              httpMethod = "POST";
            };
          }
        ];
        deleteDatasources = [
          {
            name = "Prometheus";
            orgId = 1;
          }
        ];
      };

      dashboards.settings = {
        apiVersion = 1;
        providers = [
          {
            name = "Default";
            type = "file";
            options.path = "/etc/${targetDashboardDir}";
          }
        ];
      };

    };

    settings = {
      server = {
        http_addr = "0.0.0.0";
      };
    };
  };
}
