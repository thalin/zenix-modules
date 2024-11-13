{ lib, config, pkgs, ... }:
let
  inherit (lib) mkIf;
  suite_name = "nix-devel";
  mkIfsuite = mkIf (builtins.elem suite_name config.zen.suites);
in
{
  config = mkIfsuite {
    # zen = lib.mkDefault {
    # };
    environment.systemPackages = with pkgs; [
      nixos-generators
    ];
  };
}
