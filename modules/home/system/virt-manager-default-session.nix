{ osConfig, lib, ... }:
let
  inherit (lib) mkIf;
in
{
  config = mkIf osConfig.zen.system.kvm-host.enable {
    dconf.settings = {
      "org/virt-manager/virt-manager/connections" = {
        autoconnect = ["qemu:///system"];
        uris = ["qemu:///system"];
      };
    };
  };
}
