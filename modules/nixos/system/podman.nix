# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.zen.system.podman;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.zen.system.podman.enable = mkEnableOption "zen config: enable podman support";

  config = mkIf cfg.enable {
    virtualization = {
      containers.enable = true;
      podman = {
        enable = true;
        dockerCompat = true;
        defaultNetwork.settings.dns_enabled = true;
      };
    };
    environment.systemPackages = with pkgs; [
      dive
      podman-tui
      podman-compose
    ];
  };
}
