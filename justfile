new-role role:
  @echo 'Making new role: {{role}}...'
  {{justfile_directory()}}/.just_templates/make_role.sh {{role}}

new-suite suite:
  @echo 'Making new suite: {{suite}}...'
  {{justfile_directory()}}/.just_templates/make_suite.sh {{suite}}

new-hm-role role:
  @echo 'Making new home-manager role: {{role}}...'
  {{justfile_directory()}}/.just_templates/make_role.sh {{role}} home

new-hm-suite suite:
  @echo 'Making new home-manager suite: {{suite}}...'
  {{justfile_directory()}}/.just_templates/make_suite.sh {{suite}} home

new-darwin-role role:
  @echo 'Making new darwin role: {{role}}...'
  {{justfile_directory()}}/.just_templates/make_role.sh {{role}} darwin

new-darwin-suite suite:
  @echo 'Making new darwin suite: {{suite}}...'
  {{justfile_directory()}}/.just_templates/make_suite.sh {{suite}} darwin

new-home-module module_name:
  @echo 'Making new home module: {{module_name}}...'
  nix run .\#make_zenix_module home {{module_name}}

new-nixos-module module_name:
  @echo 'Making new nixos module: {{module_name}}...'
  nix run .\#make_zenix_module nixos {{module_name}}
