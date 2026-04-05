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
      inputs.nixpkgs.follows = "nixpkgs-stable";
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
      syncthingDevices = {
        tiniboi = {
          id = "KGJIQ7E-4QRMOTX-NWZ4ZCC-4MJFKCD-PDEVO73-OYBEPSK-DIEHTMC-OLRXUAE";
        };
        beafiboi = {
          id = "A43OEPY-MXDKEEL-PWPKD4L-F2SMCPS-OFWR5L4-56WJGBE-CF6LXIE-5EEMCA6";
        };
        clydesdale = {
          id = "3N565CZ-BQ53D2P-CRX2Y75-PH2A3N5-475JVFI-AQAUM4X-BAVS7WG-ITMHFQX";
        };
      };
    in
    {
      homeConfigurations = {
        "trakehner" = home-manager.lib.homeManagerConfiguration {
          modules = [
            ./home-manager/home.nix
            ./home-manager/ghostty.nix
            {
              home.username = "mishok13";
              home.homeDirectory = "/home/mishok13";
            }
          ];
          extraSpecialArgs = {
            inherit nixgl;
            system = "x86_64-linux";
            commitSignProgram = "/opt/1Password/op-ssh-sign";
            sshCommand = "ssh";
            pkgsLLM = nix-ai-tools.packages."x86_64-linux";
          };
          pkgs = nixpkgs.legacyPackages."x86_64-linux";
        };
        "clydesdale" = home-manager.lib.homeManagerConfiguration {
          modules = [
            ./home-manager/home.nix
            ./home-manager/syncthing.nix
            {
              home.username = "mishok13";
              home.homeDirectory = "/home/mishok13";
            }
          ];
          extraSpecialArgs = {
            inherit nixgl syncthingDevices;
            system = "x86_64-linux";
            commitSignProgram = "/opt/1Password/op-ssh-sign";
            sshCommand = "ssh";
            pkgsLLM = nix-ai-tools.packages."x86_64-linux";
          };
          pkgs = nixpkgs.legacyPackages."x86_64-linux";
        };
        "C307G4T99J" = home-manager.lib.homeManagerConfiguration {
          modules = [
            ./home-manager/macos.nix
            ./home-manager/onepassword.nix
            ./home-manager/ghostty.nix
            {
              home.username = "Andrii.Mishkovskyi";
              home.homeDirectory = "/Users/Andrii.Mishkovskyi";
            }
          ];
          extraSpecialArgs = {
            system = "aarch64-darwin";
            commitSignProgram = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
            sshCommand = "ssh";
            pkgsLLM = nix-ai-tools.packages."aarch64-darwin";
          };
          pkgs = nixpkgs.legacyPackages."aarch64-darwin";
        };
      };

      nixosConfigurations = {
        beafiboi = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit syncthingDevices; };
          modules = [
            ./nixos/beafiboi.nix
            sops-nix.nixosModules.sops
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = false;
              home-manager.useUserPackages = true;
              home-manager.users.mishok13 = import ./home-manager/server.nix;
              home-manager.extraSpecialArgs = {
                inherit nixgl sops-nix;
                pkgsLLM = nix-ai-tools.packages."x86_64-linux";
                system = "x86_64-linux";
                commitSignProgram = "/opt/1Password/op-ssh-sign";
                sshCommand = "ssh";
              };
            }
          ];
        };
        tiniboi = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit syncthingDevices; };
          modules = [
            ./nixos/tiniboi.nix
            sops-nix.nixosModules.sops
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = false;
              home-manager.useUserPackages = true;
              home-manager.users.mishok13 = import ./home-manager/server.nix;
              home-manager.extraSpecialArgs = {
                inherit nixgl sops-nix;
                system = "x86_64-linux";
                pkgsLLM = nix-ai-tools.packages."x86_64-linux";
                commitSignProgram = "/opt/1Password/op-ssh-sign";
                sshCommand = "ssh";
              };
            }
          ];
        };
      };
    };
}
