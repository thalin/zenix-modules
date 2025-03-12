{ config, lib, pkgs, ... }:
let
  cfg = config.zen.apps.audio;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.zen.apps.audio.enable = mkEnableOption "zen home: audio apps";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      pavucontrol
      spotifyd
      spotify
    ];
    services.mpd = {
      enable = true;
      musicDirectory = "~/Music";
    };
  };
}
