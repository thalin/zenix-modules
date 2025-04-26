# Make a wrapper for Brave that can be scaled.

{ config, pkgs, lib, ... }:

let
  cfg = config.zen.gui.brave-scaled;

  # Define the wrapper script package (same as Method 1)
  brave-scaled-wrapper = pkgs.writeShellScriptBin "brave" ''
    #!${pkgs.bash}/bin/bash
    real_brave_path="${pkgs.brave}/bin/brave"
    args=()
    args+=(--force-device-scale-factor="${toString cfg.scale}")
    exec "$real_brave_path" "''${args[@]}" "$@"
  '';

  inherit (lib) mkEnableOption mkOption mkIf types;
in
{
  options.zen.gui.brave-scaled = {
    enable = mkEnableOption "zen: Enable wrapper for Brave to use --force-device-scale-factor";
    scale = mkOption {
      type = types.float;
      default = 1.0;
    };
  };

  config = mkIf cfg.enable {
    # Add the wrapper package if the option is enabled
    home.packages = [ brave-scaled-wrapper ];
  };
}

