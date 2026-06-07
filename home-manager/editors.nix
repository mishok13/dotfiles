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
      pkgs.emacs
      pkgs.emacsPackages.jinx
      pkgs.aspell
      pkgs.aspellDicts.en
    ];

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
