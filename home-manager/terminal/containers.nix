{ config, pkgs, ... }:

let
  isMacOS = pkgs.stdenv.hostPlatform.isDarwin;
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
          "gnvasandbox.azurecr.io" = { };
          "gnvatest.azurecr.io" = { };
          "gnvapreprod.azurecr.io" = { };
          "shellgeneva.azurecr.io" = { };
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
    pkgs.docker-client
    pkgs.docker-buildx
    pkgs.docker-compose
    pkgs.docker-credential-helpers
    pkgs.dive
    pkgs.kubectl
    pkgs.krew
    pkgs.kubelogin
    pkgs.kubectx
    pkgs.stern
    pkgs.k9s
    pkgs.trivy
  ];
}
