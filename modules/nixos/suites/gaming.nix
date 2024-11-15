{ lib, config, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.zen.suites.gaming;
in
{
  options.zen.suites.gaming.enable = mkEnableOption "zen suite: gaming";

  config = mkIf cfg.enable {
    zen = lib.mkDefault {
      games.steam = {
        enable = true;
        xdg_portal = true;
      };
    };
  };
}
