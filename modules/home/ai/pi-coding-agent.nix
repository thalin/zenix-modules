{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.zen.ai.pi-coding-agent;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.zen.ai.pi-coding-agent.enable = mkEnableOption "zen home: enable pi-coding-agent";

  config = mkIf cfg.enable {
    home.packages = [ pkgs.pi-coding-agent ];
  };
}
