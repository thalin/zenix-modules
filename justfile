new-role role:
  @echo 'Making new role: {{role}}...'
  {{justfile_directory()}}/.just_templates/make_role.sh {{role}}

new-suite suite:
  @echo 'Making new suite: {{suite}}...'
  {{justfile_directory()}}/.just_templates/make_suite.sh {{suite}}
