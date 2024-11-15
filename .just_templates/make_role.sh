#!/usr/bin/env bash

ROLE_DIR="modules/nixos/roles"

ROLE_NAME=$1

if [ -f ${ROLE_DIR}/${ROLE_NAME}.nix ]; then
  echo "Role ${ROLE_NAME} already exists."
  exit
fi

cp .just_templates/role_template.nix ${ROLE_DIR}/${ROLE_NAME}.nix
sed -i -e "s/ROLE_NAME/${ROLE_NAME}/" ${ROLE_DIR}/${ROLE_NAME}.nix
