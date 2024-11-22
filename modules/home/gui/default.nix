# Set up and theme GUI toolkit elements
# https://www.youtube.com/watch?v=m_6eqpKrtxk
{ config, lib, pkgs, ... }:
let
  cfg = config.zen.gui;
  inherit (lib) mkIf mkEnableOption;
  fileFilter = n: v: lib.strings.hasSuffix ".nix" n &&
                     n != "default.nix" &&
                     v == "regular";
  fileList = builtins.readDir ./.;
  validFiles = lib.attrsets.filterAttrs fileFilter fileList;
  importFiles = lib.attrsets.mapAttrsToList (n: v: ./${n}) validFiles;
in
{
  imports = importFiles;

  options.zen.gui.enable = mkEnableOption "zen home: gui";

  # Turn on GTK
  config = mkIf cfg.enable {
    gtk = {
      enable = true;
    };
    #
    # # Turn on QT
    qt = {
      enable = true;
    };

    # Configure XDG portal
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        lxqt.xdg-desktop-portal-lxqt
      ];
      config = {
        common = {
          default = [
            "gtk"
            "lxqt"
          ];
        };
      };
    };

    home.packages = with pkgs; [
      # Screen locker
      xsecurelock
    ];
  };

  # services.network-manager-applet.enable = true;
}
