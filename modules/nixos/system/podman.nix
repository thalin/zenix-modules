{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.zen.system.podman;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.zen.system.podman.enable = mkEnableOption "zen config: enable podman support";

  config = mkIf cfg.enable {
    virtualisation = {
      containers.enable = true;
      podman = {
        enable = true;
        dockerCompat = true;
        defaultNetwork.settings.dns_enabled = true;
      };
    };
    environment.systemPackages = with pkgs; [
      dive
      podman-tui
      podman-compose
    ];
  };
}
