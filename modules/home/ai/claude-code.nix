{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.zen.ai.claude-code;
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    mkDefault
    types
    ;
  jsonFormat = pkgs.formats.json { };
  settingsFile = "${config.home.homeDirectory}/.claude/settings.json";
  # herdr writes this script itself (`herdr integration install claude`); only the hook entry is ours.
  herdrHook = "${config.home.homeDirectory}/.claude/hooks/herdr-agent-state.sh";
  delegationNudge = lib.getExe (
    pkgs.writeShellApplication {
      name = "claude-delegation-nudge";
      runtimeInputs = with pkgs; [
        jq
        gnugrep
        coreutils
      ];
      text = builtins.readFile ./claude-code/delegation-nudge.sh;
    }
  );
  nudgeHook = arg: {
    type = "command";
    command = "${delegationNudge}${arg}";
    timeout = 5;
  };
in
{
  options.zen.ai.claude-code = {
    enable = mkEnableOption "zen home: enable claude-code tools";

    settings = mkOption {
      inherit (jsonFormat) type;
      default = { };
      description = ''
        Settings merged into ~/.claude/settings.json on activation. The file stays
        writable so /config, /model and permission prompts keep working; declared
        keys win, arrays are replaced, and undeclared keys are left alone.
      '';
    };

    authTokenFile = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "/run/user/1000/secrets/claude_proxy_token";
      description = ''
        Runtime path to the gateway auth token (sops-nix or similar), read via
        apiKeyHelper. When set, any plaintext env.ANTHROPIC_AUTH_TOKEN is removed
        from settings.json. Keep this a string so the secret never hits the store.
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ jq ];

    programs.claude-code = {
      enable = true;
      context = ./claude-code/CLAUDE.md;
      # Sonnet agents the main thread delegates to; Explore overrides the built-in,
      # which otherwise runs on the main model.
      agentsDir = ./claude-code/agents;
    };
    # Saved workflows, run as /review-loop and /fleet-check.
    home.file."${config.programs.claude-code.configDir}/workflows".source = ./claude-code/workflows;
    # Replaces the hand-written copy this module was seeded from.
    home.file."${config.programs.claude-code.configDir}/CLAUDE.md".force = true;

    zen.ai.claude-code.settings = lib.mapAttrsRecursive (_: mkDefault) (
      {
        env = {
          ANTHROPIC_BASE_URL = "https://cli-proxy-api.zen-finity.com";
          CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY = "1";
          API_TIMEOUT_MS = "600000";
          BASH_DEFAULT_TIMEOUT_MS = "600000";
          BASH_MAX_TIMEOUT_MS = "600000";
          CLAUDE_API_TIMEOUT = "600000";
          CLAUDE_CODE_MAX_CONTEXT_TOKENS = "200000";
          CLAUDE_AUTOCOMPACT_PCT_OVERRIDE = "95";
          DISABLE_TELEMETRY = "1";
          MCP_TIMEOUT = "30000";
          MCP_TOOL_TIMEOUT = "600000";
          _ZO_DOCTOR = "0";
          # Agents without their own model (general-purpose, workflow stages) use Sonnet.
          CLAUDE_CODE_SUBAGENT_MODEL = "sonnet";
        };
        # allow/deny are left out so "always allow" answers survive activation.
        permissions.defaultMode = "auto";
        model = "opus";
        effortLevel = "medium";
        worktree.baseRef = "fresh";
        enabledPlugins = {
          "mattpocock-skills@claude-plugins-official" = true;
          "frontend-design@claude-plugins-official" = true;
          "worktrunk@worktrunk" = true;
        };
        extraKnownMarketplaces.worktrunk.source = {
          source = "github";
          repo = "max-sixty/worktrunk";
        };
        tui = "fullscreen";
        skipDangerousModePermissionPrompt = true;
        skipWorkflowUsageWarning = true;
        theme = "dark";
        editorMode = "vim";
        verbose = true;
        autoCompactEnabled = true;
      }
      // {
        hooks = {
          PreToolUse = [
            {
              matcher = "*";
              hooks = [ (nudgeHook "") ];
            }
          ];
          UserPromptSubmit = [ { hooks = [ (nudgeHook " reset") ]; } ];
        }
        // lib.optionalAttrs config.zen.ai.herdr.enable {
          SessionStart = [
            {
              matcher = "^(startup|resume|clear|compact|fork)$";
              hooks = [
                {
                  type = "command";
                  command = "bash '${herdrHook}' session";
                  timeout = 10;
                }
              ];
            }
          ];
        };
      }
      // lib.optionalAttrs (cfg.authTokenFile != null) {
        apiKeyHelper = "cat ${lib.escapeShellArg cfg.authTokenFile}";
      }
    );

    # TODO: replace with programs.claude-code.mutableSettings after the 26.11 upgrade
    # (thalin/nix#12).
    home.activation.claudeCodeSettings =
      let
        jq = lib.getExe pkgs.jq;
        declared = jsonFormat.generate "claude-code-settings.json" (
          { "$schema" = "https://json.schemastore.org/claude-code-settings.json"; } // cfg.settings
        );
        dropToken = lib.optionalString (cfg.authTokenFile != null) " | del(.env.ANTHROPIC_AUTH_TOKEN)";
      in
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        settings=${lib.escapeShellArg settingsFile}
        if [[ -v DRY_RUN ]]; then
          echo "Would merge ${declared} into $settings"
        else
          mkdir -p "$(dirname "$settings")"
          current='{}'
          if [[ -s "$settings" ]]; then
            if ${jq} -e 'type == "object"' "$settings" >/dev/null 2>&1; then
              current="$(cat "$settings")"
            else
              warnEcho "$settings is not a JSON object; moving it to $settings.hm-bak"
              mv "$settings" "$settings.hm-bak"
            fi
          fi
          # mktemp gives 0600, which suits a file that may still hold a token.
          tmp="$(mktemp "$settings.XXXXXX")"
          ${jq} -s '.[0] * .[1]${dropToken}' <(printf '%s' "$current") ${declared} > "$tmp"
          # Drops a leftover store symlink too, instead of writing through it.
          mv -f "$tmp" "$settings"
        fi
      '';
  };
}
