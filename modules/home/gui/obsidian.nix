{ config, lib, pkgs, ... }:
let
  cfg = config.zen.gui.obsidian;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.zen.gui.obsidian.enable = mkEnableOption "zen home: gui - obsidian notes";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      obsidian
    ];
  };
}
