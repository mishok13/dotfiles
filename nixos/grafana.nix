{
  config,
  lib,
  pkgs,
  ...
}:

{
  sops.secrets.grafanaTelegramBotToken = {
    owner = "grafana";
    group = "grafana";
  };

  environment.etc."grafana-dashboards/blackbox.json" = {
    source = ./grafana/dashboards/blackbox.json;
    mode = "0444";
  };

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

      alerting.contactPoints.settings = {
        contactPoints = [
          {
            name = "Telegram";
            receivers = [
              {
                type = "telegram";
                uid = "dehejhje4uu4ge";
                disableResolveMessage = false;
                settings = {
                  bottoken = "$__file{${config.sops.secrets.grafanaTelegramBotToken.path}}";
                  chatid = "-4745798193";
                  disable_notification = false;
                  disable_web_page_preview = false;
                  protect_content = false;
                };
              }
            ];
          }
        ];
      };

      dashboards.settings = {
        apiVersion = 1;
        providers = [
          {
            name = "Default";
            type = "file";
            options.path = "/etc/grafana-dashboards";
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
