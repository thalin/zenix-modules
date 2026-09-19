{ config, lib, pkgs, ... }:
let
  cfg = config.zen.apps.wow;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.zen.apps.wow.enable = mkEnableOption "zen home: WoW launcher (faugus-launcher) and addon manager (instawow)";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      faugus-launcher
      instawow
      mangohud
      gamemode
    ];
  };
}
