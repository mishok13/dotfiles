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

docker-services *hosts:
    #!/usr/bin/env nu
    let valid_hosts = [orangepi]
    let hosts = "{{ hosts }}" | split words | where {|host| $host != ""} | str downcase | uniq
    let invalid = $hosts | where {|h| $h not-in $valid_hosts}

    if ($invalid | is-not-empty) {
        print $"Error: Unknown hosts: ($invalid | str join ', '). Valid hosts: ($valid_hosts | str join ', ')"
        exit 1
    }

    let targets = if ($hosts | is-empty) { $valid_hosts } else { $hosts }
    print $"==> Requested targets: ($targets | str join ', ')"

    $targets | par-each { |target|
        print $"==> Deploying Docker Compose files to ($target)..."
        rsync -avz orchestration/playbooks/templates/compose-$"($target)".yaml $"($target):~/.config/compose.yaml"
        rsync -avz orchestration/playbooks/templates/compose/ $"($target):~/.config/compose/"
        print $"==> Running docker compose up -d on ($target)..."
        ssh $target "cd ~/.config && docker compose up -d --remove-orphans --pull always"
        print $"==> Successfully deployed to ($target)"
    }
    print "==> All deployments complete!"
