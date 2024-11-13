{ lib, ... }:
let
  inherit (lib) mkOption types;
  fileFilter = n: v: lib.strings.hasSuffix ".nix" n &&
                     n != "default.nix" &&
                     v == "regular";
  fileList = builtins.readDir ./.;
  validFiles = lib.attrsets.filterAttrs fileFilter fileList;
  importFiles = lib.attrsets.mapAttrsToList (n: v: ./${n}) validFiles;
in
{
  imports = importFiles;

  options.zen.suites = mkOption {
    type = types.listOf types.str;
    default = [];
    example = [ "gui-desktop" "gui-games" ];
    description = "zen config: list of suites to enable";
  };
}
