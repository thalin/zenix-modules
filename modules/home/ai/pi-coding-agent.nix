{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  cfg = config.zen.ai.pi-coding-agent;
  inherit (lib) mkEnableOption mkIf;
in
{
  imports = mkIf cfg.enable [
    inputs.pi.homeModules.default
  ];

  options.zen.ai.pi-coding-agent = {
    enable = mkEnableOption "zen home: enable pi-coding-agent";
    provider = lib.mkOption {
      type = lib.types.str;
      default = "google";
      description = "The AI provider to use for pi-coding-agent";
    };
    model = lib.mkOption {
      type = lib.types.str;
      default = "gemini-3.5-flash";
      description = "The AI model to use for pi-coding-agent";
    };
  };

  config = mkIf cfg.enable {
    sops.secrets.gemini_api_key = { };
    sops.secrets.openrouter_api_key = { };

    home.packages = [
      pkgs.graphify
    ];

    programs.pi.coding-agent = {
      enable = true;
      settings = {
        inherit (cfg) provider model;
      };
      environment = {
        GEMINI_API_KEY = config.sops.secrets.gemini_api_key.path;
        OPENROUTER_API_KEY = config.sops.secrets.openrouter_api_key.path;
      };
    };
  };
}
