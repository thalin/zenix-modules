{ lib, config, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.zen.roles.cli;
in
{
  options.zen.roles.cli.enable = mkEnableOption "zen role: cli";

  config = mkIf cfg.enable {
    zen = lib.mkDefault {
      git.enable = true;
      zsh.enable = true;
      nixvim.enable = true;
      tmux.enable = true;
      apps.cliutil.enable = true;
    };
  };
}
