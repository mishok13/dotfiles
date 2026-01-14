{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./common.nix
    ./beafiboi/hardware-configuration.nix
  ];
  networking.hostName = "beafiboi";
  system.stateVersion = "25.05";

  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    open = false;
    modesetting.enable = true;
  };
  hardware.nvidia-container-toolkit.enable = true;

  nixpkgs.config.allowUnfree = true;

  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda.override {
      # Workaround from https://github.com/NixOS/nixpkgs/issues/421775#issuecomment-3689793418
      # Query with `nvidia-smi --query-gpu=compute_cap`
      cudaArches = [ "61" ];
    };
    loadModels = [
      "qwen2.5-coder:7b"
      "codellama:7b"
      "deepseek-coder-v2:7b"

      "llama3.2:7b"
      "mistral:7b"
      "qwen2.5:7b"
      "llama3.1:8b"

      "llama3.2:3b"
      "phi3:3.8b"
    ];
    openFirewall = true;
    host = "0.0.0.0";
  };
}
