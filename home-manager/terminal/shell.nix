{ config, pkgs, ... }:

{
  programs = {
    bash = {
      enable = false;
      initExtra = ''
        if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
        then
          shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
          exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
        fi
      '';
    };

    fish = {
      enable = true;
      shellAbbrs = {
        l = "eza -la";
        c = "bat";
        hm = "home-manager";
        kns = "kubens";
        kx = "kubectx";
        k = "kubectl";
        kgp = "kubectl get pods";
        d = "docker";
        dbl = "docker build .";
        drn = "docker run --rm ";
        dex = "docker exec";
      };
      # It seems that there's just no other way to make `fish` behave if it's used as the default command in
      # kitty or ghostty. Just straight up direct manipulation of the PATH.
      interactiveShellInit = ''
        set fish_greeting
        fish_add_path /nix/var/nix/profiles/default/bin/
        fish_add_path $HOME/.nix-profile/bin/
      '';
      shellInitLast = ''
        fzf_configure_bindings
        set -gx ATUIN_NOBIND "true"
        atuin init fish | source
        bind alt-r _atuin_bind_up
        bind ctrl-r _atuin_search
      '';
      binds = {
        "alt-c".command = "commandline ~/ && _fzf_search_directory";
      };
      plugins = [
        {
          name = "fzf";
          src = pkgs.fetchFromGitHub {
            owner = "PatrickF1";
            repo = "fzf.fish";
            rev = "8920367cf85eee5218cc25a11e209d46e2591e7a";
            hash = "sha256-T8KYLA/r/gOKvAivKRoeqIwE2pINlxFQtZJHpOy9GMM=";
          };
        }
      ];
    };

    starship = {
      enable = true;
      enableFishIntegration = true;
      settings = {
        git_commit = {
          tag_disabled = false;
        };
        docker_context = {
          disabled = true;
        };
        gcloud = {
          disabled = true;
        };
        python = {
          format = "[\${symbol}(\${version} )]($style)";
        };
        aws = {
          disabled = true;
        };
        kubernetes = {
          disabled = false;
          detect_files = [ "k8s" ];
        };
        package = {
          disabled = true;
        };
        directory = {
          truncate_to_repo = false;
        };
        nodejs = {
          disabled = true;
        };
      };
    };

    atuin = {
      enable = true;
      daemon.enable = pkgs.stdenv.hostPlatform.isLinux;
      enableFishIntegration = true;
      settings = {
        sync_address = "https://atuin.mishok13.me";
        filter_mode_shell_up_key_binding = "directory";
      };
    };

    mise = {
      enable = true;
      enableFishIntegration = true;
    };
  };
}
