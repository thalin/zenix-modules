{ lib, config, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.zen.suites.SUITE_NAME;
in
{
  options.zen.suites.SUITE_NAME.enable = mkEnableOption "zen suite: SUITE_NAME";

  config = mkIf cfg.enable {
    zen = lib.mkDefault {
    };
  };
}
