{
  config,
  lib,
  pkgs,
  syncthingDevices,
  ...
}:

{
  services.syncthing = {
    enable = true;
    overrideDevices = false;
    overrideFolders = false;

    settings = {
      devices = syncthingDevices;

      folders = {
        "Downloads" = {
          path = "${config.home.homeDirectory}/Downloads";
          devices = builtins.attrNames syncthingDevices;
          ignoreDelete = false;
        };
        "Screenshots" = {
          path = "${config.home.homeDirectory}/Screenshots";
          devices = builtins.attrNames syncthingDevices;
          ignoreDelete = false;
        };
        "Documents" = {
          path = "${config.home.homeDirectory}/Documents";
          devices = builtins.attrNames syncthingDevices;
          ignoreDelete = true;
        };
        "notes" = {
          path = "${config.home.homeDirectory}/nonwork/notes";
          devices = builtins.attrNames syncthingDevices;
          ignoreDelete = true;
        };
      };
    };
  };
}
