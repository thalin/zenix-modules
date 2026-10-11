{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.zen.ai.herdr;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.zen.ai.herdr.enable = mkEnableOption "zen home: enable herdr tools";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ herdr ];

    # TODO: switch to programs.herdr.settings once home-manager/release-26.05
    # includes the herdr module (merged in main at modules/programs/herdr.nix)
    xdg.configFile."herdr/config.toml".source =
      (pkgs.formats.toml { }).generate "herdr-config.toml" {
        onboarding = false;
        terminal.default_shell = "${pkgs.zsh}/bin/zsh";

        # Plugins are installed imperatively (`herdr plugin install`); these only
        # bind their actions. Keys avoid herdr defaults except prefix+shift+g,
        # which worktrunk deliberately takes over from the built-in new_worktree.
        keys.command =
          let
            bind = key: command: description: {
              inherit key command description;
              type = "plugin_action";
            };
          in
          [
            # smarzban/herdr-file-viewer
            (bind "prefix+f" "herdr-file-viewer.open-file-viewer" "open file viewer in split")
            (bind "prefix+shift+f" "herdr-file-viewer.open-file-viewer-tab" "open file viewer in tab")
            (bind "prefix+d" "herdr-file-viewer.open-file-viewer-at" "open file viewer at… (split)")
            (bind "prefix+alt+d" "herdr-file-viewer.open-file-viewer-at-tab" "open file viewer at… (tab)")

            # persiyanov/herdr-reviewr (upstream suggests cmd+r, which is macOS-only)
            (bind "prefix+alt+r" "persiyanov.reviewr.toggle" "toggle reviewr pane")

            # speardragon/herdr-plugin-manager (upstream suggests prefix+p = previous_tab)
            (bind "prefix+alt+p" "ray.plugin-manager.open" "open plugin manager")

            # devashish2203/herdr-worktrunk (upstream suggests prefix+shift+d/r,
            # which are close_workspace/reload_config)
            (bind "prefix+shift+g" "worktrunk.open" "worktree: switch / create from default branch")
            (bind "prefix+shift+c" "worktrunk.open-current" "worktree: switch / create from current branch")
            (bind "prefix+alt+g" "worktrunk.open-with-remotes" "worktree: switch / create incl. remotes")
            (bind "prefix+alt+x" "worktrunk.remove" "worktree: remove")
            (bind "prefix+shift+m" "worktrunk.merge" "worktree: merge into target branch")
            (bind "prefix+alt+m" "worktrunk.merge-no-squash" "worktree: merge, keeping every commit")
          ];
      };
  };
}
