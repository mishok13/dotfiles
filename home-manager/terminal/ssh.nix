{ config, pkgs, ... }:

{
  programs = {
    ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings = {
        "orangepi" = {
          User = "ubuntu";
        };
        "*" = {
          IdentityAgent = "~/.1password/agent.sock";
          ServerAliveInterval = 60;
          ServerAliveCountMax = 3;
        };
        "shellhub.com" = {
          Hostname = "github.com";
          # Note that ~/.ssh/work would need to be generated with `op` if it's not present
          IdentityFile = "~/.ssh/work";
          IdentitiesOnly = true;
        };
      };
    };
  };
}
