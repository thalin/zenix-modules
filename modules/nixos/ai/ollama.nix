{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.zen.ai.ollama;
  inherit (lib) mkEnableOption mkPackageOption mkIf;
in
{
  options.zen.ai.ollama.enable = mkEnableOption "zen config: enable ollama";
  options.zen.ai.ollama.webui-pkg = mkPackageOption pkgs "open-webui" { };
  
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ ollama-rocm ];
    services = {
      ollama = {
        enable = true;
        acceleration = "rocm";
        rocmOverrideGfx = "11.0.1";
        host = "127.0.0.1";
        port = 11434;
        openFirewall = true;
      };
      open-webui = {
        enable = true;
        package = cfg.webui-pkg;
      };
    };
  };
}

