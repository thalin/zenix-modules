# This module is useful pretty much anywhere. It sets locale, enables flakes,
# and adds some basic packages which every system is going to need.

{ ... }:

{
  imports = [
    ./i18n.nix
    ./nix.nix
    ./apps.nix
  ];
}
