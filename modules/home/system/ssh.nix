{ config, lib, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.zen.system.ssh;
in
{
  options.zen.system.ssh.enable = mkEnableOption "zen home: ssh user config";
  config = mkIf cfg.enable {
    programs.ssh = {
      enable = true;
      matchBlocks = {
        # just an example for github
        "gh" = {
          hostname = "github.com";
          user = "git";
        };
      };
    };
    services.ssh-agent.enable = true;
    programs.zsh.prezto.ssh.identities = [
      "id_ed25519" # use good keys please
    ];
    # Note: Things like authorized ssh keys go in the nixos config for a user,
    # not home-manager. A cool trick though is to add your github ssh keys file
    # as a flake input and refer to it like this - again, in your nixos config, 
    # not here in home-manager:
    # in flake inputs:
    # sshkeys = {
    #   url = "https://github.com/myghuser.keys";
    #   flake = false;
    # };
    #
    # and then wherever you define your user(s), set the following option:
    # users.users.<username>.openssh.authorizedKeys.keyFiles = [ sshkeys.outPath ];
    #
    # See also this thread on the nixos discourse forum:
    # https://discourse.nixos.org/t/fetching-ssh-public-keys/12076/7
  };
}
