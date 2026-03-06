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
      mkHomeConfig =
        {
          commitSignProgram,
          sshCommand,
          system,
          user,
        }:
        {
          modules =
            if system == "aarch64-darwin" then
              [
                ./home-manager/macos.nix
                ./home-manager/onepassword.nix
                {
                  home.username = user;
                  home.homeDirectory = "/Users/${user}";
                }
              ]
            else
              [
                ./home-manager/home.nix
                {
                  home.username = user;
                  home.homeDirectory = "/home/${user}";
                }
              ];
          extraSpecialArgs = {
            inherit
              nixgl
              system
              commitSignProgram
              sshCommand
              ;
            pkgsLLM = nix-ai-tools.packages.${system};
          };
          pkgs = nixpkgs.legacyPackages.${system};
        };
    in
    {
      homeConfigurations = {
        "mishok13" = home-manager.lib.homeManagerConfiguration (mkHomeConfig {
          commitSignProgram = "/opt/1Password/op-ssh-sign";
          sshCommand = "ssh";
          system = "x86_64-linux";
          user = "mishok13";
        });
        "C307G4T99J" = home-manager.lib.homeManagerConfiguration (mkHomeConfig {
          commitSignProgram = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
          sshCommand = "ssh";
          system = "aarch64-darwin";
          user = "Andrii.Mishkovskyi";
        });
        "wsl" = home-manager.lib.homeManagerConfiguration (mkHomeConfig {
          commitSignProgram = "/mnt/c/Users/mishok13/AppData/Local/1Password/app/8/op-ssh-sign-wsl";
          sshCommand = "ssh.exe";
          system = "x86_64-linux";
          user = "mishok13";
        });
      };

      nixosConfigurations = {
        beafiboi = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
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
