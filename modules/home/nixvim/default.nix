{
  lib,
  config,
  inputs,
  pkgs,
  ...
}:
let 
  inherit (lib) mkEnableOption mkIf;
  cfg = config.zen.nixvim;
in
{
  options.zen.nixvim.enable = mkEnableOption "zen config: enable nixvim";

  imports = [
    inputs.nixvim.homeManagerModules.nixvim
    ./keymaps.nix
    ./options.nix
    ./plugins
  ];

  config = mkIf cfg.enable {

    programs.nixvim = {
      enable = true;

      defaultEditor = true;

      viAlias = true;
      vimAlias = true;

      globals = {
        mapleader = " ";
        maplocalleader = " ";
      };
    }; # programs.nixvim

    home.sessionVariables = lib.mkDefault {
      VISUAL="$EDITOR";
    };

    # Additional packages that nixvim configuration needs
    home.packages = with pkgs; [
      ripgrep
      fzf
    ];
  };
}
