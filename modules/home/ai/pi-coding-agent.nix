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
  imports = [
    inputs.pi.homeModules.default
  ];

  options.zen.ai.pi-coding-agent.enable = mkEnableOption "zen home: enable pi-coding-agent";

  config = mkIf cfg.enable {
    sops.secrets.gemini_api_key = { };

    programs.pi.coding-agent = {
      enable = true;
      settings = {
        provider = "google";
        model = "gemini-3.5-flash";
      };
      environment = {
        GEMINI_API_KEY = config.sops.secrets.gemini_api_key.path;
      };
    };
  };
}
