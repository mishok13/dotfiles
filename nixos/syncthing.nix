{
  config,
  lib,
  pkgs,
  ...
}:

let
  hostname = config.networking.hostName;
  home = "/home/mishok13";

  syncthing = import ../syncthing/lib.nix {
    inherit lib hostname;
    homeDir = home;
  };
in
{
  sops.secrets."syncthing/${hostname}/key" = {
    owner = "mishok13";
    group = "users";
    mode = "0600";
  };
  sops.secrets."syncthing/${hostname}/cert" = {
    owner = "mishok13";
    group = "users";
    mode = "0644";
  };
  sops.secrets."syncthing/gui-password" = {
    owner = "mishok13";
    group = "users";
    mode = "0400";
  };

  services.syncthing = {
    enable = true;
    user = "mishok13";
    group = "users";
    dataDir = home;
    openDefaultPorts = true;
    overrideDevices = true;
    overrideFolders = true;

    key = config.sops.secrets."syncthing/${hostname}/key".path;
    cert = config.sops.secrets."syncthing/${hostname}/cert".path;
    guiPasswordFile = config.sops.secrets."syncthing/gui-password".path;

    settings = {
      gui.user = "mishok13";
      inherit (syncthing) devices folders;
    };
  };

  systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true";
}
