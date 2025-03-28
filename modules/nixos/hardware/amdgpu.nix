{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.zen.hardware.amdgpu;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.zen.hardware.amdgpu.enable = mkEnableOption "zen config: amdgpu tools";

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      lact
      amdgpu_top
    ];

    # systemd.services.lact = {
    #   description = "AMDGPU Control Daemon";
    #   after = ["multi-user.target"];
    #   wantedBy = ["multi-user.target"];
    #   serviceConfig = {
    #     ExecStart = "${pkgs.lact}/bin/lact daemon";
    #   };
    #   enable = true;
    # };
  };
}
