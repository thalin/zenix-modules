# Taken from youtube video titled "Battery life improvements on NixOS"
# from the channel "Tech Support On Hold"

{ config, pkgs, ... }:
{
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
}
