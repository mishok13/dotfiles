test-renovate:
    nix run nixpkgs#renovate -- --platform=local --repository-cache=reset

apply profile="mishok13":
    home-manager switch --flake .#{{profile}}

build profile="mishok13":
    home-manager build --flake .#{{profile}}

update input="":
    nix flake update {{input}}

nixos-build *target:
    nix run 'nixpkgs#nixos-rebuild' -- build --flake '.#{{ target }}' --target-host {{ target }} --sudo --build-host {{ target }}

nixos-switch *target:
    nix run 'nixpkgs#nixos-rebuild' -- switch --flake '.#{{ target }}' --target-host {{ target }} --sudo --build-host {{ target }}

docker-services *hosts:
    #!/usr/bin/env nu
    let valid_hosts = [orangepi bigboi beafiboi tiniboi]
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
