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

  users.users.mishok13 = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHq59/s7ucbxhQD4gdjkK6u/mK9P2497o1FpSG5XcgqP"
    ];
  };

  security.sudo.wheelNeedsPassword = false;

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

  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  sops.defaultSopsFile = ./secrets/example.yaml;
  sops.secrets.tailscaleAuthKey = { };

  fileSystems."/mnt/media" = {
    device = "bigboi:/mnt/media";
    fsType = "nfs";
    options = [
      "x-systemd.automount"
      "noauto"
      "x-systemd.idle-timeout=600"
      "ro"
    ];
  };

  fileSystems."/mnt/media/share" = {
    device = "bigboi:/mnt/media/share";
    fsType = "nfs";
    options = [
      "x-systemd.automount"
      "noauto"
      "x-systemd.idle-timeout=600"
      "rw"
    ];
  };

  services.prometheus.exporters.node = {
    enable = true;
    openFirewall = true;
    enabledCollectors = [
      "systemd"
    ];
  };

}
