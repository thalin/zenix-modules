#!/usr/bin/env bash

ROLE_DIR="modules/nixos/roles"

role_name=$1

if [ -f ${ROLE_DIR}/${role_name}.nix ]; then
  echo "Role ${role_name} already exists."
  exit
fi

cp .just_templates/role_template.nix ${ROLE_DIR}/${role_name}.nix
sed -i -e "s/ROLE_NAME/${role_name}/" ${ROLE_DIR}/${role_name}.nix
