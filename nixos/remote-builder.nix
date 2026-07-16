# Remote builder user configuration
# Creates a system user for remote Nix builds
{
  config,
  lib,
  pkgs,
  ...
}:

{
  users.users.remotebuild = {
    isSystemUser = true;
    group = "remotebuild";
    useDefaultShell = true;

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDg9UWz1sYTeA0lFV7C9QZGC7J+baSB4ZZAoYyXvS9w4"
    ];
  };

  users.groups.remotebuild = { };

  nix.settings.trusted-users = [ "remotebuild" ];
}
