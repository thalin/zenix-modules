{ lib, config, ... }:
let
  inherit (lib) mkIf;
  suite_name = "kvm-host";
  mkIfsuite = mkIf (builtins.elem suite_name config.zen.suites);
in
{
  config = mkIfsuite {
    zen = lib.mkDefault {
      system.kvm-host.enable = true;
    };
  };
}
