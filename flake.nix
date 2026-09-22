{
  description = "NixOS + home manager config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-26.05";

    # Dedicated nixpkgs pin for caddy so its FOD vendor hash only churns when this
    # input is bumped, not on weekly lockfile maintenance. Kept as a fixed commit on
    # purpose: `nix flake update` cannot move a commit-pinned input, so weekly
    # maintenance leaves caddy untouched. Renovate bumps this commit monthly via the
    # `nixpkgs-caddy` customManager in renovate.json; the caddy-hash workflow then
    # syncs flake.lock and fixes the vendor hash.
    nixpkgs-caddy.url = "github:nixos/nixpkgs/4df1b885d76a54e1aa1a318f8d16fd6005b6401f";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    llm-agents = {
      url = "github:numtide/llm-agents.nix";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

  };

  outputs =
    {
      nixpkgs,
      nixpkgs-caddy,
      nixpkgs-stable,
      home-manager,
      nixgl,
      llm-agents,
      sops-nix,
      ...
    }:
    let
      stableOverlay =
        system:
        (
          _final: _prev:
          let
            stable = import nixpkgs-stable { inherit system; };
          in
          {
            inherit (stable) emacs emacsPackagesFor;
          }
        );
      pkgsFor =
        system:
        import nixpkgs {
          inherit system;
          overlays = [ (stableOverlay system) ];
        };
      linuxPkgs = pkgsFor "x86_64-linux";
      darwinPkgs = pkgsFor "aarch64-darwin";
    in
    {
      homeConfigurations = {
        "trakehner" = home-manager.lib.homeManagerConfiguration {
          modules = [
            ./home-manager/linux.nix
            ./home-manager/ghostty.nix
            {
              home.username = "mishok13";
              home.homeDirectory = "/home/mishok13";
            }
          ];
          extraSpecialArgs = {
            inherit nixgl;
            hostname = "trakehner";
            system = "x86_64-linux";
            commitSignProgram = "/opt/1Password/op-ssh-sign";
            sshCommand = "ssh";
            pkgsLLM = llm-agents.packages."x86_64-linux";
          };
          pkgs = linuxPkgs;
        };
        "clydesdale" = home-manager.lib.homeManagerConfiguration {
          modules = [
            ./home-manager/linux.nix
            ./home-manager/ghostty.nix
            {
              home.username = "mishok13";
              home.homeDirectory = "/home/mishok13";
            }
          ];
          extraSpecialArgs = {
            inherit nixgl;
            hostname = "clydesdale";
            system = "x86_64-linux";
            commitSignProgram = "/opt/1Password/op-ssh-sign";
            sshCommand = "ssh";
            pkgsLLM = llm-agents.packages."x86_64-linux";
          };
          pkgs = linuxPkgs;
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
            pkgsLLM = llm-agents.packages."aarch64-darwin";
          };
          pkgs = darwinPkgs;
        };
      };

      nixosConfigurations = {
        beafiboi = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            pkgsCaddy = nixpkgs-caddy.legacyPackages."x86_64-linux";
          };
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
                pkgsLLM = llm-agents.packages."x86_64-linux";
                system = "x86_64-linux";
                commitSignProgram = "/opt/1Password/op-ssh-sign";
                sshCommand = "ssh";
              };
            }
          ];
        };
        bigboi = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            pkgsCaddy = nixpkgs-caddy.legacyPackages."x86_64-linux";
          };
          modules = [
            ./nixos/bigboi.nix
            sops-nix.nixosModules.sops
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = false;
              home-manager.useUserPackages = true;
              home-manager.users.mishok13 = import ./home-manager/server.nix;
              home-manager.extraSpecialArgs = {
                inherit nixgl sops-nix;
                system = "x86_64-linux";
                pkgsLLM = llm-agents.packages."x86_64-linux";
                commitSignProgram = "/opt/1Password/op-ssh-sign";
                sshCommand = "ssh";
              };
            }
          ];
        };
        tiniboi = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            pkgsCaddy = nixpkgs-caddy.legacyPackages."x86_64-linux";
          };
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
                pkgsLLM = llm-agents.packages."x86_64-linux";
                commitSignProgram = "/opt/1Password/op-ssh-sign";
                sshCommand = "ssh";
              };
            }
          ];
        };
      };
    };
}
