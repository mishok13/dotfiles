{
  config,
  lib,
  pkgs,
  ...
}:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  networking.firewall = {
    enable = true;
    # As per https://github.com/tailscale/tailscale/issues/4432#issuecomment-1112819111 this is the only way to
    # get Tailscale to work with exit nodes
    checkReversePath = "loose";
    # The ports open here are likely excessive and should be trimmed to the minimum required
    allowedTCPPorts = [
      80
      443
      3478
    ];
    allowedUDPPorts = [
      41641
      3478
    ];
  };

  environment.systemPackages = with pkgs; [
    vim
    htop
    unixtools.netstat
    dig
  ];

  services.openssh.enable = true;

  services.tailscale = {
    enable = true;
    authKeyFile = config.sops.secrets.tailscaleAuthKey.path;
    extraUpFlags = [
      "--accept-routes"
      "--accept-dns"
    ];
    extraSetFlags = [
      "--exit-node=orangepi"
      "--exit-node-allow-lan-access"
    ];
  };

  systemd.services.tailscaled.serviceConfig.RestartSec = "5s";
  systemd.services.tailscaled.stopIfChanged = false;

  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  sops.defaultSopsFile = ./secrets/secrets.yaml;
  sops.secrets.tailscaleAuthKey = { };
  sops.secrets.gitlabRunnerAuthenticationToken = { };

  # Create the GitLab runner authentication token file in the correct format
  sops.templates."gitlab-runner-auth".content = ''
    CI_SERVER_URL=https://gitlab.com
    CI_SERVER_TOKEN=${config.sops.placeholder.gitlabRunnerAuthenticationToken}
  '';

  services.prometheus.exporters.node = {
    enable = true;
    openFirewall = true;
    enabledCollectors = [
      "systemd"
    ];
  };

  virtualisation.docker = {
    enable = true;
  };

  services.gitlab-runner = {
    enable = true;
    settings = {
      concurrent = 4;
    };
    services = {
      default = {
        authenticationTokenConfigFile = config.sops.templates."gitlab-runner-auth".path;
        dockerImage = "debian:testing";
        requestConcurrency = 2;
        limit = 4;
        description = "HomeLab runner";
      };
    };
  };

  # Required for uv-managed Python to work
  programs.nix-ld.enable = true;
}
