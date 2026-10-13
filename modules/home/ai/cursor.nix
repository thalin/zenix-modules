{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.zen.ai.cursor;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.zen.ai.cursor.enable = mkEnableOption "zen home: enable Cursor editor and CLI";

  config = mkIf cfg.enable {
    # FHS variant so marketplace extensions with native binaries work
    home.packages = [ pkgs.code-cursor-fhs pkgs.cursor-cli ];
  };
}
