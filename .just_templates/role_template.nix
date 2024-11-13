{ lib, config, ... }:
let
  inherit (lib) mkIf;
  role_name = "ROLE_NAME";
  mkIfRole = mkIf (builtins.elem role_name config.zen.roles);
in
{
  config = mkIfRole {
    zen = lib.mkDefault {
    };
  };
}
