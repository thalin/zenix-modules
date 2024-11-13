{ lib, config, ... }:
let
  inherit (lib) mkIf;
  role_name = "workstation";
  mkIfRole = mkIf (builtins.elem role_name config.zen.roles);
in
{
  config = mkIfRole {
    zen = lib.mkDefault {
      suites = [
        "gui-desktop"
        "nix-devel"
        "real-system"
      ];

      network.openssh.enable = true;
    };
  };
}
