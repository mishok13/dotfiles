{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./common.nix
    ./user.nix
    ./remote-builder.nix
    ./bigboi/hardware-configuration.nix
  ];

  networking.hostName = "bigboi";

  # NFS Server configuration
  services.nfs.server = {
    enable = true;
    exports = ''
      /mnt/media/share 100.64.0.0/10(rw,no_subtree_check,fsid=0) 192.168.0.0/24(rw,no_subtree_check,fsid=0) 192.168.0.20(rw,no_subtree_check,insecure,fsid=0)
      /mnt/media 100.64.0.0/10(ro,no_subtree_check,fsid=1) 192.168.0.0/24(ro,no_subtree_check,fsid=1) 192.168.0.20(ro,no_subtree_check,insecure,fsid=1)
    '';
  };

  # Open NFS ports
  networking.firewall.allowedTCPPorts = [ 2049 ];
  networking.firewall.allowedUDPPorts = [ 2049 ];

  # Samba server configuration
  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        workgroup = "WORKGROUP";
        "server role" = "standalone server";
        "log file" = "/var/log/samba/log.%m";
        "max log size" = 1000;
        "logging" = "file";
        "map to guest" = "bad user";
        "usershare allow guests" = "yes";
      };
      public = {
        browseable = "yes";
        comment = "Public samba share.";
        "guest ok" = "yes";
        path = "/mnt/media";
        "read only" = "yes";
      };
    };
  };

  # Enable winbind for Samba
  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };

  system.stateVersion = "26.05";
}
