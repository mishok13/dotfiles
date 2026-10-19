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
      # Host keys for build offload (nix.buildMachines targets bigboi).
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMQe03ZS0a4Z00qUIcK7wf0HKOTVilopmkTSD+4/tecF" # tiniboi
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICkf6d3pmDjWncaeFd2mo2tJ6jtl+7h386q3wi/x33WA" # beafiboi
    ];
  };

  users.groups.remotebuild = { };

  nix.settings.trusted-users = [ "remotebuild" ];
}
