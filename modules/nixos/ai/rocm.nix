{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.zen.ai.rocm;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.zen.ai.rocm.enable = mkEnableOption "zen config: enable rocm support";
  
  config = mkIf cfg.enable {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [ rocmPackages.clr ];
    };
  };
}
