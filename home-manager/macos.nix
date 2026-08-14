{
  config,
  pkgs,
  lib,
  system,
  pkgsLLM,
  commitSignProgram,
  sshCommand,
  ...
}:

let
  # `emacsWithPackages` builds an Emacs.app whose wrapper sets EMACSLOADPATH and
  # then exec's the *inner* emacs-30.2 bundle. Both share CFBundleIdentifier
  # "org.gnu.Emacs", so macOS LaunchServices latches onto the inner (unwrapped)
  # bundle and launches it directly for Dock/Spotlight/Finder, bypassing the
  # wrapper -> jinx/hotfuzz/etc. are missing from the load path.
  #
  # Export the package load paths into the GUI (launchd) session so *any* Emacs
  # bundle finds them, regardless of which one LaunchServices decides to run.
  emacsDeps = config.programs.emacs.finalPackage.deps;
in
{
  imports = [
    ./common.nix
    ./editors.nix
    ./terminal.nix
    ./kitty.nix
    ./ghostty.nix
    ./terminal/llm.nix
  ];

  launchd.agents.emacs-loadpath = {
    enable = true;
    config = {
      ProgramArguments = [
        "/bin/sh"
        "-c"
        "launchctl setenv EMACSLOADPATH '${emacsDeps}/share/emacs/site-lisp:'; launchctl setenv EMACSNATIVELOADPATH '${emacsDeps}/share/emacs/native-lisp:'"
      ];
      RunAtLoad = true;
    };
  };
}
