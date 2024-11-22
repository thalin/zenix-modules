{ config, lib, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.zen.system.kvm-host;
in
{
  options.zen.system.kvm-host.enable = mkEnableOption "zen home: virt manager configure default session";
  config = mkIf cfg.enable {
    dconf.settings = {
      "org/virt-manager/virt-manager/connections" = {
        autoconnect = ["qemu:///system"];
        uris = ["qemu:///system"];
      };
    };
  };
}
