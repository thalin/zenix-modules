{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.zen.ai.gemini-cli;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.zen.ai.gemini-cli.enable = mkEnableOption "zen config: enable gemini-cli";
  
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ gemini-cli ];
  };
}

