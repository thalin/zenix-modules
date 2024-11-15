{ lib, config, pkgs, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.zen.roles.nix-devel;
in
{
  options.zen.roles.nix-devel.enable = mkEnableOption "zen role: nix-devel";
  config = mkIf cfg.enable {
    # zen = lib.mkDefault {
    # };
    environment.systemPackages = with pkgs; [
      nixos-generators
    ];
  };
}
