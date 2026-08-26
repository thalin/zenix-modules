{ config, lib, pkgs, ... }:
let
  cfg = config.zen.apps.browsers;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.zen.apps.browsers.enable = mkEnableOption "zen home: browsers";

  config = mkIf cfg.enable {
    home.packages =
      with pkgs;
      # zen.gui.librewolf-scaled provides its own wrapped "librewolf"
      # binary; installing both would collide on bin/librewolf.
      lib.optional (!config.zen.gui.librewolf-scaled.enable) librewolf
      ++ [
        # google-chrome
      ];
  };
}
