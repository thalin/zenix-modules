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
  cfg = config.zen.system.docker;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.zen.system.docker.enable = mkEnableOption "zen config: enable docker support";

  config = mkIf cfg.enable {
    virtualisation = {
      containers.enable = true;
      docker = {
        enable = true;
      };
    };
    environment.systemPackages = with pkgs; [
      dive
      docker-compose
    ];
  };
}
