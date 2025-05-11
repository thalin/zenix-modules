{ 
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.zen.system.appimage;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.zen.system.appimage.enable = mkEnableOption "zen config: enable appimage support";

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      appimage-run
    ];
  };
}
