{ lib, config, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.zen.roles.ROLE_NAME;
in
{
  options.zen.roles.ROLE_NAME.enable = mkEnableOption "zen role: ROLE_NAME";

  config = mkIf cfg.enable {
    zen = lib.mkDefault {
    };
  };
}
