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
  options = {
    terminal.commitSignProgram = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Path to the GPG signing program for git commits";
    };
    terminal.sshCommand = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "ssh command to use by git";
    };
  };

  config = {
    programs = {
      git = {
        enable = true;
        settings = {
          user = {
            name = "Andrii Mishkovskyi";
            useConfigOnly = true;
          };
          init = {
            defaultBranch = "main";
            templateDir = "~/.local/share/git/templates/";
          };
          user = {

          };
          core = lib.mkIf (config.terminal.sshCommand != null) {
            sshCommand = config.terminal.sshCommand;
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
          "gpg \"ssh\"" = lib.mkIf (config.terminal.commitSignProgram != null) {
            program = config.terminal.commitSignProgram;
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
        interactiveShellInit = ''
          set fish_greeting
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
        enableFishIntegration = false;
        settings = {
          sync_address = "https://atuin.mishok13.me";
          filter_mode_shell_up_key_binding = "directory";
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

      gh = {
        enable = true;
        settings = {
          git_protocol = "ssh";
          aliases = {
            prm = "pr merge -d -s";
          };
        };
      };

      ssh = {
        enable = true;
        enableDefaultConfig = false;
        matchBlocks = {
          "orangepi" = {
            user = "ubuntu";
          };
          "*" = {
            identityAgent = "~/.1password/agent.sock";
          };
        };
      };
    };

    services = {
      spotifyd = {
        enable = true;
      };
      podman = {
        # sudo apt-get install uidmap is required for this to work in debian
        enable = true;
        containers = {
          budgeteer = {
            image = "docker.io/postgres:17.6@sha256:feff5b24fedd610975a1f5e743c51a4b360437f4dc3a11acf740dcd708f413f6";
            ports = [ "127.0.0.1:54320:5432" ];
            environment = {
              POSTGRES_PASSWORD = "foobarbaz";
            };
          };
        };
      };
    };

    home.packages = [
      pkgs.bat
      pkgs.cabal-install
      pkgs.clang
      pkgs.eza
      pkgs.fish
      pkgs.fzf
      pkgs.ghc # Required for nixfmt in pre-commit
      pkgs.glab
      pkgs.harper
      pkgs.just
      pkgs.mise
      pkgs.nixfmt-rfc-style
      pkgs.nixos-rebuild
      pkgs.nurl
      pkgs.pre-commit
      pkgs.ripgrep
      pkgs.rustup
      pkgs.starship
      pkgs.stow
      pkgs.tofu-ls
      pkgs.trufflehog
      pkgs.typst
      pkgs.typstyle
      pkgs.uiua
      pkgs.uv
      pkgs.vim
      pkgs.watchexec
      pkgs.zola
      pkgsLLM.amp
      pkgsLLM.claude-code
      pkgsLLM.codex
      pkgsLLM.gemini-cli
      # Disabled due to https://github.com/numtide/nix-ai-tools/issues/1116 :(
      # pkgsLLM.goose-cli
    ];

    home.file = {
      ".rgignore".text = builtins.concatStringsSep "\n" ignoredPaths;
    };

  };
}
