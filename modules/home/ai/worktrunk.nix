{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.zen.ai.worktrunk;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.zen.ai.worktrunk.enable = mkEnableOption "zen home: enable worktrunk git worktree manager";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ worktrunk ];

    # TODO: switch to programs.worktrunk once home-manager/release-26.05
    # includes the worktrunk module (merged in main at modules/programs/worktrunk.nix)
    # Shell integration is required for `wt switch` to change directories
    programs.zsh.initContent = ''
      eval "$(${pkgs.worktrunk}/bin/wt config shell init zsh)"
    '';
  };
}
