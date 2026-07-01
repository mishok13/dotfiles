{
  config,
  pkgs,
  lib,
  pkgsLLM,
  ...
}:

let
  isMacOS = pkgs.stdenv.isDarwin;
in
{
  # FIXME: Make this explicit per package instead of a global setting
  nixpkgs.config.allowUnfree = true;

  home.packages =
    if isMacOS then
      [
        pkgs.copilot-language-server
        pkgsLLM.copilot-cli
        pkgsLLM.opencode
        pkgsLLM.pi
      ]
    else
      [
        pkgsLLM.claude-agent-acp
        pkgsLLM.claude-code
        pkgsLLM.codex
        pkgsLLM.codex-acp
        pkgsLLM.gemini-cli
        pkgsLLM.opencode
        pkgsLLM.pi
      ];

  # Emacs-style keybindings for pi.
  # See: https://github.com/earendil-works/pi-coding-agent/blob/main/docs/keybindings.md
  home.file.".pi/agent/keybindings.json".text = builtins.toJSON {
    # Cursor movement
    "tui.editor.cursorUp" = [
      "up"
      "ctrl+p"
    ];
    "tui.editor.cursorDown" = [
      "down"
      "ctrl+n"
    ];
    "tui.editor.cursorLeft" = [
      "left"
      "ctrl+b"
    ];
    "tui.editor.cursorRight" = [
      "right"
      "ctrl+f"
    ];
    "tui.editor.cursorWordLeft" = [
      "alt+left"
      "ctrl+left"
      "alt+b"
    ];
    "tui.editor.cursorWordRight" = [
      "alt+right"
      "ctrl+right"
      "alt+f"
    ];
    "tui.editor.cursorLineStart" = [
      "home"
      "ctrl+a"
    ];
    "tui.editor.cursorLineEnd" = [
      "end"
      "ctrl+e"
    ];

    # Deletion
    "tui.editor.deleteCharBackward" = [
      "backspace"
      "ctrl+h"
    ];
    "tui.editor.deleteCharForward" = [
      "delete"
      "ctrl+d"
    ];
    "tui.editor.deleteWordBackward" = [
      "ctrl+w"
      "alt+backspace"
    ];
    "tui.editor.deleteWordForward" = [
      "alt+d"
      "alt+delete"
    ];
    "tui.editor.deleteToLineStart" = [ "ctrl+u" ];
    "tui.editor.deleteToLineEnd" = [ "ctrl+k" ];

    # Kill ring
    "tui.editor.yank" = [ "ctrl+y" ];
    "tui.editor.yankPop" = [ "alt+y" ];

    # Newline vs submit (emacs uses C-j for newline)
    "tui.input.newLine" = [
      "shift+enter"
      "ctrl+j"
    ];
    "tui.input.submit" = [ "enter" ];
  };

}
