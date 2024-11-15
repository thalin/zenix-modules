{ lib, config, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.zen.roles.kvm-host;
in
{
  options.zen.roles.kvm-host.enable = mkEnableOption "zen role: kvm-host";
  config = mkIf cfg.enable {
    zen = lib.mkDefault {
      system.kvm-host.enable = true;
    };
  };
}
