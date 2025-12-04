{
  config,
  pkgs,
  inputs,
  lib,
  namespace,
  ...
}:
let
  cfg = config.zen.system.kvm-host;
  inherit (lib) mkEnableOption mkIf;
in
{
  # options.${cfg_path}.enable = mkEnableOption "zen config: enable kvm-host support";
  options.zen.system.kvm-host.enable = mkEnableOption "zen config: enable kvm-host support";

  config = mkIf cfg.enable {
    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;
        # ovmf = {
        #   enable = true;
        #   packages = [(pkgs.OVMF.override {
        #     secureBoot = true;
        #     tpmSupport = true;
        #   }).fd];
        # };
      };
    };
    programs.virt-manager.enable = true;
    environment.systemPackages = with pkgs; [
      virt-viewer
      quickemu
    ];
  };
}
