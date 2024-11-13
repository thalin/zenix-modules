{ lib, config, ... }:
let
  inherit (lib) mkIf;
  role_name = "laptop";
  mkIfRole = mkIf (builtins.elem role_name config.zen.roles);
in
{
  config = mkIfRole {
    zen = lib.mkDefault {
      games.steam = {
        enable = true;
        xdg_portal = true;
      };
    };
  };
}
