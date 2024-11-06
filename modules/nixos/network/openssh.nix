# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ ... }:

{
  # Enable OpenSSH daemon
  services.openssh.enable = true;

  # Open ssh port in firewall.
  networking.firewall = {
    allowedTCPPorts = [ 22 ];
    allowedUDPPorts = [ 22 ];
  };
}
