{ lib, config, ... }:
let
  inherit (lib) mkIf;
  suite_name = "gui-games";
  mkIfsuite = mkIf (builtins.elem suite_name config.zen.suites);
in
{
  config = mkIfsuite {
    zen = lib.mkDefault {
      games.steam = {
        enable = true;
        xdg_portal = true;
      };
    };
  };
}
