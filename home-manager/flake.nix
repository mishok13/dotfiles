{
  description = "Home Manager configuration of mishok13";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      nixgl,
      ...
    }:
    let
      mkHomeConfiguration =
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          # Specify your home configuration modules here, for example,
          # the path to your home.nix.
          modules = [ ./home.nix ];

          # Optionally use extraSpecialArgs
          # to pass through arguments to home.nix
          extraSpecialArgs = {
            inherit nixgl system;
          };
        };
    in
    {
      homeConfigurations = {
        "mishok13" = mkHomeConfiguration "x86_64-linux";
        "mishok13-aarch64-linux" = mkHomeConfiguration "aarch64-linux";
        "mishok13-x86_64-darwin" = mkHomeConfiguration "x86_64-darwin";
        "mishok13-aarch64-darwin" = mkHomeConfiguration "aarch64-darwin";
      };
    };
}
