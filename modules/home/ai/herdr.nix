{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.zen.ai.herdr;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.zen.ai.herdr.enable = mkEnableOption "zen home: enable herdr tools";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ herdr ];

    # TODO: switch to programs.herdr.settings once home-manager/release-26.05
    # includes the herdr module (merged in main at modules/programs/herdr.nix)
    xdg.configFile."herdr/config.toml".source =
      (pkgs.formats.toml { }).generate "herdr-config.toml" {
        onboarding = false;
        terminal.default_shell = "${pkgs.zsh}/bin/zsh";
      };
  };
}
