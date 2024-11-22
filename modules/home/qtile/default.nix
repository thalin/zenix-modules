{ config, osConfig, lib, pkgs, ... }:
let
  cfg = config.zen.gui.qtile;
  inherit (lib) mkOption mkIf types;
in
{
  options.zen.gui.qtile.enable = mkOption {
    type = types.bool;
    # default = osConfig.zen.gui.qtile.enable;
    default = true;
    description = "zen gui home: enable qtile";
    example = true;
  };

  config = mkIf cfg.enable {
    # TODO: all these files should just be a package so I can configure them more nixishly
    home.file = {
      # Stub to import all the junk my module defines
      ".config/qtile/config.py".source = ./config.py;
      # The module itself
      ".config/qtile/config/__init__.py".source = ./config/__init__.py;
      ".config/qtile/config/groups.py".source = ./config/groups.py;
      ".config/qtile/config/layouts.py".source = ./config/layouts.py;
      ".config/qtile/config/vars.py".source = ./config/vars.py;
      ".config/qtile/config/floating.py".source = ./config/floating.py;
      ".config/qtile/config/hooks.py".source = ./config/hooks.py;
      ".config/qtile/config/keys.py".source = ./config/keys.py;
      ".config/qtile/config/logging.py".source = ./config/logging.py;
      ".config/qtile/config/screens.py".source = ./config/screens.py;
      ".config/qtile/config/widgets.py".source = ./config/widgets.py;
      ".config/qtile/config/themes/__init__.py".source = ./config/themes/__init__.py;
      ".config/qtile/config/themes/gruvbox.py".source = ./config/themes/gruvbox.py;
      # Autostart script
      ".config/qtile/autostart.sh".source = ./autostart.sh;
      ".config/qtile/autostart-wayland.sh".source = ./autostart-wayland.sh;
    }; # home.file

    home.packages = with pkgs; [
      networkmanagerapplet # nm-applet
      nitrogen
      picom-next
      kitty
      dconf
      xorg.xf86inputsynaptics # syndaemon/synclient
      xorg.xkill
      xorg.xev
      #upower # for upower dbus stuff
    ];

    programs.kitty = {
      enable = true;
    };
  };
}
