{ ... }:
{
  imports = [
    ./appimage.nix
    ./kvm-host.nix
    ./proxmox-guest.nix
    ./zfs.nix
    ./sound.nix
    ./touchpad.nix
  ];
}
