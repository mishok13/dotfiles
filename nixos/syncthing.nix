{
  config,
  lib,
  pkgs,
  syncthingDevices,
  ...
}:

let
  hostname = config.networking.hostName;
  otherDevices = lib.filterAttrs (name: _: name != hostname) syncthingDevices;
  otherDeviceNames = builtins.attrNames otherDevices;
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

  services.syncthing = {
    enable = true;
    user = "mishok13";
    group = "users";
    dataDir = "/home/mishok13";
    openDefaultPorts = true;
    overrideDevices = true;
    overrideFolders = true;

    key = config.sops.secrets."syncthing/${hostname}/key".path;
    cert = config.sops.secrets."syncthing/${hostname}/cert".path;

    settings = {
      devices = otherDevices;

      folders = {
        "Downloads" = {
          path = "/home/mishok13/Downloads";
          devices = otherDeviceNames;
          ignoreDelete = false;
        };
        "notes" = {
          path = "/home/mishok13/nonwork/notes";
          devices = otherDeviceNames;
          ignoreDelete = true;
        };
      };
    };
  };

  systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true";
}
