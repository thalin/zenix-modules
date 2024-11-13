{ 
  lib,
  ...
}:
{
  relativeToRoot = lib.path.append ../.;
  mkIfElse = p: yes: no: lib.mkMerge [
    (lib.mkIf p yes)
    (lib.mkIf (!p) no)
  ];
  setCfg = {cfg_path, opt}: let
    path_list = lib.strings.splitString "." cfg_path;
    cfg_path_list = lib.trivial.concat [ "config" ] path_list;
  in lib.attrsets.setAttrByPath cfg_path_list opt;
  setOpt = {cfg_path, opt}: let
    path_list = lib.strings.splitString "." cfg_path;
    cfg_path_list = lib.trivial.concat [ "options" ] path_list;
  in lib.attrsets.setAttrByPath cfg_path_list opt;
  setConfigIf = {cfg_path, opt, config}: let
    path_list = lib.strings.splitString "." cfg_path;
    option = lib.attrset.getAttrByPath lib.lists.flatten [ "config" path_list opt ];
  in lib.attrsets.setAttrByPath [ "config" ] lib.mkIf option config;
}
