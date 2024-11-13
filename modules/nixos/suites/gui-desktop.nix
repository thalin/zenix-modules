{ lib, config, ... }:
let
  inherit (lib) mkIf;
  suite_name = "gui-desktop";
  mkIfsuite = mkIf (builtins.elem suite_name config.zen.suites);
in
{
  config = mkIfsuite {
    zen = lib.mkDefault {
      system.sound.enable = true;

      gui = {
        enable = true;
        xserver = true;
        qtile.enable = true;
      };
    };
  };
}
