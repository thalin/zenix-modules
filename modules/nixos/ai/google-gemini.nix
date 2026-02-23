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
  options.zen.ai.gemini-ai.enable = mkEnableOption "zen config: enable gemini-ai tools";
  
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ gemini-cli antigravity ];
  };
}

