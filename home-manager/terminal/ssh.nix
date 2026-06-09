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
          IdentityFile = "~/.ssh/work";
        };
      };
    };
  };
}
