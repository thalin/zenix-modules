{ lib, config, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.zen.roles.gui-games;
in
{
  options.zen.roles.gui-games.enable = mkEnableOption "zen role: gui-games";
  config = mkIf cfg.enable {
    zen = lib.mkDefault {
      games.steam = {
        enable = true;
        xdg_portal = true;
      };
    };
  };
}
