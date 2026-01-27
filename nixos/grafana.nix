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

    };

    settings = {
      server = {
        http_addr = "0.0.0.0";
      };
    };
  };
}
