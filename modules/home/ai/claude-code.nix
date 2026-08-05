{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.zen.ai.claude-code;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.zen.ai.claude-code.enable = mkEnableOption "zen home: enable claude-code tools";
  
  config = mkIf cfg.enable {
    home.packages = with pkgs; [ claude-code jq ];
  };
}
