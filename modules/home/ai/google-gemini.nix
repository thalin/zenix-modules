{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.zen.ai.gemini-ai;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.zen.ai.gemini-ai.enable = mkEnableOption "zen home: enable gemini-ai tools";
  
  config = mkIf cfg.enable {
    home.packages = with pkgs; [ gemini-cli antigravity antigravity-cli ];
  };
}
