{ config, lib, ... }:
let
  cfg = config.zen.network.openssh;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.zen.network.openssh.enable = mkEnableOption "zen config: enable openssh server";

  config = mkIf cfg.enable {
    # Enable OpenSSH daemon
    services.openssh.enable = true;

    # Open ssh port in firewall.
    networking.firewall = {
      allowedTCPPorts = [ 22 ];
      allowedUDPPorts = [ 22 ];
    };
  };
}
