{ 
  lib,
  pkgs,
  namespace,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.zen.git;
in
{
  options.zen.git = {
    enable = mkEnableOption "zen home config: enable git configuration";
    userName = mkOption {
      type = types.str;
      default = "thalin";
    };
    userEmail = mkOption {
      type = types.str;
      default = "28450+thalin@users.noreply.github.com"; 
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      git
    ];
    programs.git = {
      enable = true;
      userName = cfg.userName;
      userEmail = cfg.userEmail;
      aliases = {
        it = "!git init . && git add . && git commit --allow-empty -m 'First commit'";
      };
      extraConfig = {
        push = {
          autoSetupRemote = true;
        };
        init = {
          defaultBranch = "main";
        };
      };
    };
  };
}
