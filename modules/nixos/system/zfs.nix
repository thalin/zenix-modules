# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, lib, config, ... }:
let
  cfg = config.zen.system.zfs;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.zen.system.zfs.enable = mkEnableOption "zen config: enable zfs";

  config = mkIf cfg.enable {
    # Minimum needed to get ZFS going
    boot = {
      supportedFilesystems = [ "zfs" ];
      zfs.forceImportRoot = false;
      # Also make sure we're using a kernel supported by ZFS module. Otherwise we won't get very far.
      # kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
    };

    # Install ZFS command line utils
    environment.systemPackages = with pkgs; [
      zfs
    ];
    # Also make sure networking.hostId is set somewhere in your config...
    # In my case I like to set it in the networking.nix file in my host config
  };
}
