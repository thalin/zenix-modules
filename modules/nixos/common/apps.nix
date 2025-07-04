{ pkgs, lib, ... }:
{
  environment.systemPackages = with pkgs; [
    vim # my favored editor - I mean, maybe this should be neovim
    wget # get stuff from websites
    mtr # traceroute
    unzip # unzip shit
  ];

  # Turn on a couple of things I will always want
  programs.zsh.enable = lib.mkDefault true;
  programs.git.enable = lib.mkDefault true;
}
