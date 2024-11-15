# Enable hardware stuff like sensors and bluetooth
{ lib, config, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.zen.roles.real-system;
in
{
  options.zen.roles.real-system.enable = mkEnableOption "zen role: real-system";
  config = mkIf cfg.enable {
    zen = lib.mkDefault {
      hardware.bluetooth.enable = true;
      hardware.sensors.enable = true;
    };
  };
}
