{ config, lib, pkgs, ... }:
let
  cfg = config.zen.apps.obsidian;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.zen.apps.obsidian.enable = mkEnableOption "zen home: apps - obsidian notes";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      obsidian
    ];
  };
}
