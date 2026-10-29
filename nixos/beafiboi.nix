{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./common.nix
    ./syncthing.nix
    ./user.nix
    ./remote-builder.nix
    ./build-offload.nix
    ./nfs.nix
    ./caddy.nix
    ./beafiboi/containers.nix
    ./beafiboi/hardware-configuration.nix
  ];
  networking.hostName = "beafiboi";
  networking.firewall.allowedTCPPorts = [ 9400 ];
  system.stateVersion = "25.05";

  caddy = {
    jellyfin = 8096;
    ollama = 11434;
  };

  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    open = false;
    modesetting.enable = true;
    # Tesla P4 is not supported in newer versions ;(
    package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
  };
  hardware.nvidia-container-toolkit.enable = true;

  nixpkgs.config.allowUnfree = true;

  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda.override {
      cudaPackages = pkgs.cudaPackages_12;
      # Query with `nvidia-smi --query-gpu=compute_cap`
      cudaArches = [ "61" ];
    };
    loadModels = [
      "qwen2.5-coder:7b"
      "codellama:7b"
      "deepseek-coder-v2:16b"

      "llama3.2:3b"
      "mistral:7b"
      "qwen2.5:7b"
      "llama3.1:8b"

      "llama3.2:3b"
      "phi3:3.8b"
    ];
    openFirewall = false;
    host = "127.0.0.1";
  };
}
