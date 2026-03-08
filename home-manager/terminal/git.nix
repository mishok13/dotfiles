{ config, lib, ... }:

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

      gh = {
        enable = true;
        settings = {
          git_protocol = "ssh";
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
