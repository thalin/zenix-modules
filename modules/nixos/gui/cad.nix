# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.zen.gui.cad;
in {

  options.zen.gui.cad = {
    enable = mkEnableOption "zen config: 3dmodeling/cad/3dprinter stuff";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # Bambu studio is broken right now. See:
      # https://github.com/NixOS/nixpkgs/issues/391622
      # bambu-studio
      orca-slicer
      freecad
      openscad
    ];
  };
}
