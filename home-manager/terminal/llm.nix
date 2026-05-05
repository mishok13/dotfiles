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
        pkgsLLM.copilot-cli
        pkgsLLM.opencode
        pkgs.copilot-language-server
      ]
    else
      [
        pkgsLLM.amp
        pkgsLLM.claude-code
        pkgsLLM.claude-agent-acp
        pkgsLLM.codex
        pkgsLLM.gemini-cli
        pkgsLLM.goose-cli
      ];

}
