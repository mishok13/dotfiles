{
  config,
  lib,
  hostname,
  ...
}:

let
  syncthing = import ../syncthing/lib.nix {
    inherit lib hostname;
    homeDir = config.home.homeDirectory;
  };
in
{
  services.syncthing = {
    enable = true;
    overrideDevices = false;
    overrideFolders = false;

    settings = {
      inherit (syncthing) devices folders;
    };
  };
}
