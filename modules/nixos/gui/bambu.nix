# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.zen.gui.bambu;
in {

  options.zen.gui.bambu = {
    enable = mkEnableOption "zen config: enable modeling stuff for bambu-labs printer";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      bambu-studio
      orca-slicer
      freecad
      openscad
    ];
  };
}
