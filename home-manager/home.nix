{
  config,
  pkgs,
  lib,
  nixgl,
  ...
}:

{
  home.username = "mishok13";
  home.homeDirectory = "/home/mishok13";

  nixGL.packages = nixgl.packages;
  nixGL.defaultWrapper = "mesa";

  fonts.fontconfig.enable = true;

  programs = {
    git = {
      enable = false;
    };
    bash = {
      enable = false;
    };

    fish = {
      enable = true;
      shellAbbrs = {
        l = "eza -la";
        hm = "home-manager";
      };
      shellInitLast = ''
        fzf_configure_bindings
      '';
      binds = {
        "alt-c".command = "commandline ~/ && _fzf_search_directory";
      };
      # https://search.nixos.org/packages?channel=25.05&show=fishPlugins.fzf-fish&from=0&size=50&sort=relevance&type=packages&query=fzf-fish alternatively
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

    starship = {
      enable = true;
      enableFishIntegration = true;
      settings = {
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

    kitty = {
      enable = true;
      package = (config.lib.nixGL.wrap pkgs.kitty);
      font = {
        package = pkgs.nerd-fonts.hack;
        name = "Hack Nerd Font Mono";
        size = 14;
      };
      themeFile = "Catppuccin-Macchiato";
      settings = {
        cursor_beam_thickness = 2.0;
        cursor_stop_blinking_after = 10.0;
        scrollback_lines = 9999;
        scrollback_pager_history_size = 10;
        copy_on_select = true;
        macos_option_as_alt = true;
        enabled_layouts = "tall:bias=70;full_size=2,fat:bias=60;full_size=2;mirrored=false";
        hide_window_decorations = true;
        shell = "${pkgs.fish}/bin/fish";
      };
      keybindings = {
        "ctrl+shift+enter" = "launch --cwd=current";
        "ctrl+shift+1" = "launch";
        f1 = "clear_terminal scrollback active";
        f2 = "combine | new_window_with_cwd | new_window_with_cwd | new_window_with_cwd";
      };
    };

  };

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "claude-code"
    ];

  home.stateVersion = "25.05";

  home.packages = [
    pkgs.atuin
    pkgs.bat
    pkgs.clang
    pkgs.claude-code
    pkgs.eza
    pkgs.fd
    pkgs.fish
    pkgs.fzf
    pkgs.gemini-cli
    pkgs.gh
    pkgs.git
    pkgs.goose-cli
    pkgs.kitty-themes
    pkgs.mise
    pkgs.nerd-fonts.hack
    pkgs.nixfmt-rfc-style
    pkgs.nurl
    pkgs.ripgrep
    pkgs.rustup
    pkgs.spotifyd
    pkgs.starship
    pkgs.stow
    pkgs.uv
  ];

  home.file = {
    ".config/emacs".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nonwork/emacsen";
    ".config/git".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nonwork/dotfiles/config/git/.config/git";
    # ".config/kitty".source =
    #   config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nonwork/dotfiles/config/kitty/.config/kitty";
  };

  home.sessionVariables = {
    # EDITOR = "emacs";
    # SHELL = "${pkgs.fish}/bin/fish";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
