# GUI config at the system level.

{
  config, pkgs, lib, ...
}: 
let
  cfg = config.zen.gui;
  inherit (lib) mkEnableOption mkIf;
  inherit (lib.snowzen) mkIfElse;

  fileFilter = n: v: lib.strings.hasSuffix ".nix" n &&
                     n != "default.nix" &&
                     v == "regular";
  fileList = builtins.readDir ./.;
  validFiles = lib.attrsets.filterAttrs fileFilter fileList;
  importFiles = lib.attrsets.mapAttrsToList (n: v: ./${n}) validFiles;
in
{
  imports = importFiles;

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
      # theme = pkgs.ariel-sddm-theme;
      # theme = outputs.packages.${system}.ariel-sddm-theme;
      theme = "${import ../../../packages/ariel-sddm-theme/default.nix { inherit pkgs; }}";
      wayland.enable = mkIfElse cfg.wayland true false;
    };

    environment.systemPackages = [
      # These qt5 packages allow the sddm theme to work.
      pkgs.libsForQt5.qt5.qtmultimedia
      pkgs.libsForQt5.qt5.qtgraphicaleffects
    ];
  };
} 
