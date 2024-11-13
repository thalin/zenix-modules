# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:
let
  cfg = config.zen.hardware.bluetooth;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.zen.hardware.bluetooth.enable = mkEnableOption "zen config: enable bluetooth";

  config = mkIf cfg.enable {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };

    services.blueman.enable = true;
  };
}
