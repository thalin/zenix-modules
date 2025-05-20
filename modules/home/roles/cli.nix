{ lib, config, ... }:
let
  inherit (lib) mkIf mkEnableOption mkDefault;
  cfg = config.zen.roles.cli;
in
{
  options.zen.roles.cli.enable = mkEnableOption "zen role: cli";

  config = mkIf cfg.enable {
    zen = {
      system.ssh.enable = mkDefault true;
      git.enable = mkDefault true;
      zsh.enable = mkDefault true;
      nixvim = {
        enable = mkDefault true;
        plugins.avante.enable = mkDefault false;
      };
      tmux.enable = mkDefault true;
      apps.cliutil.enable = mkDefault true;
    };
  };
}
