{ config, pkgs, ... }:

let
  isMacOS = pkgs.stdenv.isDarwin;
in
{
  programs = {
    kubecolor = {
      enable = true;
    };

    docker-cli = {
      enable = true;
      settings = {
        auths = {
          "ghcr.io" = { };
        };
        credsStore = if isMacOS then "osxkeychain" else "secretservice";
      };
    };

    lazydocker = {
      enable = true;
    };
  };

  services = {
    colima = {
      enable = isMacOS;
      # profiles  = {
      #   default = {
      #     isActive = true;
      #     isService = true;
      #     settings = {
      #       cpu = 4;
      #       memory = 6;
      #     };
      #   };
      # };
    };
  };

  home.packages = [
    pkgs.docker-buildx
    pkgs.docker-compose
    pkgs.dive
  ];
}
