{ lib, ... }:
let
  fileList = builtins.readDir ../.;
  validFiles = lib.attrsets.filterAttrs (n: v: n != "zenix" && v == "directory") fileList;
  importDirs = lib.attrsets.mapAttrsToList (n: v: ../${n}) validFiles;
in
{
  imports = importDirs;
  # imports = [
  #   ../common
  #   ../gui
  #   ../games
  #   ../hardware
  #   ../network
  #   ../system
  #   ../roles
  #   # ../suites
  # ];
}
