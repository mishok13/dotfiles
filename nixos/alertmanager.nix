{
  config,
  lib,
  pkgs,
  ...
}:

{
  sops.secrets.grafanaTelegramBotToken = { };

  sops.templates."alertmanager-env".content = ''
    TELEGRAM_BOT_TOKEN=${config.sops.placeholder.grafanaTelegramBotToken}
  '';

  services.prometheus.alertmanager = {
    enable = true;
    configuration = {
      global = { };
      route = {
        group_by = [
          "alertname"
          "instance"
        ];
        group_wait = "30s";
        group_interval = "5m";
        repeat_interval = "4h";
        receiver = "telegram";
      };
      receivers = [
        {
          name = "telegram";
          telegram_configs = [
            {
              send_resolved = true;
              bot_token = "$TELEGRAM_BOT_TOKEN";
              chat_id = -4745798193;
              parse_mode = "HTML";
            }
          ];
        }
      ];
    };
    environmentFile = config.sops.templates."alertmanager-env".path;
    checkConfig = false;
  };
}
