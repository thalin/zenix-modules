{ 
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.zen.zsh;
in
{
  options.zen.zsh.enable = mkEnableOption "zen home config: zsh with goodies";

  config = mkIf cfg.enable {
    # install packages
    home.packages = with pkgs; [
      zsh
      zsh-prezto
      zsh-powerlevel10k
    ];

    # install config file
    home.file = {
      ".config/zsh/p10k.zsh".source = ./p10k.zsh;
      ".config/zsh/prezto_modules".source = ./prezto_modules;
    };

    # configure zsh
    programs.zsh = {
      enable = true;

      prezto = {
        enable = true;
        pmodules = [
          "environment"
          "terminal"
          "editor"
          "history"
          "directory"
          "spectrum"
          "utility"
          "completion"
          "history-substring-search"
          "autosuggestions"
          "syntax-highlighting"
          "prompt"
          "ssh"
          "module_overrides"
          "p10k"
          "kitty"
          "nixos"
        ];
        pmoduleDirs = [ "${config.home.homeDirectory}/.config/zsh/prezto_modules/" ];
        editor.keymap = "vi";
        prompt.theme = "powerlevel10k";
        prompt.showReturnVal = true;
        syntaxHighlighting.highlighters = [ "main" "brackets" "pattern" "line" "cursor" "root" ];
        extraConfig = ''
        source $HOME/.config/zsh/p10k.zsh
        '';
      };

      shellAliases = {
        nix = "noglob nix";
      };
    };

    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
      options = [
        "--cmd cd"
      ];
    };

    programs.eza = {
      enable = true;
      enableZshIntegration = true;
      extraOptions = [
        "--group-directories-first"
      ];
    };
  };
}
