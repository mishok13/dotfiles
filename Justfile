export NIX_CONFIG := "access-tokens = github.com=" + `gh auth token`

test-renovate:
    nix run nixpkgs#renovate -- --platform=local --repository-cache=reset

apply profile=`hostname`:
    home-manager switch --flake .#{{profile}}

build profile=`hostname`:
    home-manager build --flake .#{{profile}}

cache-push:
    #!/usr/bin/env sh
    set -eu
    gen=$(readlink -f ~/.local/state/nix/profiles/home-manager)
    nix copy -s --no-check-sigs --to ssh-ng://bigboi "$gen"
    ssh bigboi "mkdir -p gcroots && nix-store --realise $gen --add-root gcroots/$(hostname)-home"

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
