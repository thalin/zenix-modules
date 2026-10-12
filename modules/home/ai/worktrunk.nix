{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.zen.ai.worktrunk;
  inherit (lib) mkEnableOption mkIf;
  toml = pkgs.formats.toml { };
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

    # Read-only once managed, so `wt config` commands that write here fail;
    # change settings in this module instead.
    xdg.configFile."worktrunk/config.toml".source = toml.generate "worktrunk-config.toml" {
      # Worktrees go inside each repo, e.g. <repo>/.worktrees/feature-auth.
      worktree-path = "{{ repo_path }}/.worktrees/{{ branch | sanitize }}";
      merge = {
        commit = true;
        rebase = true;
        remove = true;
        verify = true;
        ff = true;
      };
      commit.generation.command = "MAX_THINKING_TOKENS=0 claude -p --no-session-persistence --model=haiku --tools='' --safe-mode --setting-sources='user' --system-prompt=''";
    };

    # Keep in-repo worktrees out of the main checkout's git status.
    programs.git.ignores = [ ".worktrees/" ];
  };
}
