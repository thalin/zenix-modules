{ config, lib, ... }:
let
  cfg = config.zen.gui.picom;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.zen.gui.picom.enable = mkEnableOption "zen gui: enable picom";

  config = mkIf cfg.enable {
    services.picom = {
      enable = true;
      backend = "glx";
      settings = {
      };
    };
  };
}
