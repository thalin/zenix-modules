{ config, lib, pkgs, ... }:
let
  cfg = config.zen.multimedia;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.zen.multimedia.enable = mkEnableOption "zen home: multimedia";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      vlc
      smplayer
      mpv
    ];
  };
}
