# Make a wrapper for Librewolf that forces content scaling, separately
# tuned per backend. Firefox/Librewolf has no CLI flag or env var for
# layout.css.devPixelsPerPx (unlike Chromium's --force-device-scale-factor),
# so the only way to apply it conditionally is to (re)write user.js at
# launch time based on whether a wayland session is active.

{ config, pkgs, lib, ... }:

let
  cfg = config.zen.gui.librewolf-scaled;

  librewolf-scaled-wrapper = pkgs.writeShellScriptBin "librewolf" ''
    #!${pkgs.bash}/bin/bash
    profile_dir="${cfg.profileDir}"
    user_js="$profile_dir/user.js"
    if [ -n "$WAYLAND_DISPLAY" ]; then
      mkdir -p "$profile_dir"
      echo 'user_pref("layout.css.devPixelsPerPx", "${toString cfg.scale}");' > "$user_js"
    else
      ${
        if cfg.x11Scale != null then ''
          mkdir -p "$profile_dir"
          echo 'user_pref("layout.css.devPixelsPerPx", "${toString cfg.x11Scale}");' > "$user_js"
        '' else ''
          [ -f "$user_js" ] && rm -f "$user_js"
        ''
      }
    fi
    exec "${pkgs.librewolf}/bin/librewolf" "$@"
  '';

  browserMimeTypes = [
    "text/html"
    "application/xhtml+xml"
    "x-scheme-handler/http"
    "x-scheme-handler/https"
  ];

  inherit (lib) mkEnableOption mkOption mkIf mkMerge types;
in
{
  options.zen.gui.librewolf-scaled = {
    enable = mkEnableOption "zen: wrapper for Librewolf that forces layout.css.devPixelsPerPx per-backend";
    scale = mkOption {
      type = types.float;
      default = 1.0;
      description = "devPixelsPerPx to force under wayland.";
    };
    x11Scale = mkOption {
      type = types.nullOr types.float;
      default = null;
      description = "devPixelsPerPx to force under X11. Leave null to fall back to Librewolf's own auto-detected dpi-based scaling instead.";
    };
    profileDir = mkOption {
      type = types.str;
      description = "Absolute path to the librewolf profile directory to manage user.js in.";
      example = "/home/foo/.librewolf/xxxxxxxx.default";
    };
    defaultBrowser = mkEnableOption "the wrapper as the default browser (xdg-open, $BROWSER). Turns on xdg.mimeApps, so home-manager takes over ~/.config/mimeapps.list";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      home.packages = [ librewolf-scaled-wrapper ];

      # Only the wrapper's bin/ is installed, not pkgs.librewolf itself, so
      # nothing else provides a desktop entry for xdg-open/menus to use.
      xdg.desktopEntries.librewolf = {
        name = "LibreWolf";
        genericName = "Web Browser";
        exec = "${librewolf-scaled-wrapper}/bin/librewolf %U";
        icon = "${pkgs.librewolf}/share/icons/hicolor/128x128/apps/librewolf.png";
        categories = [ "Network" "WebBrowser" ];
        mimeType = browserMimeTypes;
      };
    }
    (mkIf cfg.defaultBrowser {
      # Without a desktop environment, xdg-open falls back to a hardcoded
      # browser list that includes neither librewolf nor brave.
      home.sessionVariables.BROWSER = "librewolf";
      # Other modules declare their own handlers in xdg.mimeApps.defaultApplications.
      xdg.mimeApps = {
        enable = true;
        defaultApplications = lib.genAttrs browserMimeTypes (_: "librewolf.desktop");
      };
    })
  ]);
}
