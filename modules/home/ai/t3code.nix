{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.zen.ai.t3code;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.zen.ai.t3code.enable = mkEnableOption "zen home: enable T3 Code GUI for coding agents";

  config = mkIf cfg.enable {
    home.packages = [ pkgs.t3code ];
  };
}
