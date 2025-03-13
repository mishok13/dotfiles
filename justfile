bootstrap:
    install xcode
    install brew

test-renovate:
    LOG_LEVEL=debug npx renovate --platform=local --repository-cache=reset
