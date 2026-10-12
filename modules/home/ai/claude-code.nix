{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.zen.ai.claude-code;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.zen.ai.claude-code.enable = mkEnableOption "zen home: enable claude-code tools";
  
  config = mkIf cfg.enable {
    home.packages = with pkgs; [ claude-code jq ];

    # Per-user Claude Code overrides never belong in a repo.
    programs.git.ignores = [ "**/.claude/settings.local.json" ];

    # claude-code writes this desktop entry itself, into ~/.local/share/applications.
    # Only written out where xdg.mimeApps is enabled (zen.gui.librewolf-scaled.defaultBrowser).
    xdg.mimeApps.defaultApplications."x-scheme-handler/claude-cli" = "claude-code-url-handler.desktop";
  };
}
