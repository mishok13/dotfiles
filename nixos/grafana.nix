{
  config,
  lib,
  pkgs,
  ...
}:

{
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
            access = "proxy";
            url = "https://prometheus.mishok13.me";
            jsonData = {
              httpMethod = "POST";
            };
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
