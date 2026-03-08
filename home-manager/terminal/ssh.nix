{ config, pkgs, ... }:

{
  programs = {
    ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks = {
        "orangepi" = {
          user = "ubuntu";
        };
        "*" = {
          identityAgent = "~/.1password/agent.sock";
        };
        "shellhub.com" = {
          hostname = "github.com";
          identityFile = "~/.ssh/work";
        };
      };
    };
  };
}
