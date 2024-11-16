# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  inputs,
  lib,
  namespace,
  ...
}:
let
  cfg = config.zen.system.kvm-host;
  inherit (lib) mkEnableOption mkIf;
in
{
  # options.${cfg_path}.enable = mkEnableOption "zen config: enable kvm-host support";
  options.zen.system.kvm-host.enable = mkEnableOption "zen config: enable kvm-host support";

  config = mkIf cfg.enable {
    virtualisation.libvirtd.enable = true;
    programs.virt-manager.enable = true;
    environment.systemPackages = with pkgs; [
      virt-viewer
      quickemu
    ];
  };
}
