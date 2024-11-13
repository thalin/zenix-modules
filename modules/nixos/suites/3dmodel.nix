{ lib, config, ... }:
let
  inherit (lib) mkIf;
  suite_name = "3dmodel";
  mkIfsuite = mkIf (builtins.elem suite_name config.zen.suites);
in
{
  config = mkIfsuite {
    zen = lib.mkDefault {
      gui.bambu.enable = true;
    };
  };
}
