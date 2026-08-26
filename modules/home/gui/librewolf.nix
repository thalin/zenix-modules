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

  inherit (lib) mkEnableOption mkOption mkIf types;
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
  };

  config = mkIf cfg.enable {
    home.packages = [ librewolf-scaled-wrapper ];
  };
}
