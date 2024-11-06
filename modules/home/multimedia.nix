{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    vlc
    smplayer
    mpv
  ];
}
