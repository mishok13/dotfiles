{
  config,
  pkgs,
  lib,
  nixgl,
  system,
  pkgsLLM,
  ...
}:

let
  ignoredPaths =
    builtins.map
      (
        path:
        builtins.concatStringsSep "/" [
          config.home.homeDirectory
          path
          "**"
        ]
      )
      [
        "Library"
        "Music"
        "Pictures"
        "Movies"
        "Videos"
      ];
in
{
  programs = {
    git = {
      enable = true;
      userName = "Andrii Mishkovskyi";
      extraConfig = {
        init = {
          defaultBranch = "main";
        };
        user = {
          useConfigOnly = true;
        };
        merge = {
          conflictStyle = "zdiff3";
          autostash = true;
        };
        pull = {
          autostash = true;
        };
        rebase = {
          autostash = true;
        };
        push = {
          autoSetupRemote = true;
        };
        fetch = {
          prune = true;
        };
        commit = {
          gpgsign = true;
        };
        gpg = {
          format = "ssh";
        };
        github = {
          user = "mishok13";
        };
        "gpg \"ssh\"" = {
          program =
            if pkgs.stdenv.isDarwin then
              "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
            else
              "/opt/1Password/op-ssh-sign";
        };
      };

      # Conditional includes for work/nonwork directories
      includes = [
        {
          condition = "gitdir:~/work/**";
          contents = {
            init = {
              templatedir = "~/work/.gittemplate";
            };
            url = {
              "kpn-github:" = {
                insteadOf = "git@github.com:";
              };
              "kpn-gitlab:" = {
                insteadOf = "git@gitlab.com:";
              };
            };
            include = {
              path = "~/.config/git/sensitive.work";
            };
          };
        }
        {
          condition = "gitdir:~/nonwork/**";
          contents = {
            user = {
              email = "548482+mishok13@users.noreply.github.com";
            };
            include = {
              path = "~/.config/git/sensitive.nonwork";
            };
          };
        }
      ];

      ignores = [
        "**/.claude/settings.local.json"
      ];
    };

    bash = {
      enable = false;
    };

    fish = {
      enable = true;
      shellAbbrs = {
        l = "eza -la";
        c = "bat";
        hm = "home-manager";
      };
      shellInitLast = ''
        fzf_configure_bindings
      '';
      binds = {
        "alt-c".command = "commandline ~/ && _fzf_search_directory";
      };
      # pkgs.fishPlugins.fzf-fish alternatively?
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

    ripgrep = {
      enable = true;
      arguments = [
        "--type-add=pypkg:{pyproject.toml,setup.py,setup.cfg,requirements.txt}"
        "--type-add=jenkins:{*.jenkinsfile,Jenkinsfile}"
        "--smart-case"
      ];
    };

    atuin = {
      enable = true;
      daemon.enable = true;
      enableFishIntegration = true;
      settings = {
        sync_address = "https://atuin.mishok13.me";
      };
    };

    mise = {
      enable = true;
      enableFishIntegration = true;
    };

    fd = {
      enable = true;
      hidden = true;
      ignores = ignoredPaths;
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
  };

  services = {
    spotifyd = {
      enable = true;
    };
  };

  home.packages = [
    pkgs.bat
    pkgs.cabal-install
    pkgs.clang
    pkgs.eza
    pkgs.fish
    pkgs.fzf
    pkgsLLM.amp
    pkgsLLM.claude-code
    pkgsLLM.codex
    pkgsLLM.gemini-cli
    pkgs.gh
    pkgs.ghc # Required for nixfmt in pre-commit
    pkgs.glab
    # Disabled due to issues with compiling it (i.e. running out of memory)
    # pkgs.goose-cli
    pkgs.just
    pkgs.mise
    pkgs.nixfmt-rfc-style
    pkgs.nurl
    pkgs.pre-commit
    pkgs.ripgrep
    pkgs.rustup
    pkgs.starship
    pkgs.stow
    pkgs.trufflehog
    pkgs.uv
  ];

  home.file = {
    # Git config now managed by Home Manager programs.git
    # Remove the external symlink

    ".rgignore".text = builtins.concatStringsSep "\n" ignoredPaths;
  };

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "claude-code"
    ];
}
