# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ lib, config, ... }:
let
  cfg = config.zen.gui.hidpi;
  inherit (lib) mkEnableOption mkOption mkIf mkDefault types;
in {

  options.zen.gui.hidpi = {
    enable = mkEnableOption "zen config: enable hidpi stuff";
    dpi = mkOption {
      # 92 is normal? Higher density displays do exist though
      type = types.int;
      default = 92;
    };
    scale_up = mkOption {
      # should be >= 1.0 usually
      type = types.float;
      default = 1.0;
    };
    scale_down = mkOption {
      # should be <= 1.0 usually
      type = types.float;
      default = 1.0;
    };
  };

  config = mkIf cfg.enable (
    let
      scale_up = builtins.toString cfg.scale_up;
      scale_down = builtins.toString cfg.scale_down;
    in {
      environment.variables = {
        GDK_SCALE = scale_up;
        GDK_DPI_SCALE = scale_down;
        _JAVA_OPTIONS = "-Dsun.java2d.uiScale=${scale_down}";
      };

      services.displayManager.sddm.enableHidpi = mkDefault true;

      services.xserver.dpi = mkDefault cfg.dpi;

      services.xserver.upscaleDefaultCursor = mkDefault true;
    }
  );
}
