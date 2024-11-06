# GUI config at the system level.

{
  config, pkgs, lib, configLib, ...
}: 
let
  cfg = config.zen.gui;
  inherit (lib) mkEnableOption mkIf;
  inherit (configLib) mkIfElse;
in
{
  imports = [
    ./touchpad.nix
    ./sound.nix
    ./hidpi.nix
    ./stylix.nix
  ];

  options.zen.gui = {
    enable = mkEnableOption "zen config: enable system-level gui";
    xserver = mkEnableOption "zen config: enable xserver";
    wayland = mkEnableOption "zen config: enable wayland";
  };

  config = mkIf cfg.enable {
    # Enable the X11 windowing system.
    services.xserver = {
      enable = mkIfElse cfg.xserver true false;

      xkb = {
        layout = "us";
        # remap capslock to control
        # https://search.nixos.org/options?channel=24.05&show=services.xserver.xkb.options&query=xkb.options
        options = "ctrl:nocaps,terminate:ctrl_alt_bksp";
      };
    };

    # Enable SDDM display manager
    services.displayManager.sddm = {
      enable = true;
      theme = "${import ../../../packages/ariel-sddm-theme.nix { inherit pkgs; }}";
      wayland.enable = mkIfElse cfg.wayland true false;
    };

    environment.systemPackages = [
      # These qt5 packages allow the sddm theme to work.
      pkgs.libsForQt5.qt5.qtmultimedia
      pkgs.libsForQt5.qt5.qtgraphicaleffects
    ];
  };
} 
