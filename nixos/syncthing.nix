{
  config,
  lib,
  pkgs,
  syncthingDevices,
  ...
}:

let
  # Filter out the current host from the device list
  otherDevices = lib.filterAttrs (name: _: name != config.networking.hostName) syncthingDevices;
  otherDeviceNames = builtins.attrNames otherDevices;
in
{
  services.syncthing = {
    enable = true;
    user = "mishok13";
    group = "users";
    dataDir = "/home/mishok13";
    openDefaultPorts = true;
    overrideDevices = true;
    overrideFolders = true;

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
