# NFS client configuration for mounting bigboi shares
{
  config,
  lib,
  pkgs,
  ...
}:

{
  fileSystems."/mnt/media" = {
    device = "bigboi:/mnt/media";
    fsType = "nfs";
    options = [
      "x-systemd.automount"
      "noauto"
      "x-systemd.idle-timeout=600"
      "ro"
    ];
  };

  fileSystems."/mnt/media/share" = {
    device = "bigboi:/mnt/media/share";
    fsType = "nfs";
    options = [
      "x-systemd.automount"
      "noauto"
      "x-systemd.idle-timeout=600"
      "rw"
    ];
  };
}
