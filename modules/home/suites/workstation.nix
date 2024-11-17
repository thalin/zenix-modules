{ lib, config, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.zen.suites.workstation;
in
{
  options.zen.suites.workstation.enable = mkEnableOption "zen suite: workstation";

  config = mkIf cfg.enable {
    zen = lib.mkDefault {
      roles = {
        gui-desktop.enable = true;
        cli.enable = true;
      };
    };
  };
}
