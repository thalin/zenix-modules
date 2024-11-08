# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:
let
  cfg = config.zen.hardware.sensors;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.zen.hardware.sensors.enable = mkEnableOption "zen config: enable hardware sensors";

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      lm_sensors
    ];
  };
}
