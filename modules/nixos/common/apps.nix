{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    vim # my favored editor
    wget # get stuff from websites
    bash # a shell
    mtr # traceroute
    unzip # unzip shit
  ];
}
