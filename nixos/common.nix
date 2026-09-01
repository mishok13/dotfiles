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
    # Kept loose as a precaution. It was originally required for Tailscale exit-node use
    # (https://github.com/tailscale/tailscale/issues/4432); these servers no longer use an
    # exit node (see services.tailscale below / dns-tier2-plan.md Phase 0.5), so strict
    # would likely also work, but loose is harmless and avoids surprises.
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

  # Install terminfo for all terminal emulators so SSH sessions from any client
  # (kitty, alacritty, wezterm, etc.) get a matching terminfo entry.
  environment.enableAllTerminfo = true;

  services.openssh.enable = true;

  services.tailscale = {
    enable = true;
    authKeyFile = config.sops.secrets.tailscaleAuthKey.path;
    # These servers are physically on the LAN and never roam, so they must NOT route their
    # own 192.168.0.0/24 through tailscale. Accepting orangepi's advertised subnet route
    # and/or using it as an exit node pushed the whole LAN subnet into tailscale's route
    # table 52 (consulted before the main table), which broke all direct LAN reachability
    # to these hosts — tailscale became the only path in. See dns-tier2-plan.md Phase 0.5.
    #
    # We keep --accept-dns (MagicDNS) but drop --accept-routes. Exit-node USE is a per-client
    # choice; orangepi still OFFERS the exit node, so roaming clients (e.g. trakehner) can
    # still use it. These flags are cleared via `tailscale set` (the tailscaled-set unit runs
    # on every activation) so already-running nodes converge without needing a re-auth
    # (tailscaled-autoconnect only runs `tailscale up` when logged out).
    extraUpFlags = [
      "--accept-dns"
    ];
    extraSetFlags = [
      "--accept-routes=false"
      "--exit-node="
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
