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
      btop-rocm
    ];

    services.lact.enable = true;

    hardware.amdgpu.overdrive.enable = true;
  };
}
