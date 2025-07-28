{ pkgs ? import <nixpkgs> { } } :

pkgs.writeShellScriptBin "make_zenix_module" ''
  set -e

  if [ "$#" -ne 2 ]; then
    echo "Usage: make_zenix_module <type> <module_name>"
    exit 1
  fi

  TYPE=$1
  MODULE_NAME=$2

  if [ "$TYPE" != "nixos" ] && [ "$TYPE" != "home" ]; then
    echo "Error: type must be either 'nixos' or 'home'"
    exit 1
  fi

  MODULE_DIR="modules/$TYPE/$MODULE_NAME"

  echo "Creating directory: $MODULE_DIR"
  mkdir -p "$MODULE_DIR"

  echo "Writing default.nix to $MODULE_DIR"
  cat > "$MODULE_DIR/default.nix" <<'EOF'
{ lib, ... }:
let
  fileFilter = n: v: lib.strings.hasSuffix ".nix" n &&
                     n != "default.nix" &&
                     v == "regular";
  fileList = builtins.readDir ./.;
  validFiles = lib.attrsets.filterAttrs fileFilter fileList;
  importFiles = lib.attrsets.mapAttrsToList (n: v: ./''${n}) validFiles;
in
{
  imports = importFiles;
}
EOF

  echo "Done."
''
