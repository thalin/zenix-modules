{ lib, config, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.zen.roles.modeling;
in
{
  options.zen.roles.modeling.enable = mkEnableOption "zen role: modeling";
  config = mkIf cfg.enable {
    zen = lib.mkDefault {
      gui.bambu.enable = true;
    };
  };
}
