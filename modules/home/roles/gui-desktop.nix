{ lib, osConfig, config, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  mkOsEnableOption = {osOption, description}: lib.mkOption {
    type = lib.types.bool;
    default = osOption;
    description = description;
    example = true;
  };
  cfg = config.zen.roles.gui-desktop;
in
{
  options.zen.roles.gui-desktop.enable = mkEnableOption "zen role: gui desktop";
  # options.zen.roles.gui-desktop.enable = mkOsEnableOption {
  #   osOption = osConfig.zen.roles.gui-desktop.enable;
  #   description = "zen role: gui-desktops";
  # };

  config = mkIf cfg.enable {
    zen = lib.mkDefault {
      apps = {
        # guiutil = true;
        # browsers = true;
        # guicomms = true;
        # multimedia = true;
        # audio = true;
      };
    };
  };
}
