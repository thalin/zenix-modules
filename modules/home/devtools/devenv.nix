{ config, lib, pkgs, ... }:
let
  cfg = config.zen.devtools.devenv;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.zen.devtools.devenv.enable = mkEnableOption "zen home: cli utility apps";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      devenv
    ];

    programs = {
      direnv = {
        enable = true;
        enableZshIntegration = true;
        nix-direnv.enable = true;
      };
    };
  };
}
