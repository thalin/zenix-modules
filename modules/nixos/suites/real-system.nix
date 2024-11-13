# Enable hardware stuff like sensors and bluetooth
{ lib, config, ... }:
let
  inherit (lib) mkIf;
  suite_name = "real-system";
  mkIfsuite = mkIf (builtins.elem suite_name config.zen.suites);
in
{
  config = mkIfsuite {
    zen = lib.mkDefault {
      hardware.bluetooth.enable = true;
      hardware.sensors.enable = true;
    };
  };
}
