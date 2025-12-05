test-renovate:
    LOG_LEVEL=debug npx renovate --platform=local --repository-cache=reset

dotfiles-apply:
    home-manager switch --flake ./home-manager#mishok13

nixos-build *target:
    nix run 'nixpkgs#nixos-rebuild' -- build --flake '.#{{target}}' --target-host {{target}} --sudo --build-host {{target}}

nixos-switch *target:
    nix run 'nixpkgs#nixos-rebuild' -- switch --flake '.#{{target}}' --target-host {{target}} --sudo --build-host {{target}}
