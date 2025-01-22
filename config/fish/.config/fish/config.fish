if status is-interactive
    fzf_configure_bindings --directory=\ec --history=\e\cr
    atuin init fish | source

    abbr -a -g k kubectl
    abbr -a -g kex kubectl exec -i -t
    abbr -a -g kg kubectl get
    abbr -a -g kgp kubectl get pods
    abbr -a -g kx kubectx
    abbr -a -g kns kubens

    abbr -a -g l eza
    abbr -a -g la eza -la
    abbr -a -g lt eza -T

end
