{ lib, config, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.zen.roles.gui-desktop;
in
{
  options.zen.roles.gui-desktop.enable = mkEnableOption "zen role: gui-desktop";
  config = mkIf cfg.enable {
    zen = lib.mkDefault {
      system.sound.enable = true;

      gui = {
        enable = true;
        xserver = true;
        qtile.enable = true;
      };
    };
  };
}
