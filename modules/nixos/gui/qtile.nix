{
  config, lib, ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  inherit (lib.snowzen) mkIfElse;

  guicfg = config.zen.gui;
  cfg = guicfg.qtile;
in
{
  options.zen.gui.qtile = {
    enable = mkEnableOption "zen config: enable Qtile window manager";
  };

  # services.xserver.windowManager.qtile unconditionally ships both an
  # x11 session ("qtile") and a wayland session ("qtile-wayland") via
  # sessionPackages (the qtile derivation bundles both .desktop files), so
  # there's no per-backend session to toggle here - just which one SDDM
  # preselects.
  config = mkIf cfg.enable {
    services.xserver = {
      windowManager.qtile = {
        enable = true;
        extraPackages = py3Pkg: with py3Pkg; [
          qtile-extras
          screeninfo
        ];
      };

      # Only sourced for X11 sessions - wayland has no equivalent hook here.
      displayManager.sessionCommands = ''
        $HOME/.config/qtile/autostart.sh >> $HOME/qtile-config.log
      '';
    };

    services.displayManager.defaultSession = mkIfElse guicfg.wayland "qtile-wayland" "qtile";
  };
}
