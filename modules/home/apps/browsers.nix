{ config, lib, pkgs, ... }:
let
  cfg = config.zen.apps.browsers;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.zen.apps.browsers.enable = mkEnableOption "zen home: browsers";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      librewolf
      brave
      google-chrome
    ];
  };
}
