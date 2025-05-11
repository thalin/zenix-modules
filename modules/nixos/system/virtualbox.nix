{
  config,
  pkgs,
  inputs,
  lib,
  namespace,
  ...
}:
let
  cfg = config.zen.system.virtualbox;
  inherit (lib) mkEnableOption mkIf;
in
{
  # options.${cfg_path}.enable = mkEnableOption "zen config: enable virtualbox support";
  options.zen.system.virtualbox.enable = mkEnableOption "zen config: enable kvm-host support";

  config = mkIf cfg.enable {
    virtualisation.virtualbox.host = {
      enable = true;
    };
  };
}
