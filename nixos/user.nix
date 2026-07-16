# Primary user configuration
{
  config,
  lib,
  pkgs,
  ...
}:

{
  users.users.mishok13 = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "docker"
    ];

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHq59/s7ucbxhQD4gdjkK6u/mK9P2497o1FpSG5XcgqP"
    ];
  };

  security.sudo.wheelNeedsPassword = false;
}
