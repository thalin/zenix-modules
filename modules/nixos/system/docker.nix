{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.zen.system.docker;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.zen.system.docker.enable = mkEnableOption "zen config: enable docker support";

  config = mkIf cfg.enable {
    virtualisation = {
      containers.enable = true;
      docker = {
        enable = true;
      };
    };
    environment.systemPackages = with pkgs; [
      dive
      docker-compose
    ];
  };
}
