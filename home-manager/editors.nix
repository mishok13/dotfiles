{
  config,
  pkgs,
  ...
}:

{
  imports = [
    ./fonts.nix
  ];

  config = {
    home.packages = [
      pkgs.aspell
      pkgs.aspellDicts.en
    ];

    programs.emacs = {
      enable = true;
      package = pkgs.emacs;
      extraPackages = epkgs: [
        epkgs.jinx
        epkgs.hotfuzz
        (epkgs.treesit-grammars.with-grammars (g: [
          g.tree-sitter-python
          g.tree-sitter-rust
          g.tree-sitter-typescript
          g.tree-sitter-hcl
          g.tree-sitter-dockerfile
          g.tree-sitter-nix
          g.tree-sitter-go
          g.tree-sitter-lua
        ]))
      ];
    };

    home.file = {
      ".config/emacs".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nonwork/emacsen";
    };

    programs.vim = {
      enable = true;
      plugins = [ pkgs.vimPlugins.catppuccin-vim ];
      extraConfig = ''
        colorscheme catppuccin_mocha
      '';
    };

    programs.helix = {
      enable = true;
      settings = {
        theme = "catppuccin_mocha";
      };
    };
  };
}
