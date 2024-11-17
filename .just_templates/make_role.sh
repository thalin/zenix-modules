#!/usr/bin/env bash

ROLE_NAME=$1
MOD_TYPE=${2:-nixos}

ROLE_DIR="modules/${MOD_TYPE}/roles"

if [ -f ${ROLE_DIR}/${ROLE_NAME}.nix ]; then
  echo "Role ${ROLE_NAME} already exists."
  exit
fi

cp .just_templates/role_template.nix ${ROLE_DIR}/${ROLE_NAME}.nix
sed -i -e "s/ROLE_NAME/${ROLE_NAME}/g" ${ROLE_DIR}/${ROLE_NAME}.nix
