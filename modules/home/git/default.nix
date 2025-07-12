{ 
  lib,
  pkgs,
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
        it = "!git init . && git commit --allow-empty -m 'First commit'";
      };
      extraConfig = {
        core = {
          compression = 9;
          whitespace = "error";
          preloadindex = true;
        };
        branch = {
          sort = "-committerdate";
        };
        color = {
          "decorate" = {
            HEAD = "red";
            branch = "blue";
            tag = "yellow";
            remoteBranch = "magenta";
          };
          "branch" = {
            current = "magenta";
            local = "default";
            remote = "yellow";
            upstream = "green";
            plain = "blue";
          };
          "diff" = {
            meta = "blue";
          };
        };
        diff = {
          context = 3;
          renames = "copies";
          interHunkContext = 10;
        };
        init = {
          defaultBranch = "main";
        };
        interactive = {
          singlekey = true;
        };
        log = {
          abbrevCommit = true;
          graphColors = "blue,yellow,cyan,magenta,green,red";
        };
        pull = {
          default = "current";
          rebase = true;
        };
        push = {
          autoSetupRemote = true;
          default = "current";
          followTags = true;
        };
        rebase = {
          autoStash = true;
          missingCommitsCheck = "warn";
        };
        status = {
          branch = true;
          showStash = true;
          showUntrackedFiles = "all";
        };
        tag = {
          sort = "-taggerdate";
        };
        url = {
          "git@github.com:".insteadOf = "gh:";
          "git@github.com:thalin/".insteadOf = "gt:";
        };
        gpg = {
          "ssh" = {
            allowedSignersFile = "~/.config/git/allowed_signers";
          };
        };
      };
      diff-so-fancy = {
        enable = true;
        markEmptyLines = false;
      };
    };
    programs.zsh.shellAliases = {
      gs  = "git status --short";
      gd  = "git diff";
      ga  = "git add";
      gap = "git add --patch";
      gc  = "git commit";
      gp  = "git push";
      gu  = "git pull";
      gl  = "git log --all --graph --pretty=format:'%C(magenta)%h %C(white) %an  %ar%C(auto)  %D%n%s%n'";
      gb  = "git branch";
      gi  = "git it";
      gcl = "git clone";
    };
  };
}
