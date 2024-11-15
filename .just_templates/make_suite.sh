#!/usr/bin/env bash

SUITE_DIR="modules/nixos/suites"

SUITE_NAME=$1

if [ -f ${SUITE_DIR}/${SUITE_NAME}.nix ]; then
  echo "suite ${SUITE_NAME} already exists."
  exit
fi

cp .just_templates/suite_template.nix ${SUITE_DIR}/${SUITE_NAME}.nix
sed -i -e "s/SUITE_NAME/${SUITE_NAME}/" ${SUITE_DIR}/${SUITE_NAME}.nix
