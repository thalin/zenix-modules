{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.zen.apps.guicomms;
in
{
  options.zen.apps.guicomms.enable = mkEnableOption "zen home: guicomms apps";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      slack
      discord
      signal-desktop
    ];

    # Only written out where xdg.mimeApps is enabled (zen.gui.librewolf-scaled.defaultBrowser).
    xdg.mimeApps.defaultApplications = {
      "x-scheme-handler/sgnl" = "signal.desktop";
      "x-scheme-handler/signalcaptcha" = "signal.desktop";
      "x-scheme-handler/slack" = "slack.desktop";
    };
  };
}
