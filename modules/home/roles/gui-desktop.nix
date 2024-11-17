{ lib, osConfig, config, ... }:
let
  inherit (lib) mkIf;
  mkOsEnableOption = osOption: description: lib.mkOption {
    type = lib.types.bool;
    default = osOption;
    description = description;
    example = true;
  };

  cfg = config.zen.roles.gui-desktop;
in
{
  options.zen.roles.gui-desktop.enable = mkOsEnableOption osConfig.zen.roles.gui-desktop "zen role: gui-desktop";

  config = mkIf cfg.enable {
    zen = lib.mkDefault {
      apps = {
        guiutil = true;
        browsers = true;
        guicomms = true;
        multimedia = true;
        audio = true;
      };
    };
  };
}
