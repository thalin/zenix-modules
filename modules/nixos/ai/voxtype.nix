{
  config,
  lib,
  ...
}:
let
  cfg = config.zen.ai.voxtype;
  inherit (lib) mkEnableOption mkOption mkIf types;
in
{
  options.zen.ai.voxtype = {
    enable = mkEnableOption "zen config: system support for voxtype dictation (evdev hotkey + uinput typing)";
    users = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = ''
        Users to add to the input and uinput groups. voxtype's built-in
        push-to-talk hotkey reads /dev/input (input group), and dotool types
        the transcript through /dev/uinput (uinput group). Note that input
        group membership lets that user's processes read all keyboard input.
      '';
    };
  };

  config = mkIf cfg.enable {
    hardware.uinput.enable = true;

    users.users = lib.genAttrs cfg.users (_: {
      extraGroups = [ "input" "uinput" ];
    });
  };
}
