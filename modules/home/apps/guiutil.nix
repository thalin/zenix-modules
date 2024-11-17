{ config, lib, pkgs, ... }:
let
  cfg = config.zen.apps.guiutil;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.zen.apps.guiutil.enable = mkEnableOption "zen home: gui utility apps";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      xorg.xdpyinfo
    ];
  };

}
