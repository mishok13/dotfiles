{
  config,
  pkgs,
  lib,
  nixgl,
  system,
  ...
}:

{
  imports = [
    ./fonts.nix
  ];

  config = {

    home.packages = [
      pkgs.emacs
    ];

    home.file = {
      ".config/emacs".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nonwork/emacsen";
    };
  };

}
