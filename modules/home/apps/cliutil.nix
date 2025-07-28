{ config, lib, pkgs, ... }:
let
  cfg = config.zen.apps.cliutil;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.zen.apps.cliutil.enable = mkEnableOption "zen home: cli utility apps";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      pciutils
      #usbutils
      silver-searcher
      #psmisc
      fzf
      p7zip
      age
      ssh-to-age
      sops
      xh
      du-dust
      dua
      tokei
      mask
      just
    ] ++ lib.optionals (pkgs.stdenv.isLinux) [ usbutils psmisc ];

    programs = {
      bat = {
        enable = true;
        # 8/27/2024 - removed batdiff from extraPackages because it failed a test
        # after switching to nixpkgs-unstable
        extraPackages = with pkgs.bat-extras; [ batman batgrep batwatch ];
      }; # programs.bat

      zellij = {
        enable = true;
        # I don't like it running all the time.
        # enableZshIntegration = true;
      };

      yazi = {
        enable = true;
        enableZshIntegration = true;
      };

      ncspot = {
        enable = true;
        settings = {
          use_nerdfont = true;
        };
      };
      ripgrep.enable = true;
      fd.enable = true;
      btop.enable = true;
      aria2.enable = true;

      zsh.shellAliases = {
        cat = "bat";
      }; # programs.zsh.shellAliases
    };
  };

}
