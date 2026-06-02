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
        pkgsLLM.claude-agent-acp
        pkgsLLM.claude-code
        pkgsLLM.codex
        pkgsLLM.codex-acp
        pkgsLLM.gemini-cli
        pkgsLLM.opencode
        pkgsLLM.pi
      ];

}
