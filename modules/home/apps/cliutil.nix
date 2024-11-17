{ config, lib, pkgs, ... }:
let
  cfg = config.zen.apps.cliutil;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.zen.apps.cliutil.enable = mkEnableOption "zen home: cli utility apps";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      xorg.xdpyinfo
      pciutils
      usbutils
      bat
      silver-searcher
      psmisc
      aria2
      fzf
      p7zip
      age
      ssh-to-age
      sops
    ];

    programs.bat = {
      enable = true;
      # 8/27/2024 - removed batdiff from extraPackages because it failed a test
      # after switching to nixpkgs-unstable
      extraPackages = with pkgs.bat-extras; [ batman batgrep batwatch ];
    }; # programs.bat

    programs.zsh.shellAliases = {
      cat = "bat";
    }; # programs.zsh.shellAliases
  };

}
