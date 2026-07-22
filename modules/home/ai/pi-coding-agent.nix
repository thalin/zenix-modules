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
    gemini_api_key = lib.mkOption {
      type = lib.types.path;
      default = /dev/null;
      description = "The path to the secret gemini api key. Use sops-nix or something.";
    };
    openrouter_api_key = lib.mkOption {
      type = lib.types.path;
      default = /dev/null;
      description = "The path to the secret openrouter api key. Use sops-nix or something.";
  };

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.graphify
    ];

    programs.pi.coding-agent = {
      enable = true;
      settings = {
        inherit (cfg) provider model;
      };
      environment = {
        GEMINI_API_KEY = cfg.gemini_api_key;
        OPENROUTER_API_KEY = cfg.openrouter_api_key;
      };
    };
  };
}
