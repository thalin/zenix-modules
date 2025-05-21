{ lib, ... }:
let
  fileFilter = n: v: lib.strings.hasSuffix ".nix" n &&
                     n != "default.nix" &&
                     v == "regular";
  fileList = builtins.readDir ./.;
  validFiles = lib.attrsets.filterAttrs fileFilter fileList;
  importFiles = lib.attrsets.mapAttrsToList (n: v: ./${n}) validFiles;
in
{
  imports = importFiles;
}
