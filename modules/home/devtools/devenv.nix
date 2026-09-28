{ config, lib, pkgs, ... }:
let
  cfg = config.zen.devtools.devenv;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.zen.devtools.devenv.enable = mkEnableOption "zen home: cli utility apps";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      devenv
    ];

    # devenv's own `devenv hook` replaces direnv for cd-based activation
    # (devenv >=2.0) - no .envrc needed, just `devenv allow` per project.
    programs.zsh.initContent = ''
      eval "$(${pkgs.devenv}/bin/devenv hook zsh)"
    '';
  };
}
