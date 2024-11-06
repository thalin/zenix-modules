{ lib, config, ... }:
let
  cfg = config.zen.touchpad;
  inherit (lib) mkEnableOption mkIf;
in {

  options.zen.touchpad = {
    enable = mkEnableOption "zen config: touchpad setup";
  };

  config = mkIf cfg.enable {
    # This should help prevent jumping around by accidentally hitting the touchpad
    # when editing files, especially in Vim where it is really annoying
    services.libinput.touchpad.disableWhileTyping = true;
  };
}
