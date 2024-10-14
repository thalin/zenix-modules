{
  lib,
  pkgs,
  namespace,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf mkDefault;
  cfg = config.${namespace}.comms;
in
{
  options.${namespace}.comms.enable = mkEnableOption "zen home config: enable extra comms apps";

  config = mkIf cfg.enable {
    nixpkgs.config.allowUnfree = mkDefault true;
    home.packages = with pkgs; [
      slack
      discord
    ];
  };
}
