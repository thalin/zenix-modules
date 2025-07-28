# Make a new zenix module

This script does two things:

1. Creates a new directory for a module
2. Copies over the default.nix file for modules.

It takes two arguments:

1. `type`: either `nixos` or `home`
2. `module_name`: defines the module name. Should have no spaces.

The directory is created under `../modules/<type>/<module_name>/`, and then the file `module_default.nix` in this directory is copied to the new directory as `default.nix`.
