{
  config,
  pkgs,
  lib,
  ...
}:

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
    xdg.configFile."git/allowed_signers.nonwork".text = ''
      548482+mishok13@users.noreply.github.com namespaces="git" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG7AIn/xIHtxP6BIJzzc1RtljcQ1d8K0EEraz3ugFi4A
    '';

    home.packages = [
      pkgs.actionlint
      pkgs.git-absorb
      pkgs.git-autofixup
      pkgs.glab
      pkgs.pinact
      pkgs.zizmor
    ];

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
          http = {
            sslVerify = false;
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
                "git@shellhub.com:sede-enterprise/" = {
                  insteadOf = "git@github.com:sede-enterprise/";
                };
              };
              include = {
                path = "~/.config/git/sensitive.work";
              };
              "gpg \"ssh\"" = {
                allowedSignersFile = "~/.config/git/allowed_signers.work";
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
              "gpg \"ssh\"" = {
                allowedSignersFile = "~/.config/git/allowed_signers.nonwork";
              };
            };
          }
        ];

        ignores = [
          "**/.claude/settings.local.json"
          "**/.agent-shell/"
        ];
      };

      gh = {
        enable = true;
        extensions = [
          pkgs.gh-stack
        ];
        settings = {
          git_protocol = "ssh";
          editor = "hx";
          aliases = {
            ci = "pr checks --watch";
            prm = "pr merge -d -s";
            prv = "pr view";
            prw = "pr view -w";
          };
        };
      };
    };
  };
}
