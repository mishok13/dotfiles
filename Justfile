test-renovate:
    nix run nixpkgs#renovate -- --platform=local --repository-cache=reset

apply profile=`hostname`:
    home-manager switch --flake .#{{profile}}

build profile=`hostname`:
    home-manager build --flake .#{{profile}}

update input="":
    nix flake update {{input}}

nixos-build config host=config:
    nix run 'nixpkgs#nixos-rebuild' -- build --flake '.#{{ config }}' --target-host {{ host }} --sudo --build-host {{ host }}

nixos-switch config host=config:
    nix run 'nixpkgs#nixos-rebuild' -- switch --flake '.#{{ config }}' --target-host {{ host }} --sudo --build-host {{ host }}

nixos-boot config host=config:
    nix run 'nixpkgs#nixos-rebuild' -- boot --flake '.#{{ config }}' --target-host {{ host }} --sudo --build-host {{ host }}

docker-services:
    rsync -avz orchestration/playbooks/templates/compose-orangepi.yaml orangepi:~/.config/compose.yaml
    ssh orangepi "cd ~/.config && docker compose up -d --remove-orphans --pull always"
