{
  lib,
  pkgs,
  namespace,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.${namespace}.comms;
in
{
  options.${namespace}.comms.enable = mkEnableOption "zen home config: enable extra comms apps";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      slack
      discord
    ];
  };
}
