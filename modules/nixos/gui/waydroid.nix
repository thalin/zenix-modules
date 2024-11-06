{ lib, config, ... }:
let
  cfg = config.zen.waydroid;
  inherit (lib) mkEnableOption mkIf;
in {

  options.zen.waydroid = {
    enable = mkEnableOption "zen config: Enable Waydroid to run Android apps.";
  };

  config = mkIf cfg.enable {
    virtualisation.waydroid.enable = true;
  };
}
