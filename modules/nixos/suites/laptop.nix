{ lib, config, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.zen.suites.laptop;
in
{
  options.zen.suites.laptop.enable = mkEnableOption "zen suites: laptop";

  config = mkIf cfg.enable {
    zen = lib.mkDefault {
      games.steam = {
        enable = true;
        xdg_portal = true;
      };
    };
  };
}
