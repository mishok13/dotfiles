test-renovate:
    LOG_LEVEL=debug npx renovate --platform=local --repository-cache=reset

dotfiles-apply:
    home-manager switch --flake ./home-manager#mishok13
