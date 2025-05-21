{ config, lib, ... }:
let
  cfg = config.zen.network.tailscale;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.zen.network.tailscale.enable = mkEnableOption "zen config: enable tailscale";

  config = mkIf cfg.enable {
    # Enable tailscale
    services.tailscale.enable = true;
  };
}
