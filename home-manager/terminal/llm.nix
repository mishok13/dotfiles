{
  config,
  pkgs,
  pkgsLLM,
  ...
}:

let
  isMacOS = pkgs.stdenv.isDarwin;
in
{
  home.packages =
    if isMacOS then
      [
        pkgsLLM.copilot-cli
        pkgsLLM.opencode
      ]
    else
      [
        pkgsLLM.amp
        pkgsLLM.claude-code
        pkgsLLM.claude-code-acp
        pkgsLLM.codex
        pkgsLLM.gemini-cli
        pkgsLLM.goose-cli
      ];
}
