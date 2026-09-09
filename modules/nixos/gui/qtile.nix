{
  config, lib, ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  inherit (lib.snowzen) mkIfElse;

  guicfg = config.zen.gui;
  cfg = guicfg.qtile;

  qtile_pkg = config.services.xserver.windowManager.qtile.finalPackage;
  qtile_xsession = {
    manage = "desktop";
    name = "qtile";
    start = ''
    $HOME/.config/qtile/autostart.sh >> $HOME/.config/qtile/qtile.log
    ${qtile_pkg}/bin/qtile start -c $HOME/.config/qtile/config.py &
    waitPID=$!
    '';
  };
  qtile_wayland = {
    manage = "desktop";
    name = "qtile-wayland";
    start = ''
    $HOME/.config/qtile/autostart-wayland.sh >> $HOME/.config/qtile/qtile.log
    ${qtile_pkg}/bin/qtile start -c $HOME/.config/qtile/config.py -b wayland &
    waitPID=$!
    '';
  };
in
{
  options.zen.gui.qtile = {
    enable = mkEnableOption "zen config: enable Qtile window manager";
  };

  config = mkIf cfg.enable {
    # Enable the X11 windowing system.
    services.xserver = {
      windowManager.qtile = {
        enable = true;
        extraPackages = py3Pkg: with py3Pkg; [
          qtile-extras
          screeninfo
        ];
      };
      displayManager = mkIfElse (guicfg.wayland) {
        session = [ qtile_wayland ];
        sessionCommands = ''
          $HOME/.config/qtile/autostart-wayland.sh >> $HOME/qtile-config.log
        '';
      } {
        session = [ qtile_xsession ];
        sessionCommands = ''
          $HOME/.config/qtile/autostart.sh >> $HOME/qtile-config.log
        '';
      };
    };
  };
} 
