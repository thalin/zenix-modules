# Import packages to install xdg stuff
{ config, lib, pkgs, ... } : 
let
  inherit (lib) mkEnableOption mkIf mkDefault;
  cfg = config.zen.gui.steam;
in
{
  options.zen.gui.steam = {
    enable = mkEnableOption "zen config: enable steam";
    xdg_portal = mkEnableOption "zen config: enable XDG Portal for Steam file chooser";
  };

  config = {
    # This is started out lifted from the wiki:
    # https://nixos.wiki/wiki/Steam
    programs.steam = mkIf cfg.enable {
      # docs: https://mynixos.com/nixpkgs/options/programs.steam
      enable = true;
      # https://mynixos.com/nixpkgs/options/programs.steam.remotePlay
      remotePlay.openFirewall = true;
      # https://mynixos.com/nixpkgs/option/programs.steam.localNetworkGameTransfers.openFirewall
      localNetworkGameTransfers.openFirewall = true;
    };

    # Adding this because one can't add a new steam library without something like this; the file chooser widget depends on an xdg portal with a file chooser being available
    # https://github.com/ValveSoftware/steam-for-linux/issues/9640#issuecomment-1595336466
    xdg.portal = mkIf cfg.xdg_portal mkDefault {
      # docs: https://mynixos.com/options/xdg.portal
      enable = true;
      # https://wiki.archlinux.org/title/XDG_Desktop_Portal#List_of_backends_and_interfaces
      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
      ];
      config = {
        common = {
          default = [
            "gtk"
          ];
        };
      };
    };
  };
} 
