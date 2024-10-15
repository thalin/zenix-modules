{ 
  lib, 
  config, 
  namespace,
  pkgs, 
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.${namespace}.tmux;
in
{
  options.${namespace}.tmux.enable = mkEnableOption; 

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      tmux
    ];
    programs.tmux = {
      enable = true;
      keyMode = "vi";
      newSession = true;
      shortcut = "a";
    };
  };
}
