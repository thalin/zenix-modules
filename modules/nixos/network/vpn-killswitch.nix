{ lib, config, ... }:
let
  inherit (lib) mkEnableOption mkOption mkIf types concatMapStringsSep;
  cfg = config.zen.network.vpnKillswitch;
in
{
  options.zen.network.vpnKillswitch = {
    enable = mkEnableOption "zen config: drop all outbound traffic except to allowed LAN CIDRs and a VPN tunnel interface";

    vpnInterface = mkOption {
      type = types.str;
      default = "tun0";
      description = "Tunnel interface allowed to carry all outbound traffic.";
    };

    allowedCidrs = mkOption {
      type = types.listOf types.str;
      default = [ "10.0.0.0/16" ];
      description = "Destination CIDRs allowed to leave via any non-tunnel interface.";
    };

    vpnEndpoints = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = ''
        VPN server IP addresses (from the `remote` line(s) of the OpenVPN config) that must
        stay reachable outside allowedCidrs so the tunnel itself can be established.
      '';
    };
  };

  config = mkIf cfg.enable {
    networking.nftables.enable = true;

    networking.nftables.tables.zen-vpn-killswitch = {
      family = "inet";
      content = ''
        chain output {
          type filter hook output priority filter; policy drop;

          oifname "lo" accept
          ct state established,related accept
          oifname "${cfg.vpnInterface}" accept

          ${concatMapStringsSep "\n          " (c: "ip daddr ${c} accept") cfg.allowedCidrs}
          ${concatMapStringsSep "\n          " (e: "ip daddr ${e} accept") cfg.vpnEndpoints}
        }
      '';
    };
  };
}
