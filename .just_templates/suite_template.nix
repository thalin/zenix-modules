{ lib, config, ... }:
let
  inherit (lib) mkIf;
  suite_name = "suite_NAME";
  mkIfsuite = mkIf (builtins.elem suite_name config.zen.suites);
in
{
  config = mkIfsuite {
    zen = lib.mkDefault {
    };
  };
}
