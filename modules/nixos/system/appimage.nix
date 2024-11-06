# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ 
  config,
  pkgs,
  lib,
  namespace,
  ...
}:
let
  cfg = config.${namespace}.gui.appimage;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.${namespace}.gui.appimage.enable = mkEnableOption "${namespace} config: enable appimage support";

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      appimage-run
    ];
  };
}
