{ config, ... }:

{
  sops.secrets.nixCacheSecretKey = { };

  services.harmonia.cache = {
    enable = true;
    signKeyPaths = [ config.sops.secrets.nixCacheSecretKey.path ];
    settings = {
      bind = "127.0.0.1:5000";
      # Lower than cache.nixos.org (40) so local paths win.
      priority = 30;
    };
  };

  caddy.nix-cache = 5000;
}
