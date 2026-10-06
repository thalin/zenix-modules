{ config, osConfig, lib, pkgs, ... }:
let
  cfg = config.zen.gui.qtile;
  inherit (lib) mkOption mkIf types;
in
{
  options.zen.gui.qtile = {
    enable = mkOption {
      type = types.bool;
      # default = osConfig.zen.gui.qtile.enable;
      default = false;
      description = "zen gui home: enable qtile";
      example = true;
    };
    settings = mkOption {
      type = types.attrsOf types.anything;
      default = {};
      description = "Qtile configuration overrides for the host";
    };
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
      ".config/qtile/config/host_vars.json".text = builtins.toJSON cfg.settings;
      ".config/qtile/config/floating.py".source = ./config/floating.py;
      ".config/qtile/config/hooks.py".source = ./config/hooks.py;
      ".config/qtile/config/keys.py".source = ./config/keys.py;
      ".config/qtile/config/logging.py".source = ./config/logging.py;
      ".config/qtile/config/screens.py".source = ./config/screens.py;
      ".config/qtile/config/widgets.py".source = ./config/widgets.py;
      ".config/qtile/config/timers.py".source = ./config/timers.py;
      ".config/qtile/config/themes/__init__.py".source = ./config/themes/__init__.py;
      ".config/qtile/config/themes/gruvbox.py".source = ./config/themes/gruvbox.py;
      # Autostart script
      ".config/qtile/autostart.sh".source = ./autostart.sh;
      ".config/qtile/autostart-wayland.sh".source = ./autostart-wayland.sh;
    }; # home.file

    home.packages = lib.optionals (pkgs.stdenv.isLinux) [ 
      pkgs.networkmanagerapplet
      pkgs.nitrogen
      pkgs.picom
      pkgs.kitty
      pkgs.xf86inputsynaptics # syndaemon/synclient
      pkgs.xkill
      pkgs.xev
      pkgs.flameshot
      pkgs.wlr-randr
    ] ++ lib.optionals (cfg.settings.notifications or false) [
      pkgs.libnotify # notify-send, for the bar's Notify widget to show
    ];

    programs.kitty = {
      enable = pkgs.stdenv.isLinux;
    };

    # Launcher for mod+p; rofi 2.x runs under both X11 and qtile-wayland
    programs.rofi = {
      enable = pkgs.stdenv.isLinux;
      modes = [ "drun" "run" ];
      terminal = "kitty";
      # A centred, bordered window instead of rofi's default 50%-of-monitor
      # width (which is a whole screen with fake_screens). Merges with the
      # stylix theme; em units scale with the font size.
      theme.window = {
        width = config.lib.formats.rasi.mkLiteral "50em";
        border = config.lib.formats.rasi.mkLiteral "2px";
        padding = config.lib.formats.rasi.mkLiteral "0.5em";
      };
    };
  };
}
