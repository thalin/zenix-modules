{ config, lib, pkgs, ... }:
let
  cfg = config.zen.apps.multimedia;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.zen.apps.multimedia.enable = mkEnableOption "zen home: multimedia";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      vlc
      smplayer
      mpv
    ];
  };
}
