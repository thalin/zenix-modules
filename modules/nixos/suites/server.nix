{ lib, config, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.zen.suites.server;
in
{
  options.zen.suites.server.enable = mkEnableOption "zen suite: server";
  config = mkIf cfg.enable {
    zen = lib.mkDefault {
      games.steam = {
        enable = true;
        xdg_portal = true;
      };
    };
  };
}
