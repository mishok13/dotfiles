{
  description = "Home Manager configuration of mishok13";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-ai-tools = {
      url = "github:numtide/nix-ai-tools";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      nixgl,
      nix-ai-tools,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      pkgsLLM = nix-ai-tools.packages.${system};
      commitSignProgram = "/opt/1Password/op-ssh-sign";
      sshCommand = "ssh";
    in
    {
      homeConfigurations = {
        "mishok13" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./home.nix ];
          extraSpecialArgs = {
            inherit
              nixgl
              system
              pkgsLLM
              commitSignProgram
              sshCommand
              ;
          };
        };
        "wsl" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./home.nix ];
          extraSpecialArgs = {
            inherit
              nixgl
              system
              pkgsLLM
              ;
            commitSignProgram = "/mnt/c/Users/mishok13/AppData/Local/1Password/app/8/op-ssh-sign-wsl";
            sshCommand = "ssh.exe";
          };
        };
      };
    };
}
