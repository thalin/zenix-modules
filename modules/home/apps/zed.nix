{ config, lib, pkgs, ... }:
let
  cfg = config.zen.apps.zed;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.zen.apps.zed.enable = mkEnableOption "zen home: apps - zed editor";

  config = mkIf cfg.enable {
    programs.zed-editor = {
      enable = true;
      extensions = [
        "nix"
        "toml"
      ];
      userSettings = {
        features = {
          copilot = false;
        };
        telemetry = {
          diagnostics = false;
          metrics = false;
        };
        buffer_font_family = lib.mkForce "FiraCode Nerd Font";
        buffer_font_size = lib.mkForce 14;
      };
    };
  };
}

