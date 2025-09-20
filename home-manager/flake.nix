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
    nix-ai-tools.url = "github:numtide/nix-ai-tools";
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
      mkHomeConfiguration =
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          pkgsLLM = nix-ai-tools.packages.${system};
        in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./home.nix ];
          extraSpecialArgs = {
            inherit nixgl system pkgsLLM;
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
