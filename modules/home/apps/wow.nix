{ config, lib, pkgs, ... }:
let
  cfg = config.zen.apps.wow;
  inherit (lib) mkEnableOption mkIf;
  # nixpkgs' instawow lags behind what's needed; build main instead.
  # See packages/instawow-main for why this can't just be a version bump.
  instawow-main = import ../../../packages/instawow-main { inherit pkgs; };
in
{
  options.zen.apps.wow.enable = mkEnableOption "zen home: WoW launcher (faugus-launcher) and addon manager (instawow)";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      faugus-launcher
      instawow-main
      mangohud
      gamemode
    ];
  };
}
