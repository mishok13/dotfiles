{
  config,
  pkgs,
  lib,
  system,
  ...
}:

{
  home.file = {
    ".config/1Password/ssh/agent.toml".source = (pkgs.formats.toml { }).generate "dummy" {
      ssh-keys = [
        {
          item = "GitHub";
          vault = "Personal";
        }
        {
          item = "GitHub Shell";
          vault = "Shell";
        }
      ];
    };
  };

}
