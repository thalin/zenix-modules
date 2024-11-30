{ lib, config, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.zen.roles.cad;
in
{
  options.zen.roles.cad.enable = mkEnableOption "zen role: cad";

  config = mkIf cfg.enable {
    zen = lib.mkDefault {
      gui.cad.enable = true;
    };
  };
}
