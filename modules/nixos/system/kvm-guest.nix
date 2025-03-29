# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, ... }:
let
  cfg = config.zen.system.kvm-guest;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.zen.system.kvm-guest.enable = mkEnableOption "zen config: enable kvm guest config";

  config = mkIf cfg.enable {
    # Enable QEMU Guest Agent
    # Options reference: https://search.nixos.org/options?channel=24.05&show=services.qemuGuest.enable&from=0&size=50&sort=relevance&type=packages&query=qemuGuest
    services.qemuGuest.enable = true;
    # Enable automatic display reside to match SPICE client window size
    # https://search.nixos.org/options?channel=24.05&show=services.spice-autorandr.enable&from=0&size=50&sort=relevance&type=packages&query=spice-autorandr
    services.spice-autorandr.enable = true;
    # https://search.nixos.org/options?channel=24.05&show=services.spice-vdagentd.enable&from=0&size=50&sort=relevance&type=packages&query=spice-vdagentd
    services.spice-vdagentd.enable = true;
  };
}
