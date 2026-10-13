{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.zen.ai.codex;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.zen.ai.codex.enable = mkEnableOption "zen home: enable OpenAI codex CLI";

  config = mkIf cfg.enable {
    home.packages = [ pkgs.codex ];
  };
}
