{ config, lib, pkgs, ... }:
let
  cfg = config.zen.apps.bitwarden;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.zen.apps.bitwarden.enable = mkEnableOption "zen home: bitwarden apps";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      bitwarden-desktop
      bitwarden-cli
    ];
  };
}
