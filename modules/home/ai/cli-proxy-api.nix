{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.zen.ai.cli-proxy-api;
  inherit (lib) mkEnableOption mkOption mkPackageOption mkIf mkDefault types;
  yaml = pkgs.formats.yaml { };

  cli-proxy-api = import ../../../packages/cli-proxy-api { inherit pkgs; };

  generatedConfig = yaml.generate "cli-proxy-api-config.yaml" cfg.settings;
  sourceConfig = if cfg.configFile != null then cfg.configFile else "${generatedConfig}";
  runtimeConfig = "${cfg.dataDir}/config.yaml";

  # The CLI's -login flags read auth-dir from the config, so point them at the
  # service's runtime copy by default. Go's flag package lets a later -config
  # override this one.
  wrapped = pkgs.writeShellApplication {
    name = "cli-proxy-api";
    text = ''
      exec ${lib.getExe cfg.package} -config ${lib.escapeShellArg runtimeConfig} "$@"
    '';
  };

  # CLIProxyAPI rewrites its own config (hashes the management secret,
  # migrates the layout, saves management-panel edits), so it can't run off a
  # read-only store path. Re-copy on every start so the declared config always
  # wins over runtime edits. Logs go to ./logs, hence the cd.
  start = pkgs.writeShellApplication {
    name = "cli-proxy-api-start";
    runtimeInputs = [ pkgs.coreutils ];
    text = ''
      install -Dm600 ${lib.escapeShellArg sourceConfig} ${lib.escapeShellArg runtimeConfig}
      cd ${lib.escapeShellArg cfg.dataDir}
      exec ${lib.getExe cfg.package} -config ${lib.escapeShellArg runtimeConfig}
    '';
  };
in
{
  options.zen.ai.cli-proxy-api = {
    enable = mkEnableOption "zen home: run CLIProxyAPI as a user service";
    package = mkPackageOption { inherit cli-proxy-api; } "cli-proxy-api" { };
    dataDir = mkOption {
      type = types.str;
      default = "${config.xdg.dataHome}/cli-proxy-api";
      description = ''
        Working directory for the service: holds the runtime config.yaml copy
        and the logs directory.
      '';
    };
    settings = mkOption {
      type = yaml.type;
      default = { };
      description = ''
        CLIProxyAPI config.yaml settings, merged over the defaults below. See
        config.example.yaml upstream. Lands in the nix store, so don't put
        api-keys here; use configFile for anything secret.
      '';
    };
    configFile = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "/run/user/1000/secrets/cli-proxy-api.yaml";
      description = ''
        Runtime path to a full config.yaml (e.g. a sops-nix template) used
        instead of settings. Kept as a string so it never enters the store.
      '';
    };
  };

  config = mkIf cfg.enable {
    zen.ai.cli-proxy-api.settings = {
      host = mkDefault "127.0.0.1";
      port = mkDefault 8317;
      auth-dir = mkDefault "${config.home.homeDirectory}/.cli-proxy-api";
    };

    home.packages = [ wrapped ];

    systemd.user.services.cli-proxy-api = {
      Unit = {
        Description = "CLIProxyAPI";
        X-Restart-Triggers = [ sourceConfig ];
      };
      Install.WantedBy = [ "default.target" ];
      Service = {
        ExecStart = lib.getExe start;
        Restart = "on-failure";
        RestartSec = 5;
      };
    };
  };
}
