set brewcmd (path filter /opt/homebrew/bin/brew /home/linuxbrew/.linuxbrew/bin/brew)[1]
and $brewcmd shellenv | source

fish_add_path ~/.local/bin
fish_add_path ~/.cargo/bin

if status is-interactive
    if test -d (brew --prefix)"/share/fish/completions"
        set -p fish_complete_path (brew --prefix)/share/fish/completions
    end

    if test -d (brew --prefix)"/share/fish/vendor_completions.d"
        set -p fish_complete_path (brew --prefix)/share/fish/vendor_completions.d
    end

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

    if string match -q -- "*WSL2*" (uname -r)
        set windows_username (whoami.exe | cut -d '\\' -f 2 | string replace -ra '[^\w]+' '')
        abbr -a -g op /mnt/c/Users/$windows_username/AppData/local/Microsoft/WinGet/Links/op.exe
        if ! path is /run/user/1000
            sudo mkdir -p /run/user/1000
            sudo chown -R mishok13:mishok13 /run/user/1000
        end
    end
end
