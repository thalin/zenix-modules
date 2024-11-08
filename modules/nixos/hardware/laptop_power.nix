# Taken from youtube video titled "Battery life improvements on NixOS"
# from the channel "Tech Support On Hold"

{ config, lib, ... }:
let
  cfg = config.zen.hardware.laptop_power;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.zen.hardware.laptop_power.enable = mkEnableOption "zen config: enable laptop power management";

  config = mkIf cfg.enable {
    services.system76-scheduler.settings.cfsProfiles.enable = true;

    services.tlp = {
      enable = true;
      settings = {
        CPU_BOOST_ON_AC = 1;
        CPU_BOOST_ON_BAT = 0;
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      };
    };

    services.power-profiles-daemon.enable = false;

    powerManagement.powertop.enable = true;

    services.thermald.enable = true;

    services.upower.enable = true;
  };
}
