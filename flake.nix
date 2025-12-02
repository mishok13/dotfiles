{
  description = "NixOS + home manager config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";

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
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      nixgl,
      nix-ai-tools,
      sops-nix,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      pkgsLLM = nix-ai-tools.packages.${system};
      mkHomeConfig =
        { commitSignProgram, sshCommand }:
        {
          inherit pkgs;
          modules = [ ./home-manager/home.nix ];
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
    in
    {
      homeConfigurations = {
        "mishok13" = home-manager.lib.homeManagerConfiguration (mkHomeConfig {
          commitSignProgram = "/opt/1Password/op-ssh-sign";
          sshCommand = "ssh";
        });
        "wsl" = home-manager.lib.homeManagerConfiguration (mkHomeConfig {
          commitSignProgram = "/mnt/c/Users/mishok13/AppData/Local/1Password/app/8/op-ssh-sign-wsl";
          sshCommand = "ssh.exe";
        });
      };

      nixosConfigurations = {
        tiniboi = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./nixos/tiniboi/configuration.nix
            sops-nix.nixosModules.sops
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = false;
              home-manager.useUserPackages = true;
              home-manager.users.mishok13 = import ./home-manager/tiniboi.nix;
              home-manager.extraSpecialArgs = {
                inherit nixgl pkgsLLM sops-nix;
                system = "x86_64-linux";
                commitSignProgram = "/opt/1Password/op-ssh-sign";
                sshCommand = "ssh";
              };
            }
          ];
        };
      };
    };
}
