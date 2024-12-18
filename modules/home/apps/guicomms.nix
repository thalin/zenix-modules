{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.zen.apps.guicomms;
in
{
  options.zen.apps.guicomms.enable = mkEnableOption "zen home: guicomms apps";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      slack
      discord
      signal-desktop
    ];
  };
}
