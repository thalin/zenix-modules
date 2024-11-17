{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.zen.apps.comms;
in
{
  options.zen.apps.comms.enable = mkEnableOption "zen home config: enable extra comms apps";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      slack
      discord
    ];
  };
}
