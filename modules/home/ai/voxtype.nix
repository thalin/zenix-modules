{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.zen.ai.voxtype;
  inherit (lib) mkEnableOption mkOption mkPackageOption mkIf mkDefault types;
  toml = pkgs.formats.toml { };

  # voxtype post_process hook (stdin -> stdout). A short utterance that starts
  # with "slash" becomes a slash command: "Slash clear." -> "/clear",
  # "slash code review" -> "/code-review". Anything else passes through as-is.
  slashCommands = pkgs.writeShellApplication {
    name = "voxtype-slash-commands";
    text = ''
      text=$(cat)
      shopt -s nocasematch
      # "slash"/"forward slash" (Whisper adds commas) or a literal "/", then
      # one to three words, then any trailing punctuation Whisper tacked on
      re='^[[:space:]]*(forward[[:space:]]+)?(slash[[:space:],.]+|/)([[:alnum:]]+([[:space:]-]+[[:alnum:]]+){0,2})[[:space:].!?]*$'
      if [[ $text =~ $re ]]; then
        cmd=''${BASH_REMATCH[3],,}
        cmd=$(tr -s ' -' '-' <<<"$cmd")
        printf '/%s' "$cmd"
      else
        printf '%s' "$text"
      fi
    '';
  };
in
{
  options.zen.ai.voxtype = {
    enable = mkEnableOption "zen home: enable voxtype push-to-talk dictation";
    package = mkPackageOption pkgs "voxtype-vulkan" { };
    model = mkOption {
      type = types.path;
      # Pinned in the store so the daemon never downloads anything at runtime
      default = pkgs.fetchurl {
        name = "ggml-large-v3-turbo.bin";
        url = "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3-turbo.bin";
        sha256 = "0sdwwblbfy9qjkjjxxvyfn47rx3y6pm1wfdcjfcidsrq9mvhziqz";
      };
      description = "Whisper ggml model file to transcribe with";
    };
    slashCommands = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Turn short utterances starting with "slash" into slash commands
        ("slash compact" -> "/compact") via voxtype's post_process hook.
      '';
    };
    settings = mkOption {
      type = toml.type;
      default = { };
      description = "voxtype config.toml settings, merged over the defaults below";
    };
  };

  config = mkIf cfg.enable {
    # Push-to-talk on ScrollLock via evdev (qtile can't bind key-release),
    # typing through dotool since wtype is Wayland-only. Both need the
    # input/uinput groups from the zen.ai.voxtype NixOS module.
    zen.ai.voxtype.settings = {
      hotkey = {
        enabled = mkDefault true;
        key = mkDefault "SCROLLLOCK";
        mode = mkDefault "push_to_talk";
      };
      audio = {
        device = mkDefault "default";
        sample_rate = mkDefault 16000;
        max_duration_secs = mkDefault 120;
      };
      whisper = {
        model = mkDefault "${cfg.model}";
        language = mkDefault "en";
      };
      output = {
        mode = mkDefault "type";
        driver_order = mkDefault [ "dotool" ];
        fallback_to_clipboard = mkDefault true;
        post_process = mkIf cfg.slashCommands {
          command = mkDefault (lib.getExe slashCommands);
          timeout_ms = mkDefault 1000;
        };
      };
    };

    home.packages = [ cfg.package ];

    xdg.configFile."voxtype/config.toml".source = toml.generate "voxtype-config.toml" cfg.settings;

    systemd.user.services.voxtype = {
      Unit = {
        Description = "voxtype push-to-talk dictation";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
        X-Restart-Triggers = [ config.xdg.configFile."voxtype/config.toml".source ];
      };
      Install.WantedBy = [ "graphical-session.target" ];
      Service = {
        ExecStart = "${lib.getExe cfg.package} daemon";
        Restart = "on-failure";
        RestartSec = 5;
      };
    };
  };
}
