{ config, lib, pkgs, ... }:
let
  cfg = config.zen.apps.bitwarden;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.zen.apps.bitwarden.enable = mkEnableOption "zen home: bitwarden apps";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      #5-30-2026 - currently using insecure electron version.
      # Also I don't really use this. Maybe I should just nuke it.
      #bitwarden-desktop
      bitwarden-cli
    ];
  };
}
