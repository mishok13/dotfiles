{
  config,
  pkgs,
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
    ripgrep = {
      enable = true;
      arguments = [
        "--type-add=pypkg:{pyproject.toml,setup.py,setup.cfg,requirements.txt}"
        "--type-add=jenkins:{*.jenkinsfile,Jenkinsfile}"
        "--hidden"
        "--smart-case"
      ];
    };

    fd = {
      enable = true;
      hidden = true;
      ignores = ignoredPaths;
    };
  };

  home.packages = [
    pkgs.bat
    pkgs.cabal-install
    pkgs.clang
    pkgs.eza
    pkgs.fish
    pkgs.fzf
    pkgs.glab
    pkgs.harper
    pkgs.hyperfine
    pkgs.ispell
    pkgs.just
    pkgs.mise
    pkgs.nixfmt
    pkgs.nixos-rebuild
    pkgs.nurl
    pkgs.nushell
    pkgs.pre-commit
    pkgs.ripgrep
    pkgs.nodejs
    pkgs.rust-analyzer
    pkgs.rustup
    pkgs.starship
    pkgs.stow
    pkgs.tofu-ls
    pkgs.trufflehog
    pkgs.typst
    pkgs.typstyle
    pkgs.uiua
    pkgs.uv
    pkgs.watchexec
    pkgs.zola
  ];

  home.file = {
    ".rgignore".text = builtins.concatStringsSep "\n" ignoredPaths;
  };
}
