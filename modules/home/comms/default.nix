{
  lib,
  pkgs,
  namespace,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.zen.comms;
in
{
  options.zen.comms.enable = mkEnableOption "zen home config: enable extra comms apps";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      slack
      discord
    ];
  };
}
